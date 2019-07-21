Shader "Unlit/Billboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [KeywordEnum(OFF, ALL_AXIS, Y_AXIS)] _BILLBOARD("Billboard Mode", Float) = 1
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags{ "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" "IgnoreProjector" = "True" }

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
            
            float _Cutoff;

            v2f vert (appdata v)
            {
                v2f o;

                #if _BILLBOARD_OFF
                {
                    // ビルボードなしの通常の座標変換
                    o.vertex = UnityObjectToClipPos(v.vertex);
                }
                #elif _BILLBOARD_ALL_AXIS
                {                   
                    // Meshの原点をModelView変換
                    float3 viewPos = UnityObjectToViewPos(float3(0, 0, 0));
                    
                    // スケールと回転（平行移動なし）だけModel変換して、View変換はスキップ
                    float3 scaleRotatePos = mul((float3x3)unity_ObjectToWorld, v.vertex);
                    
                    // scaleRotatePosを右手系に変換して、viewPosに加算
                    // 本来はView変換で暗黙的にZが反転されているので、View変換をスキップする場合は明示的にZを反転する必要がある
                    viewPos += float3(scaleRotatePos.xy, -scaleRotatePos.z);
                    
                    o.vertex = mul(UNITY_MATRIX_P, float4(viewPos, 1.0));
                }
                #elif _BILLBOARD_Y_AXIS
                {
                    // Meshの原点をModelView変換
                    float3 viewPos = UnityObjectToViewPos(float3(0, 0, 0));
                    
                    // スケールと回転（平行移動なし）だけModel変換して、View変換はスキップ
                    float3 scaleRotatePos = mul((float3x3)unity_ObjectToWorld, v.vertex);                
                    
                    // View行列からY軸の回転だけ抽出した行列を生成
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
                clip(col.a - _Cutoff);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
