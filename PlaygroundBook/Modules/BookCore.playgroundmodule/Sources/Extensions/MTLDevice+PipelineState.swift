//
//  MTLDevice+PipelineState.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 05.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

import Foundation
import Metal

extension MTLDevice {
    func makeComputePipelineState(functionName name: String) -> MTLComputePipelineState? {
        guard let library = makeDefaultLibrary(), let function = library.makeFunction(name: name), let state = try? makeComputePipelineState(function: function) else {
            return nil
        }
        
        return state
    }

    func makeRenderPipelineDescriptor(vertexFunctionName: String, fragmentFunctionName: String) -> MTLRenderPipelineDescriptor? {

        guard
            let libraryURL = Bundle.main.url(forResource: "default", withExtension: ".metallib"),
            let library = try? makeLibrary(URL: libraryURL),
            let vertexFunction = library.makeFunction(name: vertexFunctionName),
            let fragmentFunction = library.makeFunction(name: fragmentFunctionName)
        else {
            return nil
        }

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        return pipelineStateDescriptor
    }
    
    func makeRenderPipelineState(vertexFunctionName: String, fragmentFunctionName: String) -> MTLRenderPipelineState? {
        guard let pipelineDescriptor = makeRenderPipelineDescriptor(vertexFunctionName: vertexFunctionName, fragmentFunctionName: fragmentFunctionName) else {
            return nil
        }

        return try? makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}
