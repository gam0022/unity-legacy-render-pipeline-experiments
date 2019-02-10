Shader "Unlit/Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Density ("_Density", Float) = 1.0
        _WaveFreq("_WaveFreq", Float) = 100.0
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
            float _WaveFreq;
            
            float2x2 rotate(in float a)
            {
                float s = sin(a), c = cos(a);
                return float2x2(c, s, -s, c);
            }

            v2f vert (appdata v)
            {
                v2f o;
               
                fixed2 uv = v.uv;
                uv.x += 0.1 * sin(8.0 * uv.y + 0.3 * _Time.y);
                uv.y += 0.1 * sin(8.0 * uv.x + 0.3 * _Time.y);
                o.uv = TRANSFORM_TEX(uv, _MainTex);
                
                v.vertex.y += 0.5 * sin(_WaveFreq * uv.x) + 0.5 * sin(_WaveFreq * uv.y);
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
                fixed4 noise2 = tex2D(_MainTex, i.uv + _Time.y * 0.2);
                col.a *= saturate(0.75 + 0.25 * (noise1.r + noise2.r));
                
                return col;
            }
            ENDCG
        }
    }
}
