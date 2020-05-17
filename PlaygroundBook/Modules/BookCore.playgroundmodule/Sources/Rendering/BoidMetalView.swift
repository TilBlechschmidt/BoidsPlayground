//
//  BoidMetalView.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 05.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

import MetalKit
import simd

class BoidMetalView: MTKView {
    private let recognizer = DragGestureRecognizer()

    private var pipelineController: PipelineController!
    private let commandQueue: MTLCommandQueue
    private var transformationUniforms: TransformationUniforms!

    private var previousDraw = Date()
    private var frameIndex: UInt32 = 0
    private var metricSize: (Float, Float) = (0, 0)

    private var simulationConfig: SimulationConfiguration! {
        didSet {
            pipelineController.configuration = simulationConfig
            mtkView(self, drawableSizeWillChange: drawableSize)
        }
    }

    private var interactionConfig: InteractionConfiguration! {
        didSet {
            NSLog(String(describing: oldValue.hashValue))
            NSLog(String(describing: interactionConfig.hashValue))

            if oldValue != interactionConfig {
                pipelineController = PipelineController(interaction: interactionConfig, device: device!)!
                pipelineController.configuration = simulationConfig
            } else {
                NSLog("Not updating config!")
            }
        }
    }

    init(_ simulation: SimulationConfiguration = SimulationConfiguration(), _ interaction: InteractionConfiguration = InteractionConfiguration.example) {
        let device = MTLCreateSystemDefaultDevice()!

        simulationConfig = simulation
        interactionConfig = interaction

        commandQueue = device.makeCommandQueue()!
        pipelineController = PipelineController(interaction: interaction, device: device)!
        pipelineController.configuration = simulation

        super.init(frame: .zero, device: device)
        
        self.delegate = self
        self.clearColor = MTLClearColor(
            red: 0.42,
            green: 0.72,
            blue: 0.74,
            alpha: 1.0
        )

        recognizer.touchDelegate = self
        self.addGestureRecognizer(recognizer)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func push(configuration: SimulationConfiguration) {
        simulationConfig = configuration
    }

    public func push(interaction: InteractionConfiguration) {
        interactionConfig = interaction
    }
}

extension BoidMetalView: MTKViewDelegate {
    // TODO This is 2D only, adjust to enable 3D
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let metersPerPixel: Float = pipelineController.configuration.metersPerPixel
        // TODO This is a parameter
        let boundsInset: Float = 0 // 25 // 15
        // TODO Make the inset relative (percentage) to real world screen "size"
        
        metricSize = (Float(size.width) * metersPerPixel - boundsInset, Float(size.height) * metersPerPixel - boundsInset)
        
        var projectionMatrix = float4x4.identity
        
        // Convert from metric coordinate space into pixel coordinate space
        projectionMatrix.scale(1 / metersPerPixel, y: 1 / metersPerPixel, z: 1)
        
        // Convert from pixel coordinate space into NDC space
        projectionMatrix.scale(Float(2 / size.width), y: Float(2 / size.height), z: 1)
        
        transformationUniforms = TransformationUniforms(
            projectionMatrix: projectionMatrix,
            worldModelMatrix: float4x4.identity
        )
    }

    func draw(in view: MTKView) {
        frameIndex += 1

        guard let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let drawable = view.currentDrawable,
            let transformationUniforms = transformationUniforms
        else {
            return
        }
        
        let timeDelta = -previousDraw.timeIntervalSinceNow * 0.1
        previousDraw = Date()

        pipelineController.encodeForceComputation(in: commandBuffer)
        pipelineController.encodeTickComputation(in: commandBuffer, frameDuration: timeDelta, boundsSize: metricSize)
        pipelineController.encodeGeometryComputation(in: commandBuffer)
        pipelineController.encodeRenderPass(in: commandBuffer, renderPassDescriptor: renderPassDescriptor, transformationUniforms: transformationUniforms)

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension BoidMetalView: DragGestureRecognizerDelegate {
    func dragGestureRecognizer(_ gestureRecognizer: DragGestureRecognizer, didUpdateTouches touches: [CGPoint]) {
        if let touch = touches.first {
            // Convert from NDC space to metric coordinate space
            let x = Float(touch.x) * (metricSize.0 / 2)
            let y = Float(touch.y) * (metricSize.1 / 2)
            pipelineController.touchLocation = (x, y)
        } else {
            pipelineController.touchLocation = nil
        }
    }
}
