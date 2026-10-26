Shader "Hidden/Toony Colors Pro 2/Outline Only (Shader Model 2)" {
	Properties {
		_Outline ("Outline Width", Float) = 1
		_OutlineColor ("Outline Color", Vector) = (0.2,0.2,0.2,1)
		_MainTex ("Base (RGB) Gloss (A) ", 2D) = "white" {}
		_TexLod ("Texture Outline LOD", Range(0, 10)) = 5
		_ZSmooth ("Z Correction", Range(-3, 3)) = -0.5
		_Offset1 ("Z Offset 1", Float) = 0
		_Offset2 ("Z Offset 2", Float) = 0
		_SrcBlendOutline ("#BLEND# Blending Source", Float) = 0
		_DstBlendOutline ("#BLEND# Blending Dest", Float) = 0
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