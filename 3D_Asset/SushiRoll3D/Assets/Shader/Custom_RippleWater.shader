Shader "Custom/RippleWater" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BumpMap ("Bumpmap", 2D) = "bump" {}
		_Color ("Color", Vector) = (1,1,1,1)
		_ColorEmission ("ColorEmission", Float) = 1
		_Glossiness ("Smoothness", Range(0, 1)) = 0.5
		_Metallic ("Metallic", Range(0, 1)) = 0
		_Scale ("Scale", Float) = 1
		_Speed ("Speed", Float) = 1
		_Frequency ("Frequency", Float) = 1
		[HideInInspector] _WaveAmplitude1 ("WaveAmplitude1", Float) = 0
		[HideInInspector] _WaveAmplitude2 ("WaveAmplitude1", Float) = 0
		[HideInInspector] _WaveAmplitude3 ("WaveAmplitude1", Float) = 0
		[HideInInspector] _WaveAmplitude4 ("WaveAmplitude1", Float) = 0
		[HideInInspector] _WaveAmplitude5 ("WaveAmplitude1", Float) = 0
		[HideInInspector] _WaveAmplitude6 ("WaveAmplitude1", Float) = 0
		[HideInInspector] _WaveAmplitude7 ("WaveAmplitude1", Float) = 0
		[HideInInspector] _WaveAmplitude8 ("WaveAmplitude1", Float) = 0
		[HideInInspector] _xImpact1 ("x Impact 1", Float) = 0
		[HideInInspector] _zImpact1 ("z Impact 1", Float) = 0
		[HideInInspector] _xImpact2 ("x Impact 2", Float) = 0
		[HideInInspector] _zImpact2 ("z Impact 2", Float) = 0
		[HideInInspector] _xImpact3 ("x Impact 3", Float) = 0
		[HideInInspector] _zImpact3 ("z Impact 3", Float) = 0
		[HideInInspector] _xImpact4 ("x Impact 4", Float) = 0
		[HideInInspector] _zImpact4 ("z Impact 4", Float) = 0
		[HideInInspector] _xImpact5 ("x Impact 5", Float) = 0
		[HideInInspector] _zImpact5 ("z Impact 5", Float) = 0
		[HideInInspector] _xImpact6 ("x Impact 6", Float) = 0
		[HideInInspector] _zImpact6 ("z Impact 6", Float) = 0
		[HideInInspector] _xImpact7 ("x Impact 7", Float) = 0
		[HideInInspector] _zImpact7 ("z Impact 7", Float) = 0
		[HideInInspector] _xImpact8 ("x Impact 8", Float) = 0
		[HideInInspector] _zImpact8 ("z Impact 8", Float) = 0
		[HideInInspector] _Distance1 ("Distance1", Float) = 0
		[HideInInspector] _Distance2 ("Distance2", Float) = 0
		[HideInInspector] _Distance3 ("Distance3", Float) = 0
		[HideInInspector] _Distance4 ("Distance4", Float) = 0
		[HideInInspector] _Distance5 ("Distance5", Float) = 0
		[HideInInspector] _Distance6 ("Distance6", Float) = 0
		[HideInInspector] _Distance7 ("Distance7", Float) = 0
		[HideInInspector] _Distance8 ("Distance8", Float) = 0
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
}