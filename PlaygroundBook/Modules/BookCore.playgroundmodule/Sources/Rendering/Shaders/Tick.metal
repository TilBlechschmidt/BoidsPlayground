//
//  Tick.metal
//  Boidtastic
//
//  Created by Til Blechschmidt on 06.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

#include <metal_stdlib>
#include "Structs.metal"
#include "Helpers.metal"

using namespace metal;

kernel void boid_tick(
    device packed_float3* position_array [[ buffer(0) ]],
    const device packed_float3* acceleration_matrix [[ buffer(1) ]],
    device packed_float3* velocity_array [[ buffer(2) ]],
    device packed_float3* summed_acceleration_array [[ buffer(3) ]],
    const device GPUBoidConfiguration* configurations [[ buffer(4) ]],
    const device uint &boid_count [[ buffer(5) ]],
    const device uint &force_count [[ buffer(6) ]],
    const device uint &team_count [[ buffer(7) ]],
    const device float &tick_duration [[ buffer(8) ]],
    const device packed_float2 &bounds_size [[ buffer(9) ]],
    const device bool &touching [[ buffer(10) ]],
    const device packed_float2 &touchLocation [[ buffer(11) ]],
    const device float &touch_radius [[ buffer(12) ]],
    const device float &touch_strength [[ buffer(13) ]],
    const device uint32_t &time_index [[ buffer(14) ]],
    uint2 gid [[thread_position_in_grid]],
    uint2 grid_dimensions [[threads_per_grid]]
) {
    uint boid_index = thread_id(gid, grid_dimensions);
    if (boid_index >= boid_count) return;
    
    bool two_dimensional = true;

    GPUBoidConfiguration configuration = configurations[boid_index];
    float3 position = position_array[boid_index];
    float3 velocity = velocity_array[boid_index];
    float3 acceleration = float3(0, 0, 0);
    
    // Calculate the overall acceleration
    for (uint team_index = 0; team_index < team_count; team_index++) {
        for (uint force_index = 0; force_index < force_count; force_index++) {
            uint index = velocity_index(boid_count, team_count, force_count, boid_index, team_index, force_index);
            acceleration += acceleration_matrix[index];
        }
    }

    // Calculate interaction independent acceleration components
    // TODO Implement different bounds per team or obstacles/walls
//    float2 boundsSize = configuration.team == 0 ? bounds_size * 0.175 : bounds_size;
//    float2 boundsSize = bounds_size * 0.5;
//    float out_of_bounds_x = max(0.0, -((boundsSize.x / 2) - abs(position.x)));
//    float out_of_bounds_y = max(0.0, -((boundsSize.y / 2) - abs(position.y)));
//    float out_of_bounds_val = max(out_of_bounds_x, out_of_bounds_y);
//    if (out_of_bounds_val > 0) {
//        float out_of_bounds_percentage = min(1.0, out_of_bounds_val / 10);
//        acceleration += normalize(-position) * tan(out_of_bounds_percentage * 1.5);
//    }

    // Add some random movement if the boid would stay still
    if (vector_is_null(acceleration)) {
        uint seed = time_index * gid.x + configuration.team;
        acceleration.x += (random_float(seed) * 2 - 1) * 2;
        acceleration.y += (random_float(seed + 1) * 2 - 1) * 2;
    }

    // Apply the acceleration to the velocity
    if (two_dimensional) acceleration.z = 0;
    velocity += acceleration;
    
    // Store the acceleration for later use
    summed_acceleration_array[boid_index] = acceleration;
    
    if (vector_is_not_null(velocity)) {
        float velocity_value = length(velocity);
        // TODO Add some wave function with random offsets to the maximum velocity for more variation
        if (velocity_value > configuration.maximumVelocity) {
            velocity = normalize(velocity) * configuration.maximumVelocity;
        }
    }

    // Add an acceleration towards the touch location
    if (touching) {
        float3 direction_vector = float3(touchLocation, 0) - position;
        float dist = length(direction_vector);

        if (dist < touch_radius) {
            float dist_percentage = min(1.0, dist / touch_radius);
            velocity += (direction_vector / dist) * (1 - dist_percentage) * touch_strength;
        }
    }

    // Collision avoidance based on ray casting
    // ---------

    float bx_h = bounds_size.x / 2;
    float by_h = bounds_size.y / 2;

    int line_segment_count = 8;
    float2 line_segments[8] = {
        // Left wall
        float2(-bx_h, -by_h),
        float2(-bx_h,  by_h),

        // Bottom wall
        float2(-bx_h, -by_h),
        float2( bx_h, -by_h),

        // Right wall
        float2( bx_h,  by_h),
        float2( bx_h, -by_h),

        // Water surface
        float2( bx_h, by_h * 0.7),
        float2(-bx_h, by_h * 0.7),
    };

    float startAngle = heading(velocity) + M_PI_2_H;
    if (isnan(startAngle)) startAngle = 0;

    uint32_t ray_count = 32;
    uint32_t check_rays = 6;

    float2 ray_src = float2(position.x, position.y);

    // Check if the path is obstructed
    bool path_obstructed = false;
    for (uint32_t index = 0; index < check_rays; index++) {
        float2 ray_dst = collision_ray_position(ray_src, startAngle, index, ray_count, 1);

        for (int i = 0; i < (line_segment_count / 2); i++) {
            float2 segment_src = line_segments[i * 2];
            float2 segment_dst = line_segments[i * 2 + 1];
            path_obstructed = doIntersect(ray_src, ray_dst, segment_src, segment_dst);

            if (path_obstructed) break;
        }

        if (path_obstructed) break;
    }


    // Find a clear path if it is obstructed
    float3 clear_path = -position;
    if (path_obstructed) {
        for (uint32_t index = 0; index < ray_count; index++) {
            float2 ray_dst = collision_ray_position(ray_src, startAngle, index, ray_count, 2);

            bool is_obstructed = false;
            for (int i = 0; i < (line_segment_count / 2); i++) {
                float2 segment_src = line_segments[i * 2];
                float2 segment_dst = line_segments[i * 2 + 1];
                is_obstructed = is_obstructed || doIntersect(ray_src, ray_dst, segment_src, segment_dst);
            }

            if (!is_obstructed) {
                clear_path = float3(ray_dst - ray_src, 0);
                break;
            }
        }
    }

    if (path_obstructed) {
        float speed = length(velocity);
        velocity = normalize(clear_path) * speed;
    }

    // ---------

    // Apply the velocity to the position
    position += velocity * tick_duration;

    // Bounds check and teleport back to center if it has somehow escaped
    bool out_of_bounds_x = position.x > bx_h || position.x < -bx_h;
    bool out_of_bounds_y = position.y > by_h * 0.7 || position.y < -by_h;

    if (out_of_bounds_x || out_of_bounds_y) {
        position = { 0, 0, 0 };
    }

    // Write all data out
    velocity_array[boid_index] = velocity;
    position_array[boid_index] = position;
}
