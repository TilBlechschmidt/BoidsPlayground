//
//  Vertex.metal
//  Boidtastic
//
//  Created by Til Blechschmidt on 05.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

#include <metal_stdlib>
#include "Structs.metal"
#include "Helpers.metal"

using namespace metal;

vertex BoidVertexOut boid_vertex(
    const device BoidVertexIn* vertex_array [[ buffer(0) ]],
    const device GPUTransformationUniforms &transformations [[ buffer(1) ]],
    unsigned int vid [[ vertex_id ]]
) {
    BoidVertexOut out;

    out.team = vertex_array[vid].team;
    out.position = transformations.projectionMatrix * transformations.worldModelMatrix * float4(vertex_array[vid].position, 1);
    out.velocity = float3(vertex_array[vid].velocity);
    out.acceleration = float3(vertex_array[vid].acceleration);
    out.textureCoordinate = vertex_array[vid].textureCoordinate;

    return out;
}

vertex InteractionVertexOut interaction_vertex(
    const device packed_float3* vertex_array [[ buffer(0) ]],
    const device GPUTransformationUniforms &transformations [[ buffer(1) ]],
    unsigned int vid [[ vertex_id ]]
) {
    InteractionVertexOut out;
    
    out.position = transformations.projectionMatrix * transformations.worldModelMatrix * float4(vertex_array[vid], 1);
    
    return out;
}

vertex float4 water_vertex(const device LineSegmentVertex* segments [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    return float4(segments[vid].position, 1);
}

vertex BuoyVertexOut buoy_vertex(
    const device GPUTransformationUniforms &transformations [[ buffer(0) ]],
    const device BuoyVertexIn* vertices [[ buffer(1) ]],
    const device LineSegmentVertex* segments [[ buffer(2) ]],
    const device uint32_t &segment_index [[ buffer(3) ]],
    unsigned int vid [[ vertex_id ]]
) {
    BuoyVertexOut out;

    float2 offset = segments[segment_index * 2].position;
    float2 nextOffset = segments[(segment_index + 1) * 2].position;
    float3 surfaceVector = float3(offset - nextOffset, 0);
    float normalAngle = heading(surfaceVector) - M_PI_2_H;

    float3 position = rotate(float3(vertices[vid].position, 0), normalAngle);
    
    out.position = transformations.projectionMatrix * transformations.worldModelMatrix * float4(position, 1);
    out.textureCoordinate = vertices[vid].textureCoordinate;

    out.position.x += offset.x;
    out.position.y += offset.y;

    return out;
}
