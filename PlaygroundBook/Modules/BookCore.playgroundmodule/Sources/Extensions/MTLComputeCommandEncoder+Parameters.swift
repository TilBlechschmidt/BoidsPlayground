//
//  MTLComputeCommandEncoder+Parameters.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 13.02.20.
//  Copyright © 2020 Til Blechschmidt. All rights reserved.
//

import Foundation
import Metal

extension MTLComputeCommandEncoder {
    func dispatch(for pipelineState: MTLComputePipelineState, boidCount: Int) {
//        let (threadsPerGrid, threadsPerThreadgroup) = device.gridParameters(for: pipelineState, sideLength: Int(ceil(sqrt(Float(boidCount)))))
//        dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

        let w = pipelineState.threadExecutionWidth
        let h = pipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1) 

        let sideLength = Int(ceil(sqrt(Float(boidCount))))
        let threadgroupsPerGrid = MTLSize(
            width: (sideLength + w - 1) / w,
            height: (sideLength + h - 1) / h,
            depth: 1)

        dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }

    func setParameters<T>(_ buffers: [MTLBuffer?], _ bytes: [T], offsets: [Int]? = nil) {
        setBuffers(buffers, offsets: offsets)
        setBytes(values: bytes, startingAtIndex: buffers.count)
    }
    
    func setBuffers(_ buffers: [MTLBuffer?], startingAtIndex startIndex: Int = 0, offsets: [Int]? = nil) {
        setBuffers(buffers, offsets: offsets ?? Array(repeating: 0, count: buffers.count), range: startIndex..<(startIndex + buffers.count))
    }
    
    func setBytes<T>(values: [T], startingAtIndex startIndex: Int = 0) {
        zip(values, startIndex..<(startIndex + values.count)).forEach {
            var (value, index) = $0
            setBytes(&value, index: index)
        }
    }
    
    func setBytes<T>(_ value: inout T, index: Int) {
        setBytes(&value, length: MemoryLayout.size(ofValue: value), index: index)
    }
}
