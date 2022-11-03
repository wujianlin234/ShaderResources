// Made with Amplify Shader Editor v1.9.0.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Unlit/NewUnlitShader"
{
	Properties
	{
		_FogColor("FogColor", Color) = (0.1581969,0.2809875,0.745283,0)
		_fogIntensity("fog Intensity", Range( 0 , 1)) = 1
		_FogDistanceStart("Fog Distance Start", Float) = 0
		_FogDistanceEnd("Fog Distance End", Float) = 700
		_FogHeightStart("Fog Height Start", Float) = 0
		_FogHeightEnd("Fog Height End", Float) = 700
		_sunfogcolor("sun fog color", Color) = (0.7933469,0.4728106,0.8018868,0)
		_sunfogrange("sun fog range", Float) = 10
		_sunfogintensity("sun fog intensity", Float) = 1
		_BaseColor("BaseColor", Color) = (0.6698113,0.6698113,0.6698113,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.4352941
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldNormal;
			float3 viewDir;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _Smoothness;
		uniform float4 _BaseColor;
		uniform float4 _FogColor;
		uniform float4 _sunfogcolor;
		uniform float _sunfogrange;
		uniform float _sunfogintensity;
		uniform float _FogDistanceEnd;
		uniform float _FogDistanceStart;
		uniform float _FogHeightEnd;
		uniform float _FogHeightStart;
		uniform float _fogIntensity;


		float3 ACESTonemap79( float3 LinearColor )
		{
			float a = 2.51f;
			float b = 0.03f;
			float c = 2.43f;
			float d = 0.59f;
			float e = 0.14f;
			return 
			saturate((LinearColor*(a*LinearColor + b)) / (LinearColor*(c*LinearColor + d) + e));
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldNormal = i.worldNormal;
			Unity_GlossyEnvironmentData g77 = UnityGlossyEnvironmentSetup( _Smoothness, data.worldViewDir, ase_worldNormal, float3(0,0,0));
			float3 indirectSpecular77 = UnityGI_IndirectSpecular( data, 1.0, ase_worldNormal, g77 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult67 = dot( -i.viewDir , ase_worldlightDir );
			float clampResult72 = clamp( pow( (dotResult67*0.5 + 0.5) , _sunfogrange ) , 0.0 , 1.0 );
			float myVarName75 = ( clampResult72 * _sunfogintensity );
			float4 lerpResult84 = lerp( _FogColor , _sunfogcolor , myVarName75);
			float temp_output_9_0_g8 = _FogDistanceEnd;
			float clampResult11_g8 = clamp( ( ( temp_output_9_0_g8 - distance( ase_worldPos , _WorldSpaceCameraPos ) ) / ( temp_output_9_0_g8 - _FogDistanceStart ) ) , 0.0 , 1.0 );
			float Fogdistance32 = ( 1.0 - clampResult11_g8 );
			float temp_output_9_0_g7 = _FogHeightEnd;
			float clampResult11_g7 = clamp( ( ( temp_output_9_0_g7 - ase_worldPos.y ) / ( temp_output_9_0_g7 - _FogHeightStart ) ) , 0.0 , 1.0 );
			float FogHeightdistance48 = ( 1.0 - ( 1.0 - clampResult11_g7 ) );
			float clampResult53 = clamp( ( ( Fogdistance32 * FogHeightdistance48 ) * _fogIntensity ) , 0.0 , 1.0 );
			float4 lerpResult35 = lerp( ( float4( indirectSpecular77 , 0.0 ) * _BaseColor ) , lerpResult84 , clampResult53);
			float3 LinearColor79 = ( lerpResult35 * lerpResult35 ).rgb;
			float3 localACESTonemap79 = ACESTonemap79( LinearColor79 );
			c.rgb = sqrt( localACESTonemap79 );
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma only_renderers d3d9 d3d11_9x d3d11 glcore gles gles3 metal vulkan 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19002
666;409;1624;864;571.9623;1200.263;2.43316;True;True
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;65;-1787.578,573.4737;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;66;-1797.42,765.8931;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;68;-1520.42,582.8931;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;31;-1820.77,-693.8427;Inherit;False;1210.163;494.4695;fog distance;7;32;28;29;30;26;23;24;;0.112362,0.1778449,0.9528302,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;41;-1902.742,-31.97868;Inherit;False;1395.91;580.042;fog height distance;6;48;47;46;45;43;50;;0.112362,0.1778449,0.9528302,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;67;-1363.42,677.8931;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1781.882,317.491;Inherit;False;Property;_FogHeightEnd;Fog Height End;5;0;Create;True;0;0;0;False;0;False;700;500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;43;-1844.743,35.02132;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;24;-1766.929,-453.0055;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;23;-1770.77,-643.8426;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;45;-1769.506,197.9434;Inherit;False;Property;_FogHeightStart;Fog Height Start;4;0;Create;True;0;0;0;False;0;False;0;-50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1358.534,-461.9208;Inherit;False;Property;_FogDistanceStart;Fog Distance Start;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1355.91,-332.3733;Inherit;False;Property;_FogDistanceEnd;Fog Distance End;3;0;Create;True;0;0;0;False;0;False;700;700;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;26;-1495.525,-539.0572;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;69;-1122.42,645.8931;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-1098.42,841.8931;Inherit;False;Property;_sunfogrange;sun fog range;7;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;47;-1455.58,115.4799;Inherit;False;Fog Linear;-1;;7;0858f36cb2b02d94398c74e27b505958;0;3;13;FLOAT;0;False;12;FLOAT;0;False;9;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;70;-892.4199,657.8931;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;30;-1107.607,-566.3843;Inherit;False;Fog Linear;-1;;8;0858f36cb2b02d94398c74e27b505958;0;3;13;FLOAT;0;False;12;FLOAT;0;False;9;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;50;-1146.114,133.9509;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;72;-664.2884,642.4963;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-832.5763,-578.881;Inherit;False;Fogdistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-820.1403,108.1187;Inherit;False;FogHeightdistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-636.3713,849.9152;Inherit;False;Property;_sunfogintensity;sun fog intensity;8;0;Create;True;0;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;92.7746,190.8399;Inherit;False;32;Fogdistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;121.7257,322.7416;Inherit;False;48;FogHeightdistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-386.3713,676.9152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;450.0175,329.804;Inherit;False;Property;_fogIntensity;fog Intensity;1;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-166.9541,681.7738;Inherit;False;myVarName;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;470.5027,129.1511;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-148.9149,-881.519;Inherit;False;Property;_Smoothness;Smoothness;10;0;Create;True;0;0;0;False;0;False;0.4352941;0.341;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;33;66.53297,-331.2559;Inherit;False;Property;_FogColor;FogColor;0;0;Create;True;0;0;0;False;0;False;0.1581969,0.2809875,0.745283,0;0.1581968,0.2809874,0.745283,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;82;143.0175,35.80396;Inherit;False;75;myVarName;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;77;232.3813,-850.2336;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;736.0175,200.804;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;38;190.8619,-563.7741;Inherit;False;Property;_BaseColor;BaseColor;9;0;Create;True;0;0;0;False;0;False;0.6698113,0.6698113,0.6698113,0;0.2075472,0.2075472,0.2075472,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;83;68.01752,-127.196;Inherit;False;Property;_sunfogcolor;sun fog color;6;0;Create;True;0;0;0;False;0;False;0.7933469,0.4728106,0.8018868,0;0.6871948,0.4217248,0.764151,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;559.6761,-723.523;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;84;373.0175,-226.196;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;53;815.683,-12.74689;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;35;727.7806,-463.754;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;979.7149,-505.1888;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;79;1140.112,-516.4321;Inherit;False;float a = 2.51f@$float b = 0.03f@$float c = 2.43f@$float d = 0.59f@$float e = 0.14f@$return $saturate((LinearColor*(a*LinearColor + b)) / (LinearColor*(c*LinearColor + d) + e))@;3;Create;1;True;LinearColor;FLOAT3;0,0,0;In;;Inherit;False;ACESTonemap;True;False;0;;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SqrtOpNode;81;1383.774,-531.1049;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;76;1676.807,-588.764;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Unlit/NewUnlitShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;8;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;vulkan;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;68;0;65;0
WireConnection;67;0;68;0
WireConnection;67;1;66;0
WireConnection;26;0;23;0
WireConnection;26;1;24;0
WireConnection;69;0;67;0
WireConnection;47;13;43;2
WireConnection;47;12;45;0
WireConnection;47;9;46;0
WireConnection;70;0;69;0
WireConnection;70;1;71;0
WireConnection;30;13;26;0
WireConnection;30;12;28;0
WireConnection;30;9;29;0
WireConnection;50;0;47;0
WireConnection;72;0;70;0
WireConnection;32;0;30;0
WireConnection;48;0;50;0
WireConnection;73;0;72;0
WireConnection;73;1;74;0
WireConnection;75;0;73;0
WireConnection;52;0;36;0
WireConnection;52;1;49;0
WireConnection;77;1;40;0
WireConnection;85;0;52;0
WireConnection;85;1;86;0
WireConnection;78;0;77;0
WireConnection;78;1;38;0
WireConnection;84;0;33;0
WireConnection;84;1;83;0
WireConnection;84;2;82;0
WireConnection;53;0;85;0
WireConnection;35;0;78;0
WireConnection;35;1;84;0
WireConnection;35;2;53;0
WireConnection;80;0;35;0
WireConnection;80;1;35;0
WireConnection;79;0;80;0
WireConnection;81;0;79;0
WireConnection;76;13;81;0
ASEEND*/
//CHKSM=F7721E9EB07E41D219721CAA217B1AFF532E3755