Shader "AuroraShader/SkyDome_AuroraVer002"
{
    Properties
    {
        _AuroraColor("Aurora_Color", Color) = (0, 1, 1, 1)
        _AuroraBrightness("Aurora_Brightness", Range(0, 10)) = 4
        _Granularity("Aurora_Granularity", Range(0, 4)) = 1
        _TopColor("Sky_TopColor", Color) = (0.2, 0.3, 0.7, 1)
        _CenterColor("Sky_CenterColor", Color) = (0, 0, 0, 1)
        _CenterHeight("Sky_CenterHeight", Range(0, 1)) = 0.5
        _GradBlur("Sky_GradientBlurring", Range(0, 1)) = 0.1
        [Toggle] _StarOnOff("Star_On/Off", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        Cull Front
        ZWrite Off
        Blend One One 

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
//Vertexシェーダ------------------------------------

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
				float2 uv : TEXCOORD0;
				float3 pos : TEXCOORD1;
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
            };

			float2 uv_texcoord;
			float3 worldPos;

			fixed4 _AuroraColor;
			float _AuroraBrightness;
			float _Granularity;

			fixed4 _TopColor;
			fixed4 _CenterColor;
			float _CenterHeight;
			float _GradBlur;

			float _StarOnOff;

			v2f vert(appdata v)
			{
				v2f o;

				UNITY_SETUP_INSTANCE_ID(v); 
				UNITY_INITIALIZE_OUTPUT(v2f, o); 
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o); 

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.pos = v.vertex.xyz;
				o.uv = v.uv;
				return o;
			}

//各種メソッド------------------------------------

			float2x2 mm2(float a) 
			{ 
				float c = cos(a), s = sin(a);
				return float2x2(c, s, -s, c);
			}

			float2x2 m2 = float2x2(0.95534, 0.29552, -0.29552, 0.95534);

			float tri(float x) 
			{ 
				return clamp(abs(frac(x) - .5), 0.01, 0.49);
			}
					   			 
			float2 tri2(float2 p)
			{
				return float2(tri(p.x) + tri(p.y), tri(p.y + tri(p.x))); 
			}


			float triNoise2d(float2 p, float spd)
			{
				float z = 1.8;
				float z2 = 2.5;
				float rz = 0 ;
				p = mul(p, mm2(p.x * 0.05));
				float2 bp = p;
				for (float i = 0.0 ; i < 4.0 ; i++)
				{
					float2 dg = tri2(bp*1.85)*0.75;
					dg = mul(dg, mm2(_Time * spd));
					p -= dg / z2;

					bp *= 1.3;
					z2 *= 0.45;
					z *= 0.42;
					p *= 1.21 + (rz - 1.0)*.02;

					rz += tri(p.x + tri(p.y))*z;
					p = mul(p, -m2);
				}
				return clamp(1. / pow(rz*29., 1.3), 0.0, 0.55);
			}

			float hash21(float2 n) { return frac(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453); }


//オーロラ------------------------------------

			float4 aurora(float3 ro, float3 rd)
			{
				float4 col = float4(0, 0, 0, 0);
				float4 avgCol = float4(0, 0, 0, 0);

				for (float i = 0 ;i < 32; i++)
				{
					float of = 0.006 * hash21(mul(unity_WorldToObject, float4(worldPos, 1))) * smoothstep(0, 15.0, i);
					float pt = ((0.8 + pow(i, 1.4)*.002) - ro.y) / (rd.y*2. + 0.4);
					pt -= of;
					float3 bpos = ro + pt * rd * _Granularity;
					float2 p = bpos.zx;
					float rzt = triNoise2d(p, 10);
					float4 col2 = float4(0, 0, 0, rzt);
					col2.rgb = (sin(1.0 - float3(2.15, -0.5, 1.2) + i * 0.043)*0.5 + 0.5)*rzt;
					avgCol = lerp(avgCol, col2, 0.5);
					col += avgCol * exp2(-i * 0.065 - 2.5)*smoothstep(0.0, 5.0, i);
				}
				col *= (clamp(rd.y * 15.0 + 0.4, 0.0, 1.0 ));

				return clamp(pow(col,float4(1.3, 1.3, 1.3, 1.3) * float4(1.0, 1.0, 1.0, 1.0)) * 1.0, 0.0 ,1.0);
			}

//星------------------------------------

			float3 hash33(float3 p)
			{
				p = frac(p * float3(443.8975, 397.2973, 491.1871));
				p += dot(p.zxy, p.yxz + 19.27);
				return frac(float3(p.x * p.y, p.z*p.x, p.y*p.z));
			}

			float3 stars(float3 p)
			{
				float3 c = float3(0, 0, 0);
				float res = 2000 * _StarOnOff;

				for (float i = 0; i < 4; i++)
				{
					float3 q = frac(p*(0.15 * res)) - 0.5;
					float3 id = floor(p * (0.15 * res));
					float2 rn = hash33(id).xy;
					float c2 = 1.0 - smoothstep(0.0, 0.6, length(q));
					c2 *= step(rn.x, 0.0005 + i * i * 0.001);
					c += c2 * (lerp(float3(1.0, 1.49, 0.1), float3(0.75, 0.9, 1.), rn.y) * 0.1 + 0.9);
					p *= 1.3;
				}
				return c * c * 0.5;
			}

//Fragmentシェーダー------------------------------------


			fixed4 frag(v2f i) : SV_Target
            {
                float3 ro = float3(0.0, 0.0, 0.0);
                float3 rd = normalize(i.pos.xyz);
                
                // Rotaci b疽ica para que no sea est疸ico
                rd.xz = mul(rd.xz, mm2(sin(_Time.y * 0.05) * 0.2));

                float3 col = float3(0, 0, 0);
                float fade = smoothstep(0.0, 0.01, abs(rd.y)) * 0.1 + 0.5;

                float Sphere_Top = saturate(i.pos.y) - (sign(saturate(i.pos.y)) * (-2 + _CenterHeight * 4));
                float Sphere_Bottom = saturate(-1 * i.pos.y) - (sign(saturate(-1 * i.pos.y)) * (-2 + _CenterHeight * 4));
                float Sphere_Add = saturate(Sphere_Top + Sphere_Bottom);
                float Sphere = pow(Sphere_Add, 0.0 + (_GradBlur + 0.01) * 3);

                // Colores de fondo (Sky)
                float4 SkyCol = lerp(_CenterColor, _TopColor, Sphere);
                col = SkyCol.rgb * fade;

                // C疝culo de Aurora y Estrellas
                if (rd.y > 0.0) 
                {
                    float4 aur = smoothstep(0.0, 1.5, aurora(ro, rd)) * fade;
                    col += stars(rd + sin(_Time.y) / 3000);
                    col = col * (1.0 - aur.a) + ((((aur.r + aur.g + aur.b) / 3.0) * _AuroraColor.rgb) * _AuroraBrightness);
                }
                else 
                {
                    rd.y = abs(rd.y);
                    float4 aur = smoothstep(0.05, 1.5, aurora(ro, rd));
                    col += stars(rd) * 0.1;
                    col = col * (1.0 - aur.a) + ((((aur.r + aur.g + aur.b) / 3.0) * _AuroraColor.rgb) * _AuroraBrightness);
                }

                // EL RETORNO FINAL (Fuera de cualquier IF)
                return float4(col, 1.0);
            }
            ENDCG
        }
    }
}