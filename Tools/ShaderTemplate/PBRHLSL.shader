Shader "S_MyShaderTemplate"
{
	Properties
	{
		_BaseColorMap ("BaseColor", 2D) = "white" {}
		//_NormalMap ("Normal", 2D) = "bump" {}
		_PBRCubeMap("PBRCubeMap", cube) = ""{}
		_CubeLight("CubeLight", cube) = ""{}
 
		_RedWeight("ReadWeight", range(0.01, 10)) = 1
		_GreenWeight("GreenWeight", range(0.01, 10)) = 1
		_BlueWeight("BlueWeight", range(0.01, 10)) = 1
		_SpecularColorMutiply("ColorMultiply", Color) = (1, 1, 1, 0.4)
		_SpecularStrenth("SpecularStrenth", range(0.01, 5)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
 
		pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			//Blend OneminusDstColor One
			//Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
 
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 normal : NORMAL;
				//float4 tangent : TANGENT;
			};
 
			struct v2f
			{
				float2 uv : TEXCOORD0;
				//float3 tangent : TEXCOORD1;
				//float3 binormal : TEXCOORD2;
				float3 normal : NORMAL;
				float3 worldpos : TEXCOORD3;
				UNITY_FOG_COORDS(4)
				float4 vertex : SV_POSITION;
			};
 
			sampler2D _BaseColorMap;
			float4 _BaseColorMap_ST;
			//sampler2D _NormalMap;
			//float4 _NormalMap_ST;
			samplerCUBE _PBRCubeMap;
 
			float _RedWeight;
			float _GreenWeight;
			float _BlueWeight;
			
			v2f vert (appdata v)
			{
				v2f o;
				//o.vertex = mul(UNITY_MATRIX_M, v.vertex);
				//o.vertex = mul(UNITY_MATRIX_V, o.vertex);
				//o.vertex = mul(UNITY_MATRIX_P, o.vertex);
				//o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _BaseColorMap);
				o.normal = UnityObjectToWorldNormal(v.normal);
				//o.tangent = UnityObjectToWorldDir(v.tangent);
				//o.binormal = cross(v.tangent, v.normal);
				o.worldpos = mul(UNITY_MATRIX_M, v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half4 finalcolor = half4(1, 1, 1, 1);
				//float3 texnormal = UnpackNormal(tex2D(_NormalMap, i.uv));
				//float3x3 NormalTransMatrix = float3x3(i.tangent, i.binormal, i.normal);
 
				//float3 N = normalize(mul(texnormal, NormalTransMatrix)).xyz;
				float3 N = i.normal.xyz;
				float3 L = normalize(_WorldSpaceLightPos0.xyz);
				float3 V = normalize(UnityWorldSpaceViewDir(i.worldpos));
 
				float NoL = saturate(dot(N,L));
				float NoV = saturate(dot(N, V));
				float3 R = reflect(V, N);
 
				// sample the texture
				half3 BaseColor = tex2D(_BaseColorMap, i.uv).rgb;
 
				half3 cubecolor = texCUBE(_PBRCubeMap, R * raycol);
				//half3 cubecolor = texCUBE(_PBRCubeMap, R);
				finalcolor.rgb = (cubecolor + BaseColor) * 0.7;
 
				finalcolor.a = 0.5;
 
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, finalcolor);
				return finalcolor;
			}
			ENDCG
		}
		//------------------------------------------------------------------------------------------//
		Pass
		{
			//Blend DstColor One
			//Blend OneminusDstColor One
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
 
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 normal : NORMAL;
				//float4 tangent : TANGENT;
			};
 
			struct v2f
			{
				float2 uv : TEXCOORD0;
				//float3 tangent : TEXCOORD1;
				//float3 binormal : TEXCOORD2;
				float3 normal : NORMAL;
				float3 worldpos : TEXCOORD3;
				float3 viewpos : TEXCOORD4;
				UNITY_FOG_COORDS(5)
				float4 vertex : SV_POSITION;
			};
 
			sampler2D _BaseColorMap;
			float4 _BaseColorMap_ST;
			//sampler2D _NormalMap;
			//float4 _NormalMap_ST;
			samplerCUBE _PBRCubeMap;
			samplerCUBE _CubeLight;
 
			half4 _SpecularColorMutiply;
			float _SpecularStrenth;
 
			v2f vert (appdata v)
			{
				v2f o;
				//o.vertex = mul(UNITY_MATRIX_M, v.vertex);
				//o.vertex = mul(UNITY_MATRIX_V, o.vertex);
				//o.vertex = mul(UNITY_MATRIX_P, o.vertex);
				//o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _BaseColorMap);
				o.normal = UnityObjectToWorldNormal(v.normal);
				//o.tangent = UnityObjectToWorldDir(v.tangent);
				//o.binormal = cross(v.tangent, v.normal);
				o.worldpos = mul(UNITY_MATRIX_M, v.vertex);
				o.viewpos = UnityObjectToViewPos(v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half4 finalcolor = half4(1, 1, 1, 1);
				//float3 texnormal = UnpackNormal(tex2D(_NormalMap, i.uv));
				//float3x3 NormalTransMatrix = float3x3(i.tangent, i.binormal, i.normal);
 
				//float3 N = normalize(mul(texnormal, NormalTransMatrix)).xyz;
				float3 N = i.normal.xyz;
				float3 L = normalize(_WorldSpaceLightPos0.xyz);
				float3 V = normalize(UnityWorldSpaceViewDir(i.worldpos));
 
				float NoL = saturate(dot(N,L));
				float NoV = saturate(dot(N, V));
				float3 R = reflect(V, N);
 
				// sample the texture
				half3 BaseColor = tex2D(_BaseColorMap, i.uv).rgb;
				half3 cubecolor02 = texCUBE(_CubeLight, R);
				finalcolor.rgb = cubecolor02 * _SpecularColorMutiply.rgb * _SpecularStrenth;
				//finalcolor.rgb = cubecolor;
				
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, finalcolor);
				return finalcolor;
			}
			ENDCG
		}
		//------------------------------------------------------------------------------------------//
	}
}
