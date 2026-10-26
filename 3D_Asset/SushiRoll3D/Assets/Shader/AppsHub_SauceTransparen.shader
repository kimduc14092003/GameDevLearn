Shader "AppsHub/SauceTransparen" {
	Properties {
		_Color ("Color", Vector) = (1,1,1,1)
		_RimColor ("RimColor", Vector) = (1,1,1,1)
		_RimMulti ("RimMulti", Range(-2, 2)) = 1
		_Transparency ("Transparency", Range(0, 1)) = 0.5
		_ShadowIntensity ("ShadowIntensity", Range(0, 2)) = 1
		_ShadowColor ("ShadowColor", Vector) = (1,1,1,1)
		_Glossiness ("Glossiness", Float) = 32
		_SpecularColor ("Specular Color", Vector) = (0.9,0.9,0.9,1)
	}
	//DummyShaderTextExporter
	SubShader{
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4x4 unity_MatrixMVP;

			struct Vertex_Stage_Input
			{
				float3 pos : POSITION;
			};

			struct Vertex_Stage_Output
			{
				float4 pos : SV_POSITION;
			};

			Vertex_Stage_Output vert(Vertex_Stage_Input input)
			{
				Vertex_Stage_Output output;
				output.pos = mul(unity_MatrixMVP, float4(input.pos, 1.0));
				return output;
			}

			float4 _Color;

			float4 frag(Vertex_Stage_Output input) : SV_TARGET
			{
				return _Color; // RGBA
			}

			ENDHLSL
		}
	}
	Fallback "Unlit/SauceTransparentWithoutGrab"
}