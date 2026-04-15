Shader "YL/ButterflyFlap"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Base Color", Color) = (1,1,1,1)

        [Space(10)]
        _EmissionTex ("Emission Map", 2D) = "white" {}
        _EmissionStrength ("Emission Intensity", Range(0,1)) = 0.5

        [Space(15)]
        _FlapAngleDeg ("Max Flap Angle", Range(0,90)) = 60
        _FlapSpeed ("Flap Rate", Range(0,30)) = 15

        [Space(10)]
        _WobbleX ("Wobble X", Float) = 10
        _WobbleY ("Wobble Y", Float) = 10
        _WobbleZ ("Wobble Z", Float) = 10

        [Space(10)]
        _WobbleSpeedX ("Wobble Rate X", Range(0,10)) = 5
        _WobbleSpeedY ("Wobble Rate Y", Range(0,10)) = 5
        _WobbleSpeedZ ("Wobble Rate Z", Range(0,10)) = 5

        [Space(15)]
        [MaterialToggle]_YRotationEnabled ("Align Forward (Y)", Float) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _EmissionTex;
            float4 _EmissionTex_ST;
            float4 _Color;
            float _EmissionStrength;

            float _FlapAngleDeg;
            float _FlapSpeed;

            float _WobbleX, _WobbleY, _WobbleZ;
            float _WobbleSpeedX, _WobbleSpeedY, _WobbleSpeedZ;

            float _YRotationEnabled;

            struct appdata
            {
                float4 vertex   : POSITION;
                float2 uv       : TEXCOORD0;
                float4 color    : COLOR;

                float3 center   : TEXCOORD1;
                float3 rotation : TEXCOORD2;
                float4 random   : TEXCOORD3;

                float3 velocity : TEXCOORD4;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
                float2 emissionUV : TEXCOORD1;
                float4 color : COLOR;
            };

            float3x3 RotationMatrix(float3 rot)
            {
                float cx = cos(rot.x), sx = sin(rot.x);
                float cy = cos(rot.y), sy = sin(rot.y);
                float cz = cos(rot.z), sz = sin(rot.z);

                float3x3 Rx = float3x3(1,0,0, 0,cx,-sx, 0,sx,cx);
                float3x3 Ry = float3x3(cy,0,sy, 0,1,0, -sy,0,cy);
                float3x3 Rz = float3x3(cz,-sz,0, sz,cz,0, 0,0,1);
                return mul(Rz, mul(Ry, Rx));
            }

            float3x3 AxisAngle(float3 axis, float angle)
            {
                float3 a = normalize(axis);
                float s = sin(angle), c = cos(angle), ic = 1.0 - c;
                return float3x3(
                    c + ic*a.x*a.x,      ic*a.x*a.y - s*a.z,  ic*a.x*a.z + s*a.y,
                    ic*a.y*a.x + s*a.z,  c + ic*a.y*a.y,      ic*a.y*a.z - s*a.x,
                    ic*a.z*a.x - s*a.y,  ic*a.z*a.y + s*a.x,  c + ic*a.z*a.z
                );
            }

            v2f vert(appdata v)
            {
                v2f o;
                float3 localPos = v.vertex.xyz - v.center;

                float3x3 R = RotationMatrix(v.rotation);
                float3 localX = mul(R, float3(1,0,0));
                float3 localY = mul(R, float3(0,1,0));
                float3 localZ = mul(R, float3(0,0,1));

                // --- 羽ばたき ---
                float speedFactor = 0.8 + (v.random.x * 0.4);
                float angleFactor = 0.8 + (v.random.y * 0.4);

                float flapPhase = sin(_Time.y * _FlapSpeed * speedFactor);
                float wingAngle = radians(_FlapAngleDeg * angleFactor) * flapPhase * sign(dot(localPos, localX));

                localPos = mul(AxisAngle(localY, wingAngle), localPos);

                // --- 揺れ ---
                float wobbleAmpX = _WobbleX / 100 * (0.8 + frac(v.random.w + v.random.x) * 0.4);
                float wobbleAmpY = _WobbleY / 100 * (0.8 + frac(v.random.w + v.random.y) * 0.4);
                float wobbleAmpZ = _WobbleZ / 100 * (0.8 + frac(v.random.w + v.random.z) * 0.4);

                float wobbleSpeedX = _WobbleSpeedX * (0.8 + frac(v.random.y + v.random.z) * 0.4);
                float wobbleSpeedY = _WobbleSpeedY * (0.8 + frac(v.random.x + v.random.z) * 0.4);
                float wobbleSpeedZ = _WobbleSpeedZ * (0.8 + frac(v.random.x + v.random.y) * 0.4);

                localPos += localX * (wobbleAmpX * sin(_Time.y * wobbleSpeedX + (frac(v.random.x + v.random.y) * 6.2831)));
                localPos += localY * (wobbleAmpY * sin(_Time.y * wobbleSpeedY + (frac(v.random.y + v.random.z) * 6.2831)));
                localPos += localZ * (wobbleAmpZ * sin(_Time.y * wobbleSpeedZ + (frac(v.random.x + v.random.z) * 6.2831)));

                // --- ワールドY回転 (velocityに基づく) ---
                float3 vel = v.velocity;
                float3x3 Ry = float3x3(1,0,0, 0,1,0, 0,0,1);

                if (_YRotationEnabled > 0.5 && (abs(vel.x) > 1e-5 || abs(vel.z) > 1e-5)) {
                    float angleY = atan2(vel.x, vel.z);
                    float c = cos(angleY), s = sin(angleY);
                    Ry = float3x3(c,0,s, 0,1,0, -s,0,c);
                }

                localPos = mul(Ry, localPos);

                // --- 最終位置 ---
                float3 finalPos = v.center + localPos;
                o.pos = UnityObjectToClipPos(float4(finalPos,1));

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                o.emissionUV = TRANSFORM_TEX(v.uv, _EmissionTex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 baseColor = tex2D(_MainTex, i.uv) * _Color;
                fixed emissionMask = tex2D(_EmissionTex, i.emissionUV).r;
                fixed3 emission = baseColor.rgb * emissionMask * _EmissionStrength;

                fixed4 finalColor;
                finalColor.rgb = baseColor.rgb + emission;
                finalColor.a = baseColor.a;
                return finalColor * i.color;
            }
            ENDCG
        }
    }
}