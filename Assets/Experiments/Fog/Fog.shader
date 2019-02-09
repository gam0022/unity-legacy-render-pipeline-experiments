Shader "Unlit/Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
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
                half4 spos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            sampler2D _CameraDepthTexture;
            float4 _CameraDepthTexture_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.spos = ComputeScreenPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed depth = UNITY_SAMPLE_DEPTH(tex2D(_MainTex, i.spos));
                return fixed4(depth, depth, depth, 0.8);
                
                
                // sample the texture
                fixed4 col = _Color;
                
                //fixed4 depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.spos));
                //col.a = depth;
                return col;
            }
            ENDCG
        }
    }
}
