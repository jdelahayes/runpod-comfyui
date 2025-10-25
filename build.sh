#!/bin/bash
sudo docker buildx build --progress=plain -f Dockerfile -t jdelahayes/runpod-comfyui:latest -t jdelahayes/runpod-comfyui:v0.0.4 .

# docker push --all-tags jdelahayes/runpod-comfyui