//
//  Structs.metal
//  Boidtastic
//
//  Created by Til Blechschmidt on 05.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct BoidVertexIn {
    int32_t team;
    packed_float3 position;
    packed_float3 velocity;
    packed_float3 acceleration;
    packed_float2 textureCoordinate;
};

struct WaveVertexIn {
    packed_float2 position;
    int32_t index;
};

struct BoidVertexOut {
    int32_t team;
    float4 position [[position]];
    float3 velocity;
    float3 acceleration;
    float2 textureCoordinate;
};

struct InteractionVertexOut {
    float4 position [[position]];
};

struct WaveVertexOut {
    float4 position [[position]];
    float2 waveCoordinate;
    int32_t index;
};

struct GPUBoidConfiguration {
    int32_t team;
    float size;
    float maximumVelocity;
};

struct GPUForceConfiguration {
    float strength;
    float radius;
    float speedLimit;
    float falloff;
    float fieldOfView;
    bool scaleWithPeers;
};

struct GPUTransformationUniforms {
    float4x4 projectionMatrix;
    float4x4 worldModelMatrix;
};

struct LineSegmentVertex {
    packed_float2 position;
};

struct BuoyVertexIn {
    packed_float2 position;
    packed_float2 textureCoordinate;
};

struct BuoyVertexOut {
    float4 position [[position]];
    float2 textureCoordinate;
};
