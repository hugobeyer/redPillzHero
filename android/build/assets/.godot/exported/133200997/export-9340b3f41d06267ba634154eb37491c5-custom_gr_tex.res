RSRC                    VisualShader            ��������                                            P      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    linked_parent_graph_frame    source    texture    texture_type    script    input_name    parameter_name 
   qualifier    default_value_enabled    default_value    op_type 	   operator    hint    min    max    step    code    graph_offset    mode    modes/blend    modes/depth_draw    modes/cull    modes/diffuse    modes/specular    flags/depth_prepass_alpha    flags/depth_test_disabled    flags/sss_mode_skin    flags/unshaded    flags/wireframe    flags/skip_vertex_transform    flags/world_vertex_coords    flags/ensure_correct_normals    flags/shadows_disabled    flags/ambient_light_disabled    flags/shadow_to_opacity    flags/vertex_lighting    flags/particle_trails    flags/alpha_to_coverage     flags/alpha_to_coverage_and_one    flags/debug_shadow_splits    flags/fog_disabled    nodes/vertex/0/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/2/node    nodes/fragment/2/position    nodes/fragment/3/node    nodes/fragment/3/position    nodes/fragment/4/node    nodes/fragment/4/position    nodes/fragment/5/node    nodes/fragment/5/position    nodes/fragment/6/node    nodes/fragment/6/position    nodes/fragment/7/node    nodes/fragment/7/position    nodes/fragment/8/node    nodes/fragment/8/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections    
   Texture2D 6   res://_textures/environment/stone_tiles_basecolor.png ����|k   &   local://VisualShaderNodeTexture_lviul �	      $   local://VisualShaderNodeInput_a4160 G
      -   local://VisualShaderNodeColorParameter_7s7to |
      -   local://VisualShaderNodeColorParameter_gw1ou �
      "   local://VisualShaderNodeMix_d72ng       '   local://VisualShaderNodeVectorOp_sjalv �      -   local://VisualShaderNodeFloatParameter_8w3k1 �      *   res://_shaders/grounds/custom_gr_tex.tres O         VisualShaderNodeTexture                                 	         VisualShaderNodeInput    
         uv 	         VisualShaderNodeColorParameter          	   ColorBot 	         VisualShaderNodeColorParameter          	   ColorTop 	         VisualShaderNodeMix                                              �?  �?  �?            ?         	         VisualShaderNodeVectorOp                    
                 
      A   A                   	         VisualShaderNodeFloatParameter             tiling                  �@	         VisualShader          �  shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec4 ColorBot : source_color;
uniform vec4 ColorTop : source_color;
uniform float tiling = 4;
uniform sampler2D tex_frg_2;



void fragment() {
// ColorParameter:4
	vec4 n_out4p0 = ColorBot;


// ColorParameter:5
	vec4 n_out5p0 = ColorTop;


// Input:3
	vec2 n_out3p0 = UV;


// FloatParameter:8
	float n_out8p0 = tiling;


// VectorOp:7
	vec2 n_out7p0 = n_out3p0 * vec2(n_out8p0);


// Texture2D:2
	vec4 n_out2p0 = texture(tex_frg_2, n_out7p0);
	float n_out2p1 = n_out2p0.r;


// Mix:6
	vec3 n_out6p0 = mix(vec3(n_out4p0.xyz), vec3(n_out5p0.xyz), n_out2p1);


// Output:0
	ALBEDO = n_out6p0;


}
    
   a�\��B1             2   
     a�  �B3            4   
     ��  \C5            6   
     �  ��7            8   
     ��  �C9            :   
      B  pC;            <   
    ���  ]C=            >   
   3+��P��C?                                                                                                         	      RSRC