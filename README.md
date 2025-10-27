# runpod-comfyui

## Versions

| Component | Version | Comment|
| --- | --- | --- |
| **Ubuntu** | 24.04 ||
| **Python** | 3.12 ||
| **CUDA** | 12.8 ||
| **torch** | 2.8.0 ||
| **COMFYUI** | v0.3.66 ||
| **Sage Attention** | latest at build time | Compiled for 12.0 Architecture (RTX5090) by default (see Dockerfile)|
| **FlashAttention**|v2.8.3||
| **Jupyter Labs** | latest at build time ||

## COMFYUI CUSTOM NODES

[ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes)  
[ComfyUI-WanVideoWrapper](https://github.com/kijai/ComfyUI-WanVideoWrapper)  
[ComfyUI-Crystools](https://github.com/crystian/ComfyUI-Crystools)  
[KayTool](https://github.com/kk8bit/KayTool)  
[ComfyUI-Custom-Scripts](https://github.com/yolain/ComfyUI-Easy-Use)  
[ComfyUI-Custom-Scripts](https://github.com/pythongosssss/ComfyUI-Custom-Scripts)  
[ComfyUI-VideoHelperSuite](https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite)  
[rgthree-comfy](https://github.com/rgthree/rgthree-comfy)  
[ComfyUI-Impact-Pack](https://github.com/ltdrdata/ComfyUI-Impact-Pack)  
[ComfyUI-GGUF](https://github.com/city96/ComfyUI-GGUF)  
[ComfyUI-SeedVR2_VideoUpscaler (nightly)](https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler)  
[ComfyUI-mxToolkit](https://github.com/Smirnov75/ComfyUI-mxToolkit)  
[ComfyUI-basic_data_handling](https://github.com/StableLlama/ComfyUI-basic_data_handling)  
[ComfyUI_Comfyroll_CustomNodes](https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes)  
[RES4LYF](https://github.com/ClownsharkBatwing/RES4LYF)  

## Build

```
docker buildx build --progress=plain -f Dockerfile -t jdelahayes/runpod-comfyui:latest -t jdelahayes/runpod-comfyui:vx.x.x .
```

## Usage

```
docker run -it -v ./workspace:/workspace --gpus all -p 8888:8888 -p 8188:8188 jdelahayes/runpod-comfyui:latest
```