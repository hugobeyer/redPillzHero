shader_type spatial;

uniform float curve_strength = 0.001;
uniform float radius = 100.0;
uniform sampler2D ground_texture : source_color;
uniform float texture_scale = 1.0;

varying float curved_height;

void vertex() {
    vec2 xz_pos = VERTEX.xz;
    float dist_squared = dot(xz_pos, xz_pos);
    
    curved_height = dist_squared * curve_strength;
    VERTEX.y -= curved_height;
    
    // Pass UVs for texturing
    UV = VERTEX.xz * texture_scale;
    
    NORMAL = normalize(NORMAL + vec3(
        -xz_pos.x * 2.0 * curve_strength,
        0.0,
        -xz_pos.y * 2.0 * curve_strength
    ));
}

void fragment() {
    vec2 uv = UV;
    vec4 tex_color = texture(ground_texture, uv);
    ALBEDO = tex_color.rgb;
}