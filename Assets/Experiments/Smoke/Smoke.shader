Shader "Unlit/Smoke"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Density ("Density", Range(0, 0.5)) = 1.0
        _DepthRate("Depth Rate", Range(0, 1)) = 0.8
        
        _WaveFreq("WaveFreq", Range(0, 100)) = 100.0
        _WaveAmplitude("Wave Amplitude", Range(0, 1)) = 0.5
        _WaveSpeed("Wave Speed", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 projPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            sampler2D _CameraDepthTexture;
            float4 _CameraDepthTexture_ST;
            
            float _Density;
            float _DepthRate;
            
            float _WaveFreq;
            float _WaveAmplitude;
            float _WaveSpeed;

            v2f vert (appdata v)
            {
                v2f o;
               
                fixed2 uv = v.uv;
                uv.x += 0.1 * sin(8.0 * uv.y + _WaveSpeed * _Time.y);
                uv.y += 0.1 * sin(8.0 * uv.x + _WaveSpeed * _Time.y);
                o.uv = TRANSFORM_TEX(uv, _MainTex);
                
                v.vertex.y += _WaveAmplitude * (sin(_WaveFreq * uv.x) + sin(_WaveFreq * uv.y));
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.projPos = ComputeScreenPos(o.vertex);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _Color;
 
                float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
                float partZ = i.projPos.z;
                col.a = clamp(col.a * _Density * (sceneZ - partZ), 0.05, 0.8);
                
                fixed4 noise1 = tex2D(_MainTex, i.uv);
                
                i.uv.x += 0.1 * sin(8.0 * i.uv.y + 4.0 * _WaveSpeed * _Time.y);
                i.uv.y += 0.1 * sin(8.0 * i.uv.x + 4.0 * _WaveSpeed * _Time.y);
                fixed4 noise2 = tex2D(_MainTex, i.uv);
                
                col.a *= saturate(_DepthRate + 0.5 * (1.0 - _DepthRate) * (noise1.r + noise2.r));
                
                return col;
            }
            ENDCG
        }
    }
}
