//
//  Shaders.metal
//  MuseStatsIos
//
//  Created by David Conner on 2/28/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct FaceSubmesh {
    unsigned int idx [[ attribute(0) ]];
};

struct CommonVertexIn {
    float4 pos;
    float4 rgb;
};

struct CommonVertexOut {
    float4 pos [[ position ]];
    float4 rgb;
};

struct Projection {
    float4x4 projectionMatrix;
};

// vertexShaders
// - position buffer
// - rgb buffer
// - uniforms
// - projection
// - submesh (identify vertex from submesh - index/3)

vertex CommonVertexOut basic_vertex_out
(
 const device int* faceIndex [[ buffer(0) ]],
 const device float4* pos [[ buffer(1) ]],
 const device float4* rgb [[ buffer(2) ]],
 const device Projection& projection [[ buffer(3) ]],
 unsigned int vid [[ vertex_id ]])
{
    CommonVertexOut v_out;

    v_out.pos = projection * pos[faceIndex];
    v_out.rgb = rgb[faceIndex];
    
    return v_out;
}

fragment float4 basic_fragment(CommonVertexOut frag [[ stage_in ]]) {
    return float4(frag.rgb[0], frag.rgb[1], frag.rgb[2], frag.rgb[3]);
}

