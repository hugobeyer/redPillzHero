RSRC                    VisualShader            ��������                                            �      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    linked_parent_graph_frame    input_name    script    parameter_name 
   qualifier    hint    min    max    step    default_value_enabled    default_value    size    expression 	   function 	   operator    initialized    properties    op_type 	   constant    code    graph_offset    mode    modes/blend    flags/skip_vertex_transform    flags/unshaded    flags/light_only    flags/world_vertex_coords    nodes/vertex/0/position    nodes/vertex/2/node    nodes/vertex/2/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/2/node    nodes/fragment/2/position    nodes/fragment/3/node    nodes/fragment/3/position    nodes/fragment/4/node    nodes/fragment/4/position    nodes/fragment/5/node    nodes/fragment/5/position    nodes/fragment/5/size    nodes/fragment/5/input_ports    nodes/fragment/5/output_ports    nodes/fragment/5/expression    nodes/fragment/7/node    nodes/fragment/7/position    nodes/fragment/12/node    nodes/fragment/12/position    nodes/fragment/14/node    nodes/fragment/14/position    nodes/fragment/15/node    nodes/fragment/15/position    nodes/fragment/21/node    nodes/fragment/21/position    nodes/fragment/25/node    nodes/fragment/25/position    nodes/fragment/28/node    nodes/fragment/28/position    nodes/fragment/29/node    nodes/fragment/29/position    nodes/fragment/30/node    nodes/fragment/30/position    nodes/fragment/31/node    nodes/fragment/31/position    nodes/fragment/33/node    nodes/fragment/33/position    nodes/fragment/34/node    nodes/fragment/34/position    nodes/fragment/35/node    nodes/fragment/35/position    nodes/fragment/37/node    nodes/fragment/37/position    nodes/fragment/38/node    nodes/fragment/38/position    nodes/fragment/39/node    nodes/fragment/39/position    nodes/fragment/40/node    nodes/fragment/40/position    nodes/fragment/41/node    nodes/fragment/41/position    nodes/fragment/42/node    nodes/fragment/42/position    nodes/fragment/43/node    nodes/fragment/43/position    nodes/fragment/44/node    nodes/fragment/44/position    nodes/fragment/45/node    nodes/fragment/45/position    nodes/fragment/46/node    nodes/fragment/46/position    nodes/fragment/47/node    nodes/fragment/47/position    nodes/fragment/49/node    nodes/fragment/49/position    nodes/fragment/50/node    nodes/fragment/50/position    nodes/fragment/51/node    nodes/fragment/51/position    nodes/fragment/52/node    nodes/fragment/52/position    nodes/fragment/53/node    nodes/fragment/53/position    nodes/fragment/54/node    nodes/fragment/54/position    nodes/fragment/55/node    nodes/fragment/55/position    nodes/fragment/56/node    nodes/fragment/56/position    nodes/fragment/57/node    nodes/fragment/57/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections     '   $   local://VisualShaderNodeInput_tqwfw �      -   local://VisualShaderNodeFloatParameter_cxn67 �      -   local://VisualShaderNodeFloatParameter_m3avs R      -   local://VisualShaderNodeFloatParameter_g3n6n �      )   local://VisualShaderNodeExpression_w1cbj       -   local://VisualShaderNodeRotationByAxis_vsgte       (   local://VisualShaderNodeFloatFunc_xe8ol �      &   local://VisualShaderNodeFloatOp_kfmg1 �      $   local://VisualShaderNodeInput_bmb5x 5      &   local://VisualShaderNodeFloatOp_8c0d2 l      $   local://VisualShaderNodeInput_620n5 �      &   local://VisualShaderNodeFloatOp_6cwgu       (   local://VisualShaderNodeFloatFunc_jtwkv a      &   local://VisualShaderNodeFloatOp_rj55b �      $   local://VisualShaderNodeInput_2dil7 �      %   local://VisualShaderNodeCustom_86cdh       %   local://VisualShaderNodeCustom_hv4ps 5      $   local://VisualShaderNodeClamp_571wn h      &   local://VisualShaderNodeFloatOp_jr8sm �      &   local://VisualShaderNodeFloatOp_um1nc �      ,   local://VisualShaderNodeFloatConstant_aekki "      (   local://VisualShaderNodeFloatFunc_oqqnh \      ,   local://VisualShaderNodeFloatConstant_7ym21 �      %   local://VisualShaderNodeCustom_mpr5n �      %   local://VisualShaderNodeCustom_mpp1q       %   local://VisualShaderNodeCustom_s7ubo �      %   local://VisualShaderNodeUVFunc_54xoo ]      $   local://VisualShaderNodeInput_tg7xe �      ,   local://VisualShaderNodeVectorCompose_xyu6j �      '   local://VisualShaderNodeVectorOp_5j01w �      &   local://VisualShaderNodeFloatOp_p6ght t      %   local://VisualShaderNodeCustom_oru2v �      ,   local://VisualShaderNodeVectorCompose_hbnqe [       $   local://VisualShaderNodeInput_2nug1 �       '   local://VisualShaderNodeVectorOp_vy7we �       )   local://VisualShaderNodeVectorFunc_sbsbc ?!      )   local://VisualShaderNodeVectorFunc_r6iyy �!      &   local://VisualShaderNodeFloatOp_fq6tj "      $   res://_shaders/post/Font_quads.tres i"         VisualShaderNodeInput             uv          VisualShaderNodeFloatParameter             grid_scale                #��=         VisualShaderNodeFloatParameter             border_size                ff�>         VisualShaderNodeFloatParameter             border_gradient                ��=         VisualShaderNodeExpression       
     �C  �C      �   vec2 scaled_uv = uv * grid_scale;
