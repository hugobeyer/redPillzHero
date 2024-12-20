RSRC                    VisualShader            ��������                                            Y      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    linked_parent_graph_frame    input_name    script    varying_name    varying_type 	   constant 	   function 	   operator    op_type    code    graph_offset    mode    modes/blend    modes/depth_draw    modes/cull    modes/diffuse    modes/specular    flags/depth_prepass_alpha    flags/depth_test_disabled    flags/sss_mode_skin    flags/unshaded    flags/wireframe    flags/skip_vertex_transform    flags/world_vertex_coords    flags/ensure_correct_normals    flags/shadows_disabled    flags/ambient_light_disabled    flags/shadow_to_opacity    flags/vertex_lighting    flags/particle_trails    flags/alpha_to_coverage     flags/alpha_to_coverage_and_one    flags/debug_shadow_splits    flags/fog_disabled    varyings/vertex_pos    varyings/vertex_color    nodes/vertex/0/position    nodes/vertex/2/node    nodes/vertex/2/position    nodes/vertex/3/node    nodes/vertex/3/position    nodes/vertex/4/node    nodes/vertex/4/position    nodes/vertex/5/node    nodes/vertex/5/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/3/node    nodes/fragment/3/position    nodes/fragment/4/node    nodes/fragment/4/position    nodes/fragment/5/node    nodes/fragment/5/position    nodes/fragment/37/node    nodes/fragment/37/position    nodes/fragment/48/node    nodes/fragment/48/position    nodes/fragment/49/node    nodes/fragment/49/position    nodes/fragment/50/node    nodes/fragment/50/position    nodes/fragment/51/node    nodes/fragment/51/position    nodes/fragment/52/node    nodes/fragment/52/position    nodes/fragment/53/node    nodes/fragment/53/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections        $   local://VisualShaderNodeInput_oyfkt �      ,   local://VisualShaderNodeVaryingSetter_cxsky �      $   local://VisualShaderNodeInput_wjhrr       ,   local://VisualShaderNodeVaryingSetter_0agra M      ,   local://VisualShaderNodeFloatConstant_4jbfj �      ,   local://VisualShaderNodeFloatConstant_ntw6i �      ,   local://VisualShaderNodeFloatConstant_46vkn       (   local://VisualShaderNodeFloatFunc_ub2wk N      ,   local://VisualShaderNodeVaryingGetter_srj68 �      &   local://VisualShaderNodeFresnel_ig4p1 �      $   local://VisualShaderNodeInput_lnrm6 ?      ,   local://VisualShaderNodeFloatConstant_bsrde x      &   local://VisualShaderNodeFloatOp_blstn �      *   local://VisualShaderNodeMultiplyAdd_cr7to       5   res://_shaders/enemy_features/melee_small_sword.tres �         VisualShaderNodeInput             vertex          VisualShaderNodeVaryingSetter             vertex_pos 	                  VisualShaderNodeInput             color          VisualShaderNodeVaryingSetter             vertex_color 	                  VisualShaderNodeFloatConstant    
         ?         VisualShaderNodeFloatConstant    
      ff�>         VisualShaderNodeFloatConstant    
        �?         VisualShaderNodeFloatFunc                      VisualShaderNodeVaryingGetter                             vertex_color 	                  VisualShaderNodeFresnel                                     �@         VisualShaderNodeInput             normal          VisualShaderNodeFloatConstant    
         @         VisualShaderNodeFloatOp                                       A                  VisualShaderNodeMultiplyAdd                                              �?  �?  �?            ?   ?   ?                  VisualShader $           shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_toon, specular_schlick_ggx;


// Varyings
varying vec3 var_vertex_pos;
varying vec4 var_vertex_color;




void vertex() {
// Input:2
	vec3 n_out2p0 = VERTEX;


// VaryingSetter:3
	var_vertex_pos = n_out2p0;


// Input:4
	vec4 n_out4p0 = COLOR;


// VaryingSetter:5
	var_vertex_color = n_out4p0;


}

void fragment() {
// VaryingGetter:48
	vec4 n_out48p0 = var_vertex_color;


// Input:50
	vec3 n_out50p0 = NORMAL;


// FloatConstant:51
	float n_out51p0 = 2.000000;


// Fresnel:49
	float n_out49p0 = pow(1.0 - clamp(dot(n_out50p0, VIEW), 0.0, 1.0), n_out51p0);


// FloatOp:52
	float n_in52p1 = 8.00000;
	float n_out52p0 = n_out49p0 * n_in52p1;


// MultiplyAdd:53
	vec3 n_out53p0 = fma(vec3(n_out48p0.xyz), vec3(n_out52p0), vec3(n_out48p0.xyz));


// FloatConstant:4
	float n_out4p0 = 0.450000;


// FloatConstant:5
	float n_out5p0 = 1.000000;


// Output:0
	ALBEDO = n_out53p0;
	ROUGHNESS = n_out4p0;
	SPECULAR = n_out5p0;
	BACKLIGHT = n_out53p0;


}
          '         0,4 (         0,5 *             +   
     \�  C,            -   
     ��  C.            /   
     W�  �C0            1   
     ��  �C2                                      3   
     zE  �C4            5   
     �D  CD6            7   
    @E  D8            9   
     E  /D:            ;   
   �+���D<            =   
     E  pC>         	   ?   
    ��D  zD@         
   A   
     9D  DB            C   
    ��D  �DD            E   
    ��D  aDF            G   
    @5E  aDH       (                               2       1       3       1      0       5       0       5      1       4       4       5      5              5                     RSRC