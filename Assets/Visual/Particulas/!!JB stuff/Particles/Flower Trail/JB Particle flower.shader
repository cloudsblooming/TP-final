Shader "JB/Particle/Flower_URP"
{
    Properties
    {
        _Albedo("Albedo", 2D) = "white" {}
        _Mask("Mask", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }
        LOD 100

        Blend Off
        AlphaToMask Off
        Cull Off
        ColorMask RGBA
        ZWrite On
        ZTest LEqual
        
        Pass
        {
            Name "Unlit"
            Tags { "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float4 color        : COLOR;
                float4 uv           : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float4 uv           : TEXCOORD0;
                float4 color        : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            // Declaración de Texturas y Samplers compatibles con URP
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            
            TEXTURE2D(_Mask);
            SAMPLER(sampler_Mask);

            CBUFFER_START(UnityPerMaterial)
                float4 _Mask_ST;
            CBUFFER_END

            // Funciones de conversión de color
            float3 RGBToHSV(float3 c)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            float3 HSVToRGB(float3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }
            
            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;
                output.color = input.color;
                
                return output;
            }
            
            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                
                // Muestreo de textura usando macros de URP
                float2 uv_Albedo = input.uv.xy;
                float4 tex2DNode2 = SAMPLE_TEXTURE2D(_Albedo, sampler_Albedo, uv_Albedo);
                
                // Lógica de desplazamiento de Tono (Hue Shift) usando las coordenadas Z del uv del particle system
                float3 hsvTorgb11 = RGBToHSV(tex2DNode2.rgb);
                float3 hsvTorgb12 = HSVToRGB(float3((hsvTorgb11.x + input.uv.z), hsvTorgb11.y, hsvTorgb11.z));
                
                // UVs de la Máscara aplicando el Tiling/Offset de las propiedades
                float2 uv_Mask = input.uv.xy * _Mask_ST.xy + _Mask_ST.zw;
                float4 maskSample = SAMPLE_TEXTURE2D(_Mask, sampler_Mask, uv_Mask);
                
                // Mezcla final basada en el canal Verde (G) de la máscara
                float3 colorModificado = hsvTorgb12 * input.color.rgb;
                float4 lerpResult3 = lerp(tex2DNode2, float4(colorModificado, 0.0), maskSample.g);
                
                return lerpResult3;
            }
            ENDHLSL
        }
    }
}