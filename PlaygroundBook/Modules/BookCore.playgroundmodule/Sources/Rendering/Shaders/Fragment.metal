//
//  Fragment.metal
//  Boidtastic
//
//  Created by Til Blechschmidt on 05.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

#include <metal_stdlib>
#include "Structs.metal"
#include "Helpers.metal"

using namespace metal;

fragment half4 boid_fragment_acceleration(BoidVertexOut in [[stage_in]], texture2d<half> mask [[ texture(0) ]]) {
    process_mask(mask, in.textureCoordinate);

    float percentage = length(in.acceleration) / 20.0;
    float capped = 1 - max(0.0, min(1.0, percentage));

    return base_color(in.team) * capped;
}

fragment half4 boid_fragment_heading(BoidVertexOut in [[stage_in]], texture2d<half> mask [[ texture(0) ]]) {
    process_mask(mask, in.textureCoordinate);
    
    float heading = 0;
    if (vector_is_not_null(in.velocity)) {
        heading = angle(in.velocity) - M_PI_2_H;
    } else {
        heading = 0;
    }

    heading *= 180 / M_PI_H;

    while (heading < 0) heading += 360;

    return half4(hsvToRGB(heading, 0.7, 1), 0);
}

fragment half4 boid_fragment_angleOfAttack(BoidVertexOut in [[stage_in]], texture2d<half> mask [[ texture(0) ]]) {
    process_mask(mask, in.textureCoordinate);
    
    return base_color(in.team) * angleOfAttack(in.velocity, in.acceleration);
}

fragment half4 boid_fragment_color(BoidVertexOut in [[stage_in]], texture2d<half> mask [[ texture(0) ]]) {
    process_mask(mask, in.textureCoordinate);
    
    return base_color(in.team);
}

fragment half4 interaction_fragment(InteractionVertexOut in [[stage_in]]) {
    return half4(hsvToRGB(16, 0.92, 0.75), 1.0);
}

fragment half4 water_fragment(float4 in [[stage_in]]) {
    return half4(0.22, 0.50, 0.56, 1);
}

fragment half4 buoy_fragment(BuoyVertexOut in [[stage_in]], texture2d<half> texture [[ texture(0) ]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);

    const half4 sample = texture.sample(textureSampler, in.textureCoordinate);

    if (sample[3] == 0) discard_fragment();

    return sample;
}