vec2 grid = fract(scaled_uv) - 0.5;
float dist = length(max(abs(grid) - border_size, vec2(0.0)));
result = smoothstep(0.0, border_gradient, dist * delta);          VisualShaderNodeRotationByAxis                                                         B         ��(����>  �?         VisualShaderNodeFloatFunc                      VisualShaderNodeFloatOp                                       A                  VisualShaderNodeInput             time          VisualShaderNodeFloatOp                                       ?                  VisualShaderNodeInput             uv          VisualShaderNodeFloatOp                                       B                  VisualShaderNodeFloatFunc                       VisualShaderNodeFloatOp                      VisualShaderNodeInput             time          VisualShaderNodeCustom                      VisualShaderNodeCustom                      VisualShaderNodeClamp             VisualShaderNodeFloatOp                                      �C                  VisualShaderNodeFloatOp                      VisualShaderNodeFloatConstant          �A ?         VisualShaderNodeFloatFunc                       VisualShaderNodeFloatConstant                      �?         VisualShaderNodeCustom                    
                   )   ��(\���?      
   �g?�p��      )   �z�G��?      )   ���Q��?                  VisualShaderNodeCustom                                             @                              VisualShaderNodeCustom                                             A                  VisualShaderNodeUVFunc             VisualShaderNodeInput             uv          VisualShaderNodeVectorCompose                                 VisualShaderNodeVectorOp                              
                 
                              VisualShaderNodeFloatOp                                 )   �$��C�?         VisualShaderNodeCustom                                       
      ?   ?            B      
                             VisualShaderNodeVectorCompose                       VisualShaderNodeInput             uv          VisualShaderNodeVectorOp                    
                 
                                       VisualShaderNodeVectorFunc                              
                              VisualShaderNodeVectorFunc                              
                              VisualShaderNodeFloatOp                                 )   ����MbP?                  VisualShader [                   S	  shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform float grid_scale = 0.12200000137091;
uniform float border_size = 0.44999998807907;
uniform float border_gradient = 0.06499999761581;



void vertex() {
// Input:2
	vec2 n_out2p0 = UV;


// Output:0
	UV = n_out2p0;


}

void fragment() {
// VectorCompose:47
	float n_in47p0 = 0.00000;
	float n_in47p1 = 0.00000;
	vec2 n_out47p0 = vec2(n_in47p0, n_in47p1);


// Input:25
	vec2 n_out25p0 = UV;


// VectorOp:49
	vec2 n_out49p0 = n_out47p0 + n_out25p0;


// VectorFunc:56
	vec2 n_out56p0 = normalize(n_out49p0);


// Input:31
	float n_out31p0 = TIME;


// FloatOp:37
	float n_in37p1 = 256.00000;
	float n_out37p0 = n_out31p0 / n_in37p1;


// FloatOp:30
	float n_in30p1 = 0.00000;
	float n_out30p0 = n_out37p0 * n_in30p1;


// FloatOp:28
	float n_in28p1 = 32.00000;
	float n_out28p0 = n_out30p0 * n_in28p1;


// FloatOp:57
	float n_in57p1 = 0.00100;
	float n_out57p0 = n_out28p0 * n_in57p1;


	vec3 n_out7p0;
	mat4 n_out7p1;
// RotationByAxis:7
	vec3 n_in7p2 = vec3(-0.66000, 0.33000, 1.00000);
	{
		float __angle = n_out57p0;
		vec3 __axis = normalize(n_in7p2);
		mat3 __rot_matrix = mat3(
			vec3( cos(__angle)+__axis.x*__axis.x*(1.0 - cos(__angle)), __axis.x*__axis.y*(1.0-cos(__angle))-__axis.z*sin(__angle), __axis.x*__axis.z*(1.0-cos(__angle))+__axis.y*sin(__angle) ),
			vec3( __axis.y*__axis.x*(1.0-cos(__angle))+__axis.z*sin(__angle), cos(__angle)+__axis.y*__axis.y*(1.0-cos(__angle)), __axis.y*__axis.z*(1.0-cos(__angle))-__axis.x*sin(__angle) ),
			vec3( __axis.z*__axis.x*(1.0-cos(__angle))-__axis.y*sin(__angle), __axis.z*__axis.y*(1.0-cos(__angle))+__axis.x*sin(__angle), cos(__angle)+__axis.z*__axis.z*(1.0-cos(__angle)) )
		);
		n_out7p0 = vec3(n_out56p0, 0.0) * __rot_matrix;
	}


// FloatParameter:2
	float n_out2p0 = grid_scale;


// FloatParameter:3
	float n_out3p0 = border_size;


// FloatParameter:4
	float n_out4p0 = border_gradient;


	float n_out5p0;
// Expression:5
	n_out5p0 = 0.0;
	{
		vec2 scaled_uv = vec2(n_out7p0.xy) * n_out2p0;
		vec2 grid = fract(scaled_uv) - 0.5;
		float dist = length(max(abs(grid) - n_out3p0, vec2(0.0)));
		n_out5p0 = smoothstep(0.0, n_out4p0, dist * n_out37p0);
	}


// FloatFunc:12
	float n_out12p0 = 1.0 - n_out5p0;


// FloatConstant:39
	float n_out39p0 = 0.626000;


// FloatOp:38
	float n_out38p0 = n_out12p0 - n_out39p0;


// Output:0
	COLOR.a = n_out38p0;


}
    
   q��Ķé�                                
     �C  �B!             "   
     H�  C#                        $   
    ��D  4�%            &   
     �  ��'            (   
    ���  �C)            *   
     ��  %D+            ,   
     >�  HC-   
     �C  �C.      E   0,3,uv;1,0,grid_scale;2,0,border_size;3,0,border_gradient;4,0,delta; /         0,0,result; 0      �   vec2 scaled_uv = uv * grid_scale;
