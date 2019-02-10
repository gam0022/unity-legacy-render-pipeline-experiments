Shader "Unlit/Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _InvFade ("_InvFade", Float) = 1.0
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
            
            float _InvFade;
            float _WaveFreq;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                v.vertex.y += 0.5 * sin(_WaveFreq * v.uv.x + 3.0 * _Time.y) + 0.5 * sin(_WaveFreq * v.uv.y + 3.0 * _Time.y);
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
    
                float fade = saturate(_InvFade * (sceneZ - partZ));
                col.a *= fade;
 
                return col;
            }
            ENDCG
        }
    }
}
