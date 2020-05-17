//
//  Geometry.metal
//  Boidtastic
//
//  Created by Til Blechschmidt on 05.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

#include <metal_stdlib>
#include "Structs.metal"
#include "Helpers.metal"

using namespace metal;

kernel void boid_to_triangles(
    device BoidVertexIn* vertex_array [[ buffer(0) ]],
    const device packed_float3* position_array [[ buffer(1) ]],
    const device packed_float3* velocity_array [[ buffer(2) ]],
    const device packed_float3* summed_acceleration_array [[ buffer(3) ]],
    const device GPUBoidConfiguration* configurations [[ buffer(4) ]],
    const device uint8_t* interaction_visualization_array [[ buffer(5) ]],
    device packed_float3* interaction_vertex_array [[ buffer(6) ]],
    const device uint &boid_count [[ buffer(7) ]],
    const device uint &interaction_boid_index [[ buffer(8) ]],
    const device uint8_t &interaction_bitmask [[ buffer(9) ]],
    uint2 gid [[thread_position_in_grid]],
    uint2 grid_dimensions [[threads_per_grid]]
) {
    uint index = thread_id(gid, grid_dimensions);
    if (index >= boid_count) return;
    
    float3 position = position_array[index];
    float3 velocity = velocity_array[index];
    float3 acceleration = summed_acceleration_array[index];

    // MARK: - Boid vertices
    GPUBoidConfiguration configuration = configurations[index];
    int32_t team = configuration.team;
    float size = configuration.size;
    
    float halfHeight = size / 2;
    float halfWidth = size / 4;
    float3 topLeft      = float3(-halfWidth,  halfHeight, 0);
    float3 topRight     = float3( halfWidth,  halfHeight, 0);
    float3 bottomLeft   = float3(-halfWidth, -halfHeight, 0);
    float3 bottomRight 	= float3( halfWidth, -halfHeight, 0);

    float boidHeading = heading(velocity);

    uint output_index = index * 2 * 3;

    // TBR Triangle
    vertex_array[output_index    ] = { team, position + rotate(topLeft, boidHeading), velocity, acceleration, {0, 1} };
    vertex_array[output_index + 1] = { team, position + rotate(bottomLeft, boidHeading), velocity, acceleration, {0, 0} };
    vertex_array[output_index + 2] = { team, position + rotate(bottomRight, boidHeading), velocity, acceleration, {1, 0} };
    // BTL Triangle
    vertex_array[output_index + 3] = { team, position + rotate(bottomRight, boidHeading), velocity, acceleration, {1, 0} };
    vertex_array[output_index + 4] = { team, position + rotate(topRight, boidHeading), velocity, acceleration, {1, 1} };
    vertex_array[output_index + 5] = { team, position + rotate(topLeft, boidHeading), velocity, acceleration, {0, 1} };
    
    // MARK: - Interaction vertices
    uint interaction_index = index * 2;
    if (interaction_visualization_array[index] & interaction_bitmask) { // TODO Add selection which forces to visualize with & bitmask
        interaction_vertex_array[interaction_index    ] = position;
        interaction_vertex_array[interaction_index + 1] = position_array[interaction_boid_index];
    } else {
        interaction_vertex_array[interaction_index    ] = float3(0, 0, 0);
        interaction_vertex_array[interaction_index + 1] = float3(0, 0, 0);
    }
}
