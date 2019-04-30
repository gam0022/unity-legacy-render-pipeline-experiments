Shader "Demoscene/ImageEffect/Reiwa-Glitch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Always("_Always", Range(0.0, 1.0)) = 1.0
        _GlitchUvIntensity("Glitch Uv Intensity", Range(0.0, 1.0)) = 0.1
        _DistortionIntensity("_DistortionIntensity", Range(0.0, 1.0)) = 0.1
        _RgbShiftIntensity("Rgb Shift Intensity", Range(0.0, 1.0)) = 0.1
        _NoiseIntensity("Noise Intensity", Range(0.0, 1.0)) = 0.1
        _FlashSpeed("Flash Speed", Range(0.0, 100.0)) = 0.0
        _FlashColor("Flash Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _BlendColor("Blend Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _Invert("Invert Rate", Range(0.0, 1.0)) = 0.0
        
        _IfsIteration("Ifs Iteration", Range(0.0, 10.0)) = 0.0
        _IfsRateA("Ifs Rate A", Range(0.0, 1.0)) = 0.0
        _IfsRateB("Ifs Rate B", Range(0.0, 1.0)) = 0.0
        _IfsRateC("Ifs Rate C", Range(0.0, 1.0)) = 0.7
        _IfsRateD("Ifs Rate D", Range(0.0, 2.0)) = 1.2
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/Experiments/Shaders/Includes/Common.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float _Beat;

            sampler2D _MainTex;

            float _Always;
            float _GlitchUvIntensity;
            float _DistortionIntensity;
            float _RgbShiftIntensity;
            float _NoiseIntensity;
            float _FlashSpeed;
            fixed4 _FlashColor;
            fixed4 _BlendColor;
            float _Invert;
            
            float _IfsIteration;
            float _IfsRateA;
            float _IfsRateB;
            float _IfsRateC;
            float _IfsRateD;

            fixed4 frag (v2f i) : SV_Target
            {
                half3 col;
                half2 uv = i.uv;

                float vibration = saturate(cos(_Beat * PI2));
                vibration = mix(vibration, 1.0, _Always);
                
                // ifs
                // TODO: Use ShaderVariant
                if (_IfsIteration > 0) {
                    vec2 q = (uv - 0.5) * 4.0;
                    //float d = 9999.0;
                    float z = _IfsRateA * PI2;
                    for (int j = 0; j < _IfsIteration; ++j) {
                        q = abs(q - _IfsRateC);
                        q = mul(rot(_IfsRateB * PI2), q);
                        q = abs(q - _IfsRateC);
                        q = mul(rot(z), q);
                        q *= _IfsRateD;
                        //float k = sdRect(q, vec2(0.6, 0.1 + q.x));
                        //d = min(d, k);
                    }
                    uv = q;
                }

                // grid hash
                float2 hash = hash23(float3(floor(half2(uv.x * 32.0, uv.y * 32.0)), _Beat));

                // uv shift
                uv += _GlitchUvIntensity * vibration * (1.0 - 2.0 * hash);

                // distortion
                uv.x += _DistortionIntensity * vibration * sin(uv.y * 4.0 + _Beat);

                // rgb shift
                float angle = hash.x * PI2;
                //half2 offset = _RgbShiftIntensity * vibration * half2(cos(angle), sin(angle));
                half2 offset = _RgbShiftIntensity * vibration * half2(1, 1);
                fixed4 cr = tex2D(_MainTex, uv - offset);
                fixed4 cg = tex2D(_MainTex, uv);
                fixed4 cb = tex2D(_MainTex, uv + offset);
                col = half3(cr.r, cg.g, cb.b);

                // noise
                col +=_NoiseIntensity * vibration * hash12(float2(i.uv.y * 20.0, _Beat));

                // flash
                col = mix(col, _FlashColor.rgb, _FlashColor.a * saturate(sin(PI2 * _Beat * _FlashSpeed)));

                // alpha blend
                col = mix(col, _BlendColor.rgb, _BlendColor.a);
                
                // invert
                col = mix(col, 1 - col, step(hash11(i.uv.y * 12) + 0.001, _Invert));

                return fixed4(col, cg.a);
            }
            ENDCG
        }
    }
}
