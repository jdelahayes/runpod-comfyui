#!/bin/bash
sudo docker buildx build --progress=plain -f Dockerfile -t jdelahayes/runpod-comfyui:latest -t jdelahayes/runpod-comfyui:v0.0.6-beta . 2>&1 | tee build.log

# docker push --all-tags jdelahayes/runpod-comfyui
