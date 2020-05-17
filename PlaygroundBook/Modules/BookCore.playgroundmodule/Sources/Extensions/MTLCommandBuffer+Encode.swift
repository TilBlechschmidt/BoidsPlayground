//
//  MTLCommandBuffer+Encode.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 13.02.20.
//  Copyright © 2020 Til Blechschmidt. All rights reserved.
//

import Foundation
import Metal

extension MTLCommandBuffer {
    func encode<T>(_ pipelineState: MTLComputePipelineState, _ buffers: [MTLBuffer?], _ bytes: [T], label: String?, boidCount: Int, bufferOffsets: [Int]? = nil) {
        let encoder = makeComputeCommandEncoder()!
        
        if let label = label {
            encoder.label = label
        }
        
        encoder.setComputePipelineState(pipelineState)
        encoder.setParameters(buffers, bytes, offsets: bufferOffsets)

        encoder.dispatch(for: pipelineState, boidCount: boidCount)
        encoder.endEncoding()
    }
}
