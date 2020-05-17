//
//  WaveController.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 06.05.20.
//  Copyright © 2020 Til Blechschmidt. All rights reserved.
//

import Foundation
import Metal
import MetalKit

class WaveController {
    private let device: MTLDevice

    private var wavesParameterBuffer: MTLBuffer!
    private var waterVertexBuffer: MTLBuffer!
    private var buoyVertexBuffer: MTLBuffer!

    private var wavePipelineState: MTLComputePipelineState!
    private var waterRenderPipelineState: MTLRenderPipelineState!
    private var buoyRenderPipelineState: MTLRenderPipelineState!

    private let segmentCount = 4_000
    private let numberOfWaves = 7
    private var waveOffset: Float = 0
    private let waveTimestep: Float = 0.004
    private var buoySegment: UInt32 = 500

    private var buoyTexture: MTLTexture!

    private func generateSteepnesses(forWaveCount waveCount: Int) -> [Float] {
        var budget: Float = 1
        return (0..<Int(waveCount-1)).reduce(into: []) { acc, _ in
            let allocated = Float.random(in: 0.0..<(budget/2))
            budget -= allocated

            acc.append(allocated)
        } + [budget]
    }

    private func initWavePipeline() {
        let offsets = (0..<numberOfWaves).map { _ in Float.random(in: -1...1) }
        let steepness = generateSteepnesses(forWaveCount: numberOfWaves)
        let wavelengths = (0..<numberOfWaves).map { _ in Float.random(in: 0.1...0.5) }

        let wavesParameterArray = offsets + steepness + wavelengths

        wavesParameterBuffer = device.makeBuffer(bytes: wavesParameterArray, length: wavesParameterArray.count * MemoryLayout<Float>.stride, options: [])!
        waterVertexBuffer = device.makeBuffer(length: segmentCount * 2 * MemoryLayout<LineSegmentVertex>.stride, options: [])!

        wavePipelineState = device.makeComputePipelineState(functionName: "generate_segments")!
        waterRenderPipelineState = device.makeRenderPipelineState(vertexFunctionName: "water_vertex", fragmentFunctionName: "water_fragment")!
    }

    private func initBuoyPipeline(textureLoader: MTKTextureLoader) {
        self.buoyTexture = try! textureLoader.newTexture(name: "buoy", scaleFactor: 1.0, bundle: .main, options: [.origin: MTKTextureLoader.Origin.flippedVertically])

        let buoyHeight: Float = 3.0
        let buoyWidth = buoyHeight / 2167.0 * 837.0
        let yOffset = buoyHeight / 4

        let vertices = [
            // Top left
            BuoyVertexIn(position: (-buoyWidth / 2,  buoyHeight / 2 + yOffset), textureCoordinate: (0, 1)),
            // Bottom left
            BuoyVertexIn(position: (-buoyWidth / 2, -buoyHeight / 2 + yOffset), textureCoordinate: (0, 0)),
            // Top right
            BuoyVertexIn(position: ( buoyWidth / 2,  buoyHeight / 2 + yOffset), textureCoordinate: (1, 1)),
            // Bottom right
            BuoyVertexIn(position: ( buoyWidth / 2, -buoyHeight / 2 + yOffset), textureCoordinate: (1, 0))
        ]

        buoyVertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<BuoyVertexIn>.stride * vertices.count, options: [])!

        buoyRenderPipelineState = device.makeRenderPipelineState(vertexFunctionName: "buoy_vertex", fragmentFunctionName: "buoy_fragment")!
    }

    init(device: MTLDevice, textureLoader: MTKTextureLoader) {
        self.device = device

        initBuoyPipeline(textureLoader: textureLoader)
        initWavePipeline()
    }

    func encode(in commandBuffer: MTLCommandBuffer) {
        waveOffset += waveTimestep

        commandBuffer.encode(wavePipelineState, [waterVertexBuffer, wavesParameterBuffer], [UInt32(numberOfWaves), waveOffset, UInt32(segmentCount)], label: "Wave generation", boidCount: segmentCount)
    }

    func encodeRenderPass(in commandBuffer: MTLCommandBuffer, encoder: MTLRenderCommandEncoder, transformationUniforms: TransformationUniforms) {
        var transformationUniforms = transformationUniforms

        encoder.setRenderPipelineState(waterRenderPipelineState)
        encoder.setVertexBuffer(waterVertexBuffer, offset: 0, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: segmentCount * 2, instanceCount: 1)

        encoder.setRenderPipelineState(buoyRenderPipelineState)
        encoder.setVertexBytes(&transformationUniforms, length: 16 * 2 * MemoryLayout<Float>.stride, index: 0)
        encoder.setVertexBuffer(buoyVertexBuffer, offset: 0, index: 1)
        encoder.setVertexBuffer(waterVertexBuffer, offset: 0, index: 2)
        encoder.setVertexBytes(&buoySegment, length: MemoryLayout<UInt32>.stride, index: 3)
        encoder.setFragmentTexture(buoyTexture, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
    }
}
