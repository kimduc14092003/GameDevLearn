Shader "Unlit/SpecialFX/Liquid2" {
	Properties {
		_Tint ("Tint", Vector) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_FillAmount ("Fill Amount", Float) = 0
		_WobbleX ("WobbleX", Range(-1, 1)) = 0
		_WobbleZ ("WobbleZ", Range(-1, 1)) = 0
		_TopColor ("Top Color", Vector) = (1,1,1,1)
		_FoamColor ("Foam Line Color", Vector) = (1,1,1,1)
		_Rim ("Foam Line Width", Range(0, 0.1)) = 0
		_RimColor ("Rim Color", Vector) = (1,1,1,1)
		_RimPower ("Rim Power", Range(0, 10)) = 0
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

			Texture2D<float4> _MainTex;
			SamplerState sampler_MainTex;

			struct Fragment_Stage_Input
			{
				float2 uv : TEXCOORD0;
			};

			float4 frag(Fragment_Stage_Input input) : SV_TARGET
			{
				return _MainTex.Sample(sampler_MainTex, float2(input.uv.x, input.uv.y));
			}

			ENDHLSL
		}
	}
}