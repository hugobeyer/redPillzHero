RSRC                    VisualShader            ��������                                            J      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    linked_parent_graph_frame    parameter_name 
   qualifier    default_value_enabled    default_value    script    op_type    hint    min    max    step    code    graph_offset    mode    modes/blend    modes/depth_draw    modes/cull    modes/diffuse    modes/specular    flags/depth_prepass_alpha    flags/depth_test_disabled    flags/sss_mode_skin    flags/unshaded    flags/wireframe    flags/skip_vertex_transform    flags/world_vertex_coords    flags/ensure_correct_normals    flags/shadows_disabled    flags/ambient_light_disabled    flags/shadow_to_opacity    flags/vertex_lighting    flags/particle_trails    flags/alpha_to_coverage     flags/alpha_to_coverage_and_one    flags/debug_shadow_splits    flags/fog_disabled    varyings/screen    nodes/vertex/0/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/2/node    nodes/fragment/2/position    nodes/fragment/13/node    nodes/fragment/13/position    nodes/fragment/32/node    nodes/fragment/32/position    nodes/fragment/34/node    nodes/fragment/34/position    nodes/fragment/35/node    nodes/fragment/35/position    nodes/fragment/37/node    nodes/fragment/37/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections        -   local://VisualShaderNodeColorParameter_2awdj 6	      /   local://VisualShaderNodeBooleanParameter_f1ovi �	      .   local://VisualShaderNodeVectorDecompose_6ldn0 
      "   local://VisualShaderNodeMix_haci7 y
      -   local://VisualShaderNodeFloatParameter_c1138 �
      -   local://VisualShaderNodeColorParameter_e2vrl ^      3   res://addons/pillzgame/scripts/flocking_debug.tres �         VisualShaderNodeColorParameter          
   BaseColor                   	      j�>-2?�>  �?
      !   VisualShaderNodeBooleanParameter          	   use_grid                   	         
          VisualShaderNodeVectorDecompose                                                
         VisualShaderNodeMix                                                  �?  �?  �?  �?            ?         
         VisualShaderNodeFloatParameter             ColorModulate                   
         VisualShaderNodeColorParameter          	   AddColor                   	      B`e=  �?      �?
         VisualShader            shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_toon, specular_disabled, unshaded, ambient_light_disabled, fog_disabled;


// Varyings
varying vec2 var_screen;

instance uniform vec4 BaseColor : source_color = vec4(0.332187, 0.696000, 0.320160, 1.000000);
instance uniform vec4 AddColor : source_color = vec4(0.056000, 1.000000, 0.000000, 1.000000);
instance uniform float ColorModulate : hint_range(0, 1);



void vertex() {
	var_screen = vec2(0.0);
}

void fragment() {
// ColorParameter:2
	vec4 n_out2p0 = BaseColor;


// ColorParameter:37
	vec4 n_out37p0 = AddColor;


// FloatParameter:35
	float n_out35p0 = ColorModulate;


// Mix:34
	vec4 n_out34p0 = mix(n_out2p0, n_out37p0, n_out35p0);


// Output:0
	ALBEDO = vec3(n_out34p0.xyz);


}
    
   Ds��?��                           !         (         )         0,3 ,   
    �PE  ��-             .   
     ��  >�/            0   
     ��  �C1            2   
     kD    3            4   
     %D  ��5            6   
     ��  ��7            8   
     ��  �9                 "       #       "      "               "               %       "      
      RSRC