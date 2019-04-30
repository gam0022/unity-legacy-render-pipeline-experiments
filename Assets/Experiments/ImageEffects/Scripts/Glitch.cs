using System;
using UnityEngine;

namespace Demoscene.ImageEffect
{
    [ExecuteInEditMode]
    public class Glitch : MonoBehaviour
    {
        readonly int alwaysId = Shader.PropertyToID("_Always");
        readonly int glitchUvIntensityId = Shader.PropertyToID("_GlitchUvIntensity");
        readonly int distortionIntensityId = Shader.PropertyToID("_DistortionIntensity");
        readonly int rgbShiftIntensityId = Shader.PropertyToID("_RgbShiftIntensity");
        readonly int noiseIntensityId = Shader.PropertyToID("_NoiseIntensity");
        readonly int flashSpeedId = Shader.PropertyToID("_FlashSpeed");
        readonly int flashColorID = Shader.PropertyToID("_FlashColor");
        readonly int blendColorId = Shader.PropertyToID("_BlendColor");
        readonly int invertId = Shader.PropertyToID("_Invert");
        
        readonly int ifsIterationId = Shader.PropertyToID("_IfsIteration");
        readonly int ifsRateAId = Shader.PropertyToID("_IfsRateA");
        readonly int ifsRateBId = Shader.PropertyToID("_IfsRateB");
        readonly int ifsRateCId = Shader.PropertyToID("_IfsRateC");
        readonly int ifsRateDId = Shader.PropertyToID("_IfsRateD");

        [SerializeField] Material material;
        [SerializeField, Range(0, 1.0f)] float always;
        [SerializeField, Range(0, 0.2f)] float glitchUvIntensity;
        [SerializeField, Range(0, 0.2f)] float distortionIntensity;
        [SerializeField, Range(0, 0.2f)] float rgbShiftIntensity;
        [SerializeField, Range(0, 0.2f)] float noiseIntensity;
        [SerializeField, Range(0, 100f)] float flashSpeed;
        [SerializeField] Color flashColor = Color.clear;
        [SerializeField] Color blendColor = Color.clear;
        [SerializeField, Range(0, 1.0f)] float invert;

        [SerializeField, Range(0, 10.0f)] float ifsIteration;
        [SerializeField, Range(0, 1.0f)] float ifsRateA;
        [SerializeField, Range(0, 1.0f)] float ifsRateB;
        [SerializeField, Range(0, 1.0f)] float ifsRateC;
        [SerializeField, Range(0, 2.0f)] float ifsRateD;

        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            material.SetFloat(alwaysId, always);
            material.SetFloat(glitchUvIntensityId, glitchUvIntensity);
            material.SetFloat(distortionIntensityId, distortionIntensity);
            material.SetFloat(rgbShiftIntensityId, rgbShiftIntensity);
            material.SetFloat(noiseIntensityId, noiseIntensity);
            material.SetFloat(flashSpeedId, flashSpeed);
            material.SetColor(flashColorID, flashColor);
            material.SetColor(blendColorId, blendColor);
            material.SetFloat(invertId, invert);
            
            material.SetFloat(ifsIterationId, ifsIteration);
            material.SetFloat(ifsRateAId, ifsRateA);
            material.SetFloat(ifsRateBId, ifsRateB);
            material.SetFloat(ifsRateCId, ifsRateC);
            material.SetFloat(ifsRateDId, ifsRateD);

            Graphics.Blit(source, destination, material);
        }
    }
}

