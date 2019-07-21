Shader "Unlit/Billboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [KeywordEnum(OFF, ALL_AXIS, Y_AXIS)] _BILLBOARD("Billboard Mode", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #pragma multi_compile _BILLBOARD_OFF _BILLBOARD_ALL_AXIS _BILLBOARD_Y_AXIS

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;

                #if _BILLBOARD_OFF
                {
                    o.vertex = UnityObjectToClipPos(v.vertex);
                }
                #elif _BILLBOARD_ALL_AXIS
                {
                    // スケールと回転のみ（平行移動なし）のworldPos
                    float3 scaleRotatePos = mul((float3x3)unity_ObjectToWorld, v.vertex);
                    
                    float3 viewPos = UnityObjectToViewPos(float3(0, 0, 0));
                    
                    // zの符号を反転して右手系に変換
                    viewPos += float3(scaleRotatePos.xy, -scaleRotatePos.z);
                    
                    o.vertex = mul(UNITY_MATRIX_P, float4(viewPos, 1.0));
                }
                #elif _BILLBOARD_Y_AXIS
                {
                    // スケールと回転のみ（平行移動なし）のworldPos
                    float3 scaleRotatePos = mul((float3x3)unity_ObjectToWorld, v.vertex);
                    
                    float3 viewPos = UnityObjectToViewPos(float3(0, 0, 0));
                    
                    float3x3 ViewRotateY = float3x3(
                        1, UNITY_MATRIX_V._m01, 0,
                        0, UNITY_MATRIX_V._m11, 0,
                        0, UNITY_MATRIX_V._m21, -1// zの符号を反転して右手系に変換
                    );
                    viewPos += mul(ViewRotateY, scaleRotatePos);
                    
                    o.vertex = mul(UNITY_MATRIX_P, float4(viewPos, 1.0));
                }
                #endif

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
