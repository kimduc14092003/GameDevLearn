Shader "RollSurafces" {
	Properties {
		[TCP2HeaderHelp(Base)] _Color ("Color", Vector) = (1,1,1,1)
		_HColor ("Highlight Color", Vector) = (0.75,0.75,0.75,1)
		_SColor ("Shadow Color", Vector) = (0.2,0.2,0.2,1)
		_MainTex ("Albedo", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
		[TCP2Separator] [TCP2Header(Ramp Shading)] _RampThreshold ("Threshold", Range(0.01, 1)) = 0.5
		_RampSmoothing ("Smoothing", Range(0.001, 1)) = 0.1
		[TCP2Separator] [TCP2HeaderHelp(Specular)] [Toggle(TCP2_SPECULAR)] _UseSpecular ("Enable Specular", Float) = 0
		[TCP2ColorNoAlpha] _SpecularColor ("Specular Color", Vector) = (0.5,0.5,0.5,1)
		_SpecularSmoothness ("Smoothness", Float) = 0.2
		[TCP2Separator] [TCP2HeaderHelp(Rim Lighting)] [Toggle(TCP2_RIM_LIGHTING)] _UseRim ("Enable Rim Lighting", Float) = 0
		_RimColor ("Rim Color", Vector) = (0.8,0.8,0.8,0.5)
		_RimMinVert ("Rim Min", Range(0, 2)) = 0.5
		_RimMaxVert ("Rim Max", Range(0, 2)) = 1
		_RimDirVert ("Rim Direction", Vector) = (0,0,1,1)
		[TCP2Separator] [TCP2HeaderHelp(MatCap)] [Toggle(TCP2_MATCAP)] _UseMatCap ("Enable MatCap", Float) = 0
		[NoScaleOffset] _MatCapTex ("MatCap (RGB)", 2D) = "black" {}
		[TCP2ColorNoAlpha] _MatCapColor ("MatCap Color", Vector) = (1,1,1,1)
		[TCP2Separator] [TCP2HeaderHelp(Normal Mapping)] [Toggle(_NORMALMAP)] _UseNormalMap ("Enable Normal Mapping", Float) = 0
		[NoScaleOffset] _BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Scale", Float) = 1
		[TCP2Separator] [PerRendererData] _RollingActive ("RollingActive", Float) = 0
		[PerRendererData] _RollingNormalize ("RollingNormalize", Range(0, 1)) = 0
		[PerRendererData] _LenghtCircle ("RollingNormalize", Float) = 0
		[PerRendererData] _LayerThickness ("RollingNormalize", Float) = 0
		[PerRendererData] _Radius ("RollingNormalize", Float) = 0
		[PerRendererData] _AdditveRadius ("RollingNormalize", Float) = 0
		[PerRendererData] _RollingBoundsCenterZ ("RollingNormalize", Float) = 0
		[PerRendererData] _RollingBoundsSizeZ ("RollingNormalize", Float) = 0
		[PerRendererData] _RollingBoundsMinZ ("RollingNormalize", Float) = 0
		[PerRendererData] _RollingBoundsMaxZ ("RollingNormalize", Float) = 0
		[PerRendererData] _ClipBoundsCenterZ ("RollingNormalize", Float) = 0
		[PerRendererData] _ClipBoundsSizeZ ("RollingNormalize", Float) = 0
		[PerRendererData] _ClipBoundsMinZ ("RollingNormalize", Float) = 0
		[PerRendererData] _ClipBoundsMaxZ ("RollingNormalize", Float) = 0
		[PerRendererData] _MinClipZ ("RollingNormalize", Float) = 0
		[PerRendererData] _MaxClipZ ("RollingNormalize", Float) = 0
		[HideInInspector] __dummy__ ("unused", Float) = 0
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
	//CustomEditor "ToonyColorsPro.ShaderGenerator.MaterialInspector_SG2"
}