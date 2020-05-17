//
//  Helpers.metal
//  Boidtastic
//
//  Created by Til Blechschmidt on 05.12.19.
//  Copyright © 2019 Til Blechschmidt. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

inline uint thread_id(uint2 gid, uint2 grid_dimensions) {
    return gid.y * grid_dimensions.x + gid.x;
}

inline uint velocity_index(uint boid_count, uint team_count, uint force_count, uint boid_index, uint team_index, uint force_index) {
    uint force_slice_size = 1;
    uint team_slice_size = force_count * force_slice_size;
    uint boid_slice_size = team_count * team_slice_size;
    
    return boid_slice_size * boid_index + team_slice_size * team_index + force_slice_size * force_index;
}

inline bool vector_is_not_null(float2 vector) {
    return (vector.x != 0 || vector.y != 0);
}

inline bool vector_is_not_null(float3 vector) {
    return (vector.x != 0 || vector.y != 0 || vector.z != 0);
}

inline bool vector_is_null(float3 vector) {
    return !vector_is_not_null(vector);
}

inline float falloff(float distancePercentage) {
    
    // random crafted curve
    return 0.5 + pow((distancePercentage - 0.44) * 1.8, 3);
    
    // cubic
//    return pow(distancePercentage, 3);
    
    // tan
//    float clampedPercentage = 1 - max(0.0, min(1.0, distancePercentage));
//    return 0.25 * (1 - tan(2 * clampedPercentage - 1.55) - 0.5169);
}

inline float angle(float3 ofVector) {
    return atan2(ofVector.y, ofVector.x);
}

inline float heading(float3 ofVector) {
    if (vector_is_not_null(ofVector)) {
        return angle(ofVector) - M_PI_2_H;
    } else {
        return 0;
    }
}

inline float2 rotate2d(float2 vector, float byAngle) {
    return float2(
        vector.x * cos(byAngle) - vector.y * sin(byAngle),
        vector.x * sin(byAngle) + vector.y * cos(byAngle)
    );
}

inline float3 rotate(float3 vector, float byAngle) {
    return float3(
        vector.x * cos(byAngle) - vector.y * sin(byAngle),
        vector.x * sin(byAngle) + vector.y * cos(byAngle),
        vector.z
    );
}

/// Returns angle between two vectors between 0 and 1
inline float angleOfAttack(float3 vector1, float3 vector2) {
    if (vector_is_null(vector1) || vector_is_null(vector2)) return 0;

    return acos(dot(vector1, vector2) / (length(vector1) * length(vector2))) / M_PI_H;
}

// r,g,b values are from 0 to 1
// h = [0, 360], s = [0,1], v = [0,1]
inline half3 hsvToRGB(float h, float s, float v) {
    int i;
    float f, p, q, t;
    float r, g, b;
    if (s == 0) {
        // achromatic (grey)
        r = g = b = v;
        return half3(r, g, b);
    }
    
    h /= 60;            // sector 0 to 5
    i = floor( h );
    f = h - i;            // factorial part of h
    
    p = v * ( 1 - s );
    q = v * ( 1 - s * f );
    t = v * ( 1 - s * ( 1 - f ) );
    
    switch (i) {
        case 0:
            r = v;
            g = t;
            b = p;
            break;
        case 1:
            r = q;
            g = v;
            b = p;
            break;
        case 2:
            r = p;
            g = v;
            b = t;
            break;
        case 3:
            r = p;
            g = q;
            b = v;
            break;
        case 4:
            r = t;
            g = p;
            b = v;
            break;
        default:        // case 5:
            r = v;
            g = p;
            b = q;
            break;
    }
    
    return half3(r, g, b);
}

inline half4 base_color(uint teamID) {
    switch (teamID) {
        case 0:
            return half4(110.0 / 256.0, 186.0 / 256.0, 170.0 / 256.0, 0);
        case 1:
            return half4(254.0 / 256.0, 151.0 / 256.0, 79.0 / 256.0, 0);
        default:
            return half4(47 / 256, 53 / 256, 66 / 256, 1.0);
    }
}

inline void process_mask(texture2d<half> mask, float2 textureCoordinate) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);

    const half4 colorSample = mask.sample(textureSampler, textureCoordinate);
    if (colorSample[0] == 0) discard_fragment();
}

//inline float slope(float2 p1, float2 p2) {
//    return (p2.y - p1.y) / (p2.x - p1.x);
//}
//
//inline float y_intercept(float2 p1, float slope) {
//    return p1.y - slope * p1.x;
//}
//
//inline float2 line_intersect(float m1, float b1, float m2, float b2) {
//    float x = (b2 - b1) / (m1 - m2);
//    float y = m1 * x + b1;
//    return { x, y };
//}

inline float2 collision_ray_position(float2 location, float startAngle, uint32_t index, uint32_t count, float radius) {
    float angleDelta = (1.5 * M_PI_H) / count;

    float a;

    // Distribute rays equally on both sides
    if (index % 2 == 0) a = startAngle - (index / 2 * angleDelta);
    else a = startAngle + ((index + 1) / 2 * angleDelta);

    return float2(
        location.x + radius * cos(a),
        location.y + radius * sin(a)
    );
}

// -- Line intersection check courtesy of https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/

// Given three colinear points p, q, r, the function checks if
// point q lies on line segment 'pr'
inline bool onSegment(float2 p, float2 q, float2 r) {
    return q.x <= max(p.x, r.x) && q.x >= min(p.x, r.x) && q.y <= max(p.y, r.y) && q.y >= min(p.y, r.y);
}

// To find orientation of ordered triplet (p, q, r).
// The function returns following values
// 0 --> p, q and r are colinear
// 1 --> Clockwise
// 2 --> Counterclockwise
inline int orientation(float2 p, float2 q, float2 r) {
    // See https://www.geeksforgeeks.org/orientation-3-ordered-points/ for details of below formula.
    int val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);

    if (val == 0) return 0;   // colinear
    return (val > 0) ? 1 : 2; // clock or counterclock wise
}

// The main function that returns true if line segment 'p1q1' and 'p2q2' intersect.
inline bool doIntersect(float2 p1, float2 q1, float2 p2, float2 q2) {
    // Find the four orientations needed for general and special cases
    int o1 = orientation(p1, q1, p2);
    int o2 = orientation(p1, q1, q2);
    int o3 = orientation(p2, q2, p1);
    int o4 = orientation(p2, q2, q1);

    // General case
    if (o1 != o2 && o3 != o4) return true;

    // Special Cases
    // p1, q1 and p2 are colinear and p2 lies on segment p1q1
    if (o1 == 0 && onSegment(p1, p2, q1)) return true;

    // p1, q1 and q2 are colinear and q2 lies on segment p1q1
    if (o2 == 0 && onSegment(p1, q2, q1)) return true;

    // p2, q2 and p1 are colinear and p1 lies on segment p2q2
    if (o3 == 0 && onSegment(p2, p1, q2)) return true;

     // p2, q2 and q1 are colinear and q1 lies on segment p2q2
    if (o4 == 0 && onSegment(p2, q1, q2)) return true;

    return false; // Doesn't fall in any of the above cases
}

// Wang hash (http://www.reedbeta.com/blog/quick-and-easy-gpu-random-numbers-in-d3d11/)
inline uint random(uint seed) {
    seed = (seed ^ 61) ^ (seed >> 16);
    seed *= 9;
    seed = seed ^ (seed >> 4);
    seed *= 0x27d4eb2d;
    seed = seed ^ (seed >> 15);
    return seed;
}

inline float random_float(uint seed) {
    return ((float) random(seed)) / ((float) UINT_MAX);
}
