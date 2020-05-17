//
//  Force.metal
//  Boidtastic
//
//  Created by Til Blechschmidt on 06.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

#include <metal_stdlib>
#include "Structs.metal"
#include "Helpers.metal"

using namespace metal;

inline uint force_matrix_index(uint team_count, uint team1_index, uint team2_index, uint force_index) {
    uint team_matrix_length = team_count * team_count;
    uint team_matrix_start_index = team_matrix_length * force_index;
    
    uint row = team1_index;
    uint column = team2_index;
    uint matrix_index = team_count * row + column;
    
    return team_matrix_start_index + matrix_index;
}

kernel void boid_force(
    const device packed_float3* position_array [[ buffer(0) ]],
    device packed_float3* acceleration_matrix [[ buffer(1) ]],
    const device packed_float3* velocity_array [[ buffer (2) ]],
    device uint32_t* interaction_count_matrix [[ buffer(3) ]],
    device uint8_t* interaction_visualization_array [[ buffer(4) ]],
    const device GPUBoidConfiguration* configurations [[ buffer(5) ]],
    const device GPUForceConfiguration* force_configuration_matrix [[ buffer(6) ]],
    const device uint &boid_count [[ buffer(7) ]],
    const device uint &force_count [[ buffer(8) ]],
    const device uint &team_count [[ buffer(9) ]],
    const device uint &interaction_boid_index [[ buffer(10) ]],
    const device float &compression_factor [[ buffer(11) ]],
    uint2 gid [[thread_position_in_grid]],
    uint2 grid_dimensions [[threads_per_grid]]
) {
    uint boid_index = thread_id(gid, grid_dimensions);
    if (boid_index >= boid_count) return;

    GPUBoidConfiguration configuration = configurations[boid_index];
    float3 position = position_array[boid_index];
    bool isSpecialBoid = boid_index == interaction_boid_index;
    
    // MARK: - Clear all intermediate buffers
    interaction_visualization_array[boid_index] = 0;
    // TODO Figure out if there is a way to create an intermediate buffer that only persist during the render pass.
    for (uint other_team = 0; other_team < team_count; other_team++) {
        for (uint force_index = 0; force_index < force_count; force_index++) {
            uint v_index = velocity_index(boid_count, team_count, force_count, boid_index, other_team, force_index);
            
            acceleration_matrix[v_index] = float3(0, 0, 0);
            interaction_count_matrix[v_index] = 0;
        }
    }
    
    // MARK: - Calculate the inter-boid forces
    threadgroup_barrier(mem_flags::mem_device);
    // TODO Start at `boid_index + 1` and calculate/apply force in reverse as well
    for (uint other_boid_index = 0; other_boid_index < boid_count; other_boid_index++) {
        GPUBoidConfiguration other_configuration = configurations[other_boid_index];
        float3 other_position = position_array[other_boid_index];
        float3 direction_vector = position - other_position;
        
        if (vector_is_null(direction_vector)) continue;
        
        float dist = length(direction_vector);
        
        for (uint force_index = 0; force_index < force_count; force_index++) {
            uint force_configuration_index = force_matrix_index(team_count, configuration.team, other_configuration.team, force_index);
            GPUForceConfiguration force_configuration = force_configuration_matrix[force_configuration_index];

            float radius_size_modifier = (configuration.size + other_configuration.size) * (1 - compression_factor);
            float radius = force_configuration.radius + radius_size_modifier;
            if (radius < dist) continue;
            float dist_percentage = max(0.0, 1.0 - dist / radius);
            
            if (force_configuration.fieldOfView < 1) {
                float aoa = angleOfAttack(float3(velocity_array[boid_index]), -direction_vector);
                if (aoa > force_configuration.fieldOfView) continue;
            }
            
            switch (force_index) {
                case 0: { // Separation
                    uint v_index = velocity_index(boid_count, team_count, force_count, boid_index, other_configuration.team, force_index);
                    float3 velocity = normalize(direction_vector) * force_configuration.strength * falloff(dist_percentage);

                    if (vector_is_not_null(velocity)) {
                        acceleration_matrix[v_index] += velocity;
                        interaction_count_matrix[v_index] += 1;
                    }
                    
                    if (isSpecialBoid) interaction_visualization_array[other_boid_index] |= 0b00000001;
                    
                    break;
                }
                case 1: { // Cohesion
                    uint v_index = velocity_index(boid_count, team_count, force_count, boid_index, other_configuration.team, force_index);
                    float3 velocity = normalize(-direction_vector) * force_configuration.strength * falloff(dist_percentage);
                    
                    if (vector_is_not_null(velocity)) {
                        acceleration_matrix[v_index] += velocity;
                        interaction_count_matrix[v_index] += 1;
                    }
                    
                    if (isSpecialBoid) interaction_visualization_array[other_boid_index] |= 0b00000010;
                    
                    break;
                }
                case 2: { // Alignment
                    uint v_index = velocity_index(boid_count, team_count, force_count, boid_index, other_configuration.team, force_index);

                    float3 other_velocity = velocity_array[other_boid_index];

                    if (vector_is_null(other_velocity)) continue;

                    float3 velocity = normalize(other_velocity) * force_configuration.strength * falloff(dist_percentage);

                    if (vector_is_not_null(velocity)) {
                        acceleration_matrix[v_index] += velocity;
                        interaction_count_matrix[v_index] += 1;
                    }
                    
                    if (isSpecialBoid) interaction_visualization_array[other_boid_index] |= 0b00000100;
                    
                    break;
                }
            }
        }
    }
    
    // MARK: - Average and limit velocities
    threadgroup_barrier(mem_flags::mem_device);
    for (uint other_team = 0; other_team < team_count; other_team++) {
        for (uint force_index = 0; force_index < force_count; force_index++) {
            uint v_index = velocity_index(boid_count, team_count, force_count, boid_index, other_team, force_index);
            uint force_configuration_index = force_matrix_index(team_count, configuration.team, other_team, force_index);
            GPUForceConfiguration configuration = force_configuration_matrix[force_configuration_index];
            float speedLimit = configuration.speedLimit;

            float3 acceleration = acceleration_matrix[v_index];
            uint32_t interaction_count = interaction_count_matrix[v_index];
            
            if (vector_is_null(acceleration)) continue;
            
            if (interaction_count > 0 && !configuration.scaleWithPeers) {
                acceleration = acceleration / interaction_count;
            }
            
            float velocity_value = length(acceleration);
            if (velocity_value > speedLimit) {
                acceleration = acceleration / velocity_value * speedLimit;
            }
            
            acceleration_matrix[v_index] = acceleration;
        }
    }
}
