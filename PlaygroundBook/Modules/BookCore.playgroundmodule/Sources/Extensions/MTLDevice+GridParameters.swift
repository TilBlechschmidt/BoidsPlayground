//
//  MTLDevice+GridParameters.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 05.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

import Foundation
import Metal

extension MTLDevice {
    func gridParameters(for pipelineState: MTLComputePipelineState, sideLength: Int) -> (threadsPerGrid: MTLSize, threadsPerThreadgroup: MTLSize) {
        let w = pipelineState.threadExecutionWidth
        let h = pipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)

        let threadsPerGrid = MTLSize(width: sideLength,
                                     height: sideLength,
                                     depth: 1)

        return (threadsPerGrid: threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }
}
