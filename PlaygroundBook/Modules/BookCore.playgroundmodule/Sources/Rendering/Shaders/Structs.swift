//
//  Structs.swift
//  Boidtastic
//
//  Created by Til Blechschmidt on 13.02.20.
//  Copyright © 2020 Til Blechschmidt. All rights reserved.
//

import Foundation
import simd

struct BoidVertexIn {
    let team: Int32
    let position: (Float, Float, Float)
    let velocity: (Float, Float, Float)
    let acceleration: (Float, Float, Float)
    let textureCoordinate: (Float, Float)
    
    static var zero: BoidVertexIn {
        return BoidVertexIn(team: 0, position: (0, 0, 0), velocity: (0, 0, 0), acceleration: (0, 0, 0), textureCoordinate: (0, 0))
    }
}

struct WaveVertexIn {
    let position: (Float, Float)
    let index: Int32
}

struct TransformationUniforms {
    let projectionMatrix: float4x4
    let worldModelMatrix: float4x4
}

struct LineSegmentVertex {
    let position: (Float, Float)
}

struct BuoyVertexIn {
    let position: (Float, Float)
    let textureCoordinate: (Float, Float)
};
