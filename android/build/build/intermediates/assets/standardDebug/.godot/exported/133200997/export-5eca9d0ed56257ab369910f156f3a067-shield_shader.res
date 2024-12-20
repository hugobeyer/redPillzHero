RSRC                    VisualShader            ��������                                            f      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    linked_parent_graph_frame    input_name    script    op_type 	   operator 	   constant    parameter_name 
   qualifier    hint    min    max    step    default_value_enabled    default_value    code    graph_offset    mode    modes/blend    modes/depth_draw    modes/cull    modes/diffuse    modes/specular    flags/depth_prepass_alpha    flags/depth_test_disabled    flags/sss_mode_skin    flags/unshaded    flags/wireframe    flags/skip_vertex_transform    flags/world_vertex_coords    flags/ensure_correct_normals    flags/shadows_disabled    flags/ambient_light_disabled    flags/shadow_to_opacity    flags/vertex_lighting    flags/particle_trails    flags/alpha_to_coverage     flags/alpha_to_coverage_and_one    flags/debug_shadow_splits    flags/fog_disabled    nodes/vertex/0/position    nodes/vertex/2/node    nodes/vertex/2/position    nodes/vertex/5/node    nodes/vertex/5/position    nodes/vertex/6/node    nodes/vertex/6/position    nodes/vertex/7/node    nodes/vertex/7/position    nodes/vertex/8/node    nodes/vertex/8/position    nodes/vertex/9/node    nodes/vertex/9/position    nodes/vertex/10/node    nodes/vertex/10/position    nodes/vertex/11/node    nodes/vertex/11/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/2/node    nodes/fragment/2/position    nodes/fragment/3/node    nodes/fragment/3/position    nodes/fragment/4/node    nodes/fragment/4/position    nodes/fragment/5/node    nodes/fragment/5/position    nodes/fragment/6/node    nodes/fragment/6/position    nodes/fragment/7/node    nodes/fragment/7/position    nodes/fragment/8/node    nodes/fragment/8/position    nodes/fragment/9/node    nodes/fragment/9/position    nodes/fragment/10/node    nodes/fragment/10/position    nodes/fragment/11/node    nodes/fragment/11/position    nodes/fragment/12/node    nodes/fragment/12/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections        $   local://VisualShaderNodeInput_fvi5g �      $   local://VisualShaderNodeInput_g2jsi �      '   local://VisualShaderNodeVectorOp_1a1ot �      '   local://VisualShaderNodeVectorOp_ui12m '      ,   local://VisualShaderNodeFloatConstant_r56lh \      "   local://VisualShaderNodeMix_43vqv �      -   local://VisualShaderNodeFloatParameter_o01d5       $   local://VisualShaderNodeInput_ay31i �      ,   local://VisualShaderNodeColorConstant_mmhdj �      "   local://VisualShaderNodeMix_dy7x4       *   local://VisualShaderNodeMultiplyAdd_ahs6f �      -   local://VisualShaderNodeFloatParameter_5ji54 (      "   local://VisualShaderNodeMix_n2r34 �      -   local://VisualShaderNodeFloatParameter_nmp41       ,   local://VisualShaderNodeColorConstant_ykbii �      .   local://VisualShaderNodeVectorDecompose_4raj3 �      ,   local://VisualShaderNodeVectorCompose_6m4bs *      $   local://VisualShaderNodeRemap_f2um7 X      *   local://VisualShaderNodeMultiplyAdd_pfvyi �      )   res://_shaders/visual/shield_shader.tres 6         VisualShaderNodeInput             normal          VisualShaderNodeInput             vertex          VisualShaderNodeVectorOp             VisualShaderNodeVectorOp    	                  VisualShaderNodeFloatConstant    
         @         VisualShaderNodeMix                         �?  �?  �?           �?  �?  �?            ?                  VisualShaderNodeFloatParameter             shield_size_hit                                     VisualShaderNodeInput             vertex          VisualShaderNodeColorConstant              
      �G?(a?��W>  �?         VisualShaderNodeMix                                                  �?  �?  �?  �?            ?                  VisualShaderNodeMultiplyAdd                    2                         2     �?  �?  �?  �?      2                                     VisualShaderNodeFloatParameter             shield_hit                                     VisualShaderNodeMix                                                  �?  �?  �?  �?            ?                  VisualShaderNodeFloatParameter             shield_die                                     VisualShaderNodeColorConstant    
      ���=  �?      �?          VisualShaderNodeVectorDecompose                                                         VisualShaderNodeVectorCompose             VisualShaderNodeRemap                        ��           �?                        �?         VisualShaderNodeMultiplyAdd                                      �@      )   �������?         VisualShader .         �  shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, diffuse_toon, specular_disabled;

