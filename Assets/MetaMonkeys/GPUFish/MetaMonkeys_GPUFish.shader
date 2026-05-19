Shader "MetaMonkeys/GPUFish_URP"
{
    Properties
    {
        [Header(Main Emission)]_emissiontexture("emission texture", 2D) = "white" {}
        [HDR]_emissioncolor("emission color", Color) = (0,0,0,0)
        _hue("hue", Range( 0 , 1)) = 0
        _saturation("saturation", Float) = 1
        
        [Header(Vertex)]_vertexwaveintensity("vertex wave intensity", Float) = 1
        _vertexwavespeed("vertex wave speed", Float) = 1
        _vertexwavefrequency("vertex wave frequency", Float) = 1
        
        [Header(Vertex Additional)]_worldposwavemultiply("world pos wave multiply", Float) = 0
        _vertexmask("vertex mask", Range( -1 , 1)) = 0
        _vertexwavedir("vertex wave dir", Vector) = (1,0,0,0)
        
        [HDR][Header(Fresnel)]_fresnelcol("fresnel col", Color) = (0,0,0,0)
        _fresnelpow("fresnel pow", Float) = 1
        
        [Header(Additional)][Enum(UnityEngine.Rendering.CullMode)]_cullmode("cull mode", Float) = 2
        
        [Header(Additional Textures)]_albedotexture("albedo texture", 2D) = "white" {}
        _normaltexture("normal texture", 2D) = "bump" {}
        _metalictexture("metalic texture", 2D) = "white" {}
        _smoothnesstexture("smoothness texture", 2D) = "white" {}
        _aotexture("ao texture", 2D) = "white" {}
        
        _normalintensity("normal intensity", Range( 0.01 , 2)) = 1
        _metalic("metalic", Range( 0 , 1)) = 0
        _smoothness("smoothness", Range( 0 , 1)) = 0
        _ambientocclusion("ambient occlusion", Range( 0 , 1)) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue"="Geometry" }
        Cull [_cullmode]

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD3;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 tangentWS : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            // Propiedades
            TEXTURE2D(_albedotexture); SAMPLER(sampler_albedotexture);
            TEXTURE2D(_normaltexture); SAMPLER(sampler_normaltexture);
            TEXTURE2D(_emissiontexture); SAMPLER(sampler_emissiontexture);
            TEXTURE2D(_metalictexture); SAMPLER(sampler_metalictexture);
            TEXTURE2D(_smoothnesstexture); SAMPLER(sampler_smoothnesstexture);
            TEXTURE2D(_aotexture); SAMPLER(sampler_aotexture);

            CBUFFER_START(UnityPerMaterial)
                float4 _albedotexture_ST;
                float4 _emissioncolor;
                float _hue;
                float _saturation;
                float _vertexwaveintensity;
                float _vertexwavespeed;
                float _vertexwavefrequency;
                float _worldposwavemultiply;
                float _vertexmask;
                float3 _vertexwavedir;
                float4 _fresnelcol;
                float _fresnelpow;
                float _normalintensity;
                float _metalic;
                float _smoothness;
                float _ambientocclusion;
            CBUFFER_END

            // Helper functions para HSV
            float3 RGBToHSV(float3 c) {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            float3 HSVToRGB(float3 c) {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                
                // Animación de Vértices (Lógica original de tu shader)
                float mulTime = _Time.y * _vertexwavespeed;
                float wave = sin((input.positionOS.y * _vertexwavefrequency) + mulTime + (abs(positionWS.y) * _worldposwavemultiply));
                float mask = saturate(sin(input.positionOS.y + _vertexmask));
                
                input.positionOS.xyz += wave * _vertexwaveintensity * _vertexwavedir * mask;

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.uv = TRANSFORM_TEX(input.uv, _albedotexture);
                
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                // Albedo
                float4 albedo = SAMPLE_TEXTURE2D(_albedotexture, sampler_albedotexture, input.uv);
                
                // Normales
                float4 normalSample = SAMPLE_TEXTURE2D(_normaltexture, sampler_normaltexture, input.uv);
                float3 normalTS = UnpackNormalScale(normalSample, _normalintensity);
                
                // Emisión y HSV
                float4 emissiveTex = SAMPLE_TEXTURE2D(_emissiontexture, sampler_emissiontexture, input.uv) * _emissioncolor;
                float3 hsv = RGBToHSV(emissiveTex.rgb);
                hsv.x += _hue;
                hsv.y *= _saturation;
                float3 emissionRGB = HSVToRGB(hsv);

                // Fresnel
                float3 viewDirWS = normalize(GetWorldSpaceViewDir(input.positionWS));
                float fresnel = pow(1.0 - saturate(dot(input.normalWS, viewDirWS)), _fresnelpow);
                float3 finalEmission = emissionRGB + (fresnel * _fresnelcol.rgb);

                // PBR Data
                float metallic = SAMPLE_TEXTURE2D(_metalictexture, sampler_metalictexture, input.uv).r * _metalic;
                float smoothness = SAMPLE_TEXTURE2D(_smoothnesstexture, sampler_smoothnesstexture, input.uv).r * _smoothness;

                // Lighting (Simplificado para el ejemplo, usa la función de URP)
                InputData inputData = (InputData)0;
                inputData.positionWS = input.positionWS;
                inputData.normalWS = normalize(input.normalWS);
                inputData.viewDirectionWS = viewDirWS;
                inputData.shadowCoord = GetShadowCoord(GetVertexPositionInputs(input.positionWS));

                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = albedo.rgb;
                surfaceData.metallic = metallic;
                surfaceData.specular = half3(0,0,0);
                surfaceData.smoothness = smoothness;
                surfaceData.normalTS = normalTS;
                surfaceData.emission = finalEmission;
                surfaceData.occlusion = SAMPLE_TEXTURE2D(_aotexture, sampler_aotexture, input.uv).r * _ambientocclusion;
                surfaceData.alpha = 1.0;

                return UniversalFragmentPBR(inputData, surfaceData);
            }
            ENDHLSL
        }
        
        // Pass para Sombras (Importante en URP)
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}