Shader "Unlit/Billboard-Y-axis"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

                // Y軸のビルボード
                /*float3x3 ViewOnlyYRotate = float3x3(
                    UNITY_MATRIX_V._m00, UNITY_MATRIX_V._m01, UNITY_MATRIX_V._m02,
                    UNITY_MATRIX_V._m10, UNITY_MATRIX_V._m11, UNITY_MATRIX_V._m12,
                    UNITY_MATRIX_V._m20, UNITY_MATRIX_V._m21, UNITY_MATRIX_V._m22,
                );*/
                /*float3x3 ViewOnlyYRotate = float3x3(
                    1, UNITY_MATRIX_V._m01, UNITY_MATRIX_V._m02,
                    0, UNITY_MATRIX_V._m11, UNITY_MATRIX_V._m12,
                    0, UNITY_MATRIX_V._m21, UNITY_MATRIX_V._m22
                );*/
                float3x3 ViewOnlyYRotate = float3x3(
                    1, UNITY_MATRIX_V._m01, 0,
                    0, UNITY_MATRIX_V._m11, 0,
                    0, UNITY_MATRIX_V._m21, -1
                );

                float3 viewPos = UnityObjectToViewPos(float3(0.0, 0.0, 0.0)) + mul(ViewOnlyYRotate, v.vertex);
                o.vertex = mul(UNITY_MATRIX_P, float4(viewPos, 1.0));

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
