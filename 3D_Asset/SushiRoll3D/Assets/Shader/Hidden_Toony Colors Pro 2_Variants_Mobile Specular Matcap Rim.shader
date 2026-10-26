Shader "Hidden/Toony Colors Pro 2/Variants/Mobile Specular Matcap Rim" {
	Properties {
		_Color ("Color", Vector) = (1,1,1,1)
		_HColor ("Highlight Color", Vector) = (0.785,0.785,0.785,1)
		_SColor ("Shadow Color", Vector) = (0.195,0.195,0.195,1)
		_MainTex ("Main Texture (RGB) Spec/MatCap Mask (A) ", 2D) = "white" {}
		[TCP2Gradient] _Ramp ("#RAMPT# Toon Ramp (RGB)", 2D) = "gray" {}
		_RampThreshold ("#RAMPF# Ramp Threshold", Range(0, 1)) = 0.5
		_RampSmooth ("#RAMPF# Ramp Smoothing", Range(0.01, 1)) = 0.1
		_BumpMap ("#NORM# Normal map (RGB)", 2D) = "bump" {}
		_SpecColor ("#SPEC# Specular Color", Vector) = (0.5,0.5,0.5,1)
		_Shininess ("#SPEC# Shininess", Range(0.01, 2)) = 0.1
		_SpecSmooth ("#SPECT# Smoothness", Range(0, 1)) = 0.05
		_RimColor ("#RIM# Rim Color", Vector) = (0.8,0.8,0.8,0.6)
		_RimMin ("#RIM# Rim Min", Range(0, 1)) = 0.5
		_RimMax ("#RIM# Rim Max", Range(0, 1)) = 1
		_RimDir ("#RIMDIR# Rim Direction", Vector) = (0,0,1,0)
		_MatCap ("#MC# MatCap (RGB)", 2D) = "black" {}
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
			float4 _Color;

			struct Fragment_Stage_Input
			{
				float2 uv : TEXCOORD0;
			};

			float4 frag(Fragment_Stage_Input input) : SV_TARGET
			{
				return _MainTex.Sample(sampler_MainTex, float2(input.uv.x, input.uv.y)) * _Color;
			}

			ENDHLSL
		}
	}
	Fallback "Diffuse"
	//CustomEditor "TCP2_MaterialInspector"
}