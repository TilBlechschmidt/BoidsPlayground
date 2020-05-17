//
//  RenderingController.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 05.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

import Foundation
import Metal
import MetalKit

class PipelineController {
    private let waveController: WaveController
    private var timeIndex: UInt32 = 0

    // MARK: Configuration
    var configuration = SimulationConfiguration()
    var touchLocation: (Float, Float)? = nil
    
    // MARK: Textures
    private let boidTexture: MTLTexture
    
    // MARK: Buffers
    private let computeConfiguration: ForceComputeConfiguration
    private let boidState: BoidState
    private let vertexBuffer: MTLBuffer
    /// Array of `boidCount * 2 * 3` floats containing two 3D vectors (source, target) for up to each boid
    private let interactionVertexBuffer: MTLBuffer

    // MARK: Pipelines
    private let device: MTLDevice
    private let forcePipelineState: MTLComputePipelineState
    private let tickPipelineState: MTLComputePipelineState
    private let geometryPipelineState: MTLComputePipelineState
    private let renderPipelineStates: [BoidColoration : MTLRenderPipelineState]
    private let interactionRenderPipelineState: MTLRenderPipelineState

    init?(computeConfiguration: ForceComputeConfiguration, boidState: BoidState, device: MTLDevice) {
        let textureLoader = MTKTextureLoader(device: device)
        self.waveController = WaveController(device: device, textureLoader: textureLoader)

        guard let vertexBuffer = device.makeBuffer(length: boidState.boidCount * 2 * 3 * MemoryLayout<BoidVertexIn>.stride, options: [.storageModePrivate]),
            let interactionVertexBuffer = device.makeBuffer(length: boidState.boidCount * 2 * 3 * MemoryLayout<Float>.stride, options: [.storageModePrivate])
        else {
            return nil
        }

        self.computeConfiguration = computeConfiguration
        self.boidState = boidState
        self.vertexBuffer = vertexBuffer
        self.interactionVertexBuffer = interactionVertexBuffer

        self.device = device
        self.forcePipelineState = device.makeComputePipelineState(functionName: "boid_force")!
        self.tickPipelineState = device.makeComputePipelineState(functionName: "boid_tick")!
        self.geometryPipelineState = device.makeComputePipelineState(functionName: "boid_to_triangles")!
        self.interactionRenderPipelineState = device.makeRenderPipelineState(vertexFunctionName: "interaction_vertex", fragmentFunctionName: "interaction_fragment")!
        
        self.renderPipelineStates = BoidColoration.allCases.reduce(into: [:]) {
            $0[$1] = device.makeRenderPipelineState(vertexFunctionName: "boid_vertex", fragmentFunctionName: $1.rawValue)!
        }

        self.boidTexture = try! textureLoader.newTexture(name: "fish", scaleFactor: 1.0, bundle: .main, options: [.origin: MTKTextureLoader.Origin.flippedVertically])
    }

    func encodeForceComputation(in commandBuffer: MTLCommandBuffer) {
        let buffers = [
            boidState.positionBuffer,
            boidState.accelerationBuffer,
            boidState.velocityBuffer,
            boidState.interactionCountBuffer,
            boidState.interactionVisualizationBuffer,
            boidState.configurationBuffer,
            computeConfiguration.forceMatrix,
        ]

        let bytes: [Any] = [
            UInt(boidState.boidCount),
            UInt(boidState.forceCount),
            UInt(boidState.teamCount),
            configuration.visualisationBoidID,
            configuration.compressionFactor
        ]

        commandBuffer.encode(forcePipelineState, buffers, bytes, label: "Force computation", boidCount: boidState.boidCount)
    }
    
    func encodeTickComputation(in commandBuffer: MTLCommandBuffer, frameDuration: TimeInterval, boundsSize: (Float, Float)) {
        timeIndex += 1
        let touching = self.touchLocation != nil
        let touchLocation = self.touchLocation ?? (0, 0)

        let buffers = [
            boidState.positionBuffer,
            boidState.accelerationBuffer,
            boidState.velocityBuffer,
            boidState.summedAccelerationBuffer,
            boidState.configurationBuffer
        ]
        
        let bytes: [Any] = [
            UInt(boidState.boidCount),
            UInt(boidState.forceCount),
            UInt(boidState.teamCount),
            Float(frameDuration) * configuration.simulationSpeed,
            boundsSize,
            touching,
            touchLocation,
            configuration.touchRadius,
            configuration.touchStrength,
            timeIndex
        ]
        
        commandBuffer.encode(tickPipelineState, buffers, bytes, label: "Velocity tick computation", boidCount: boidState.boidCount)
    }
    
    func encodeGeometryComputation(in commandBuffer: MTLCommandBuffer) {
        let buffers = [
            vertexBuffer,
            boidState.positionBuffer,
            boidState.velocityBuffer,
            boidState.summedAccelerationBuffer,
            boidState.configurationBuffer,
            boidState.interactionVisualizationBuffer,
            interactionVertexBuffer
        ]
        
        let bytes: [Any] = [
            UInt(boidState.boidCount),
            configuration.visualisationBoidID,
            configuration.visualisationBitmask
        ]
        
        commandBuffer.encode(geometryPipelineState, buffers, bytes, label: "Geometry computation", boidCount: boidState.boidCount)

        waveController.encode(in: commandBuffer)
    }
    
    func encodeRenderPass(in commandBuffer: MTLCommandBuffer, renderPassDescriptor: MTLRenderPassDescriptor, transformationUniforms: TransformationUniforms) {
        var transformationUniforms = transformationUniforms
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        // Wave render pass
        waveController.encodeRenderPass(in: commandBuffer, encoder: encoder, transformationUniforms: transformationUniforms)
        
        // Interaction line render pass
        if (configuration.visualiseForces) {
            encoder.setRenderPipelineState(interactionRenderPipelineState)
            encoder.setVertexBuffer(interactionVertexBuffer, offset: 0, index: 0)
            encoder.setVertexBytes(&transformationUniforms, length: 16 * 2 * MemoryLayout<Float>.stride, index: 1)
            encoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: boidState.boidCount * 2, instanceCount: 1)
        }
        
        // Boid render pass (per team)
        let boidVertexCount = 2 * 3
        _ = boidState.teams.reduce(0, { (start, team) in
            let renderPipelineState = self.renderPipelineStates[team.coloration]!
            
            encoder.setRenderPipelineState(renderPipelineState)
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            encoder.setVertexBytes(&transformationUniforms, length: 16 * 2 * MemoryLayout<Float>.stride, index: 1)
            encoder.setFragmentTexture(boidTexture, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: start, vertexCount: boidVertexCount * team.boidCount, instanceCount: 1)
            
            return start + (boidVertexCount * team.boidCount)
        })
        
        encoder.endEncoding()
    }
}

extension PipelineController {
    convenience init?(interaction: InteractionConfiguration, device: MTLDevice) {
        guard let boidState = interaction.createBoidState(on: device),
            let computeConfiguration = interaction.createComputeConfiguration(on: device)
        else {
            return nil
        }
        
        self.init(computeConfiguration: computeConfiguration, boidState: boidState, device: device)
    }
}