instance uniform float shield_size_hit : hint_range(0, 1) = 0;
instance uniform float shield_hit : hint_range(0, 1) = 0;
instance uniform float shield_die : hint_range(0, 1) = 0;



void vertex() {
// Input:11
	vec3 n_out11p0 = VERTEX;


// Input:2
	vec3 n_out2p0 = NORMAL;


// FloatConstant:8
	float n_out8p0 = 2.000000;


// VectorOp:7
	vec3 n_out7p0 = n_out2p0 / vec3(n_out8p0);


// Input:5
	vec3 n_out5p0 = VERTEX;


// VectorOp:6
	vec3 n_out6p0 = n_out7p0 + n_out5p0;


// FloatParameter:10
	float n_out10p0 = shield_size_hit;


// Mix:9
	vec3 n_out9p0 = mix(n_out11p0, n_out6p0, n_out10p0);


// Output:0
	VERTEX = n_out9p0;


}

void fragment() {
// ColorConstant:2
	vec4 n_out2p0 = vec4(0.780000, 0.618670, 0.210600, 1.000000);


// MultiplyAdd:4
	vec4 n_in4p1 = vec4(1.00000, 1.00000, 1.00000, 1.00000);
	vec4 n_in4p2 = vec4(0.00000, 0.00000, 0.00000, 0.00000);
	vec4 n_out4p0 = fma(n_out2p0, n_in4p1, n_in4p2);


// FloatParameter:5
	float n_out5p0 = shield_hit;


// MultiplyAdd:12
	float n_in12p1 = 4.00000;
	float n_in12p2 = 0.20000;
	float n_out12p0 = fma(n_out5p0, n_in12p1, n_in12p2);


// Mix:3
	vec4 n_out3p0 = mix(n_out2p0, n_out4p0, n_out12p0);


// ColorConstant:8
	vec4 n_out8p0 = vec4(0.100000, 1.000000, 0.000000, 1.000000);


// FloatParameter:7
	float n_out7p0 = shield_die;


// Mix:6
	vec4 n_out6p0 = mix(n_out3p0, n_out8p0, n_out7p0);


// VectorDecompose:9
	float n_out9p0 = n_out6p0.x;
	float n_out9p1 = n_out6p0.y;
	float n_out9p2 = n_out6p0.z;
	float n_out9p3 = n_out6p0.w;


// VectorCompose:10
	vec3 n_out10p0 = vec3(n_out9p0, n_out9p1, n_out9p2);


// Output:0
	ALBEDO = n_out10p0;
	ALPHA = n_out12p0;


}
                            -             .   
     ��  ��/            0   
     M�  �C1            2   
     ��   C3            4   
     9�  �B5            6   
    ���  4C7            8   
     ��  �B9            :   
     ��  �C;            <   
     9�  ��=                                                                 	                      	      
       	             	       >   
     D  pC?            @   
     ��  CA         	   B   
     ��  \CC         
   D   
     u�  �CE            F   
    ���  DG            H   
     p�  4CI            J   
     �  aDK            L   
     ��  /DM            N   
     �A  �BO            P   
     �C  pBQ            R   
    ���  4DS            T   
     \�  DU       <                                                                                           	       	       
       	      
      	      
      
                                                                            RSRC