vec2 grid = fract(scaled_uv) - 0.5;
float dist = length(max(abs(grid) - border_size, vec2(0.0)));
result = smoothstep(0.0, border_gradient, dist * delta); 1            2   
     ��  ��3            4   
     ��  ��5            6   
     ��  ��7            8   
    ���  �C9         	   :   
    ���  ��;         
   <   
    @�  W�=            >   
    @�  4C?            @   
     f�  �CA            B   
    �Z�  ��C            D   
    @��  �BE            F   
     >�  �CG            H   
     k�  ��I            J   
     �  �AK            L   
    ���  pBM            N   
   	����͟CO            P   
   �<P���DQ            R   
    �n�  %�S            T   
    � �  %�U            V   
     4�  ��W            X   
    @5�  H�Y            Z   
    �E�  *�[            \   
    �Z�  \�]            ^   
    @v�  p�_            `   
    @� ���a            b   
    ��� ���c            d   
   �eq�:�Ce            f   
     H�  ��g             h   
     \�  ��i         !   j   
    @v�   �k         "   l   
   3���q=	Cm         #   n   
    @5�  ��o         $   p   
    ���  \�q         %   r   
   f���jQCs       p                                                   #                           &       '       &      &                                   (                            %                    %                           (       -      .       -              1      /       1       2              %       2              4      %       4       1       8       8                     9       9             %                    RSRC