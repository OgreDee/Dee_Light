﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Dee/Speclur Phong"
{
	Properties
	{
        _Diffuse("Diffuse Color", Color) = (1,1,1,1)
    
        _SpecularColor("_SpecularColor", Color) = (1,1,1,1)
        _Gloss("Gloss", float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
            #include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

			struct v2f
			{
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                
				float4 vertex : SV_POSITION;
			};
            
            float4 _Diffuse;
			float4 _SpecularColor;
            float _Gloss;
            
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul((float3x3)unity_ObjectToWorld, v.normal);
                
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Diffuse.rgb;
            
                //漫反射
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * dot(worldLight, worldNormal);
                
                //Phong Specular
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 reflectDir = normalize(reflect(-worldLight, worldNormal));
                float3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow( saturate(dot(reflectDir, viewDir)), _Gloss);
                
                float3 finalCol = ambient + diffuse + specular;
                
                return float4(finalCol, 1);
			}
			ENDCG
		}
	}
}
