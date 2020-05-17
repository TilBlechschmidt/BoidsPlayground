//
//  Waves.metal
//  Boidtastic
//
//  Created by Til Blechschmidt on 06.05.20.
//  Copyright © 2020 Til Blechschmidt. All rights reserved.
//

#include <metal_stdlib>
#include "Structs.metal"
#include "Helpers.metal"

using namespace metal;

// https://catlikecoding.com/unity/tutorials/flow/waves/
kernel void generate_segments(
    device LineSegmentVertex* segments [[ buffer(0) ]],
    const device float* parameter_array [[ buffer(1) ]],
    const device uint32_t &numberOfWaves [[ buffer(2) ]],
    const device float &offset [[ buffer(3) ]],
    const device uint32_t &segment_count [[ buffer(4) ]],

    uint2 gid [[thread_position_in_grid]],
    uint2 grid_dimensions [[threads_per_grid]]
) {
    uint tid = thread_id(gid, grid_dimensions);
    if (tid >= segment_count) return;
    float index = ((float) tid) / ((float) segment_count);

    // Slightly more since the edge points might shift into the screen boundary
    float screen_width = 2.2;
    float2 position = { -(screen_width / 2) + index * screen_width, 0.75 };

    const device float* offsets = parameter_array;
    const device float* steepnesses = parameter_array + numberOfWaves;
    const device float* wavelengths = steepnesses + numberOfWaves;

    for (uint32_t i = 0; i < numberOfWaves; i++) {
        float time = offsets[i] * offset;
        float steepness = steepnesses[i];
        float wavelength = wavelengths[i];
        float k = 2 * M_PI_F / wavelength;
        float c = sqrt(9.8 / k);
        float f = k * (position.x - c * time);
        float a = steepness / k;

        position.x += a * cos(f);
        position.y += a * sin(f);
    }

    segments[tid * 2] = { position };
    segments[tid * 2 + 1] = { float2(position.x, -1) };
}
