﻿using UnityEngine;

public class CameraDepthTextureEnabler : MonoBehaviour {

    [SerializeField]
    private Shader _shader;
    private Material _material;

    void Start () {
        // たとえばライトのShadow TypeがNo Shadowsのときなどに
        // これが設定されていないとデプステクスチャが生成されない
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;

        //_material = new Material(_shader);
    }

    /*private void OnRenderImage(RenderTexture source, RenderTexture dest)
    {
        Graphics.Blit(source, dest, _material);
    }*/
}