#!/bin/bash
sudo docker buildx build --progress=plain -f Dockerfile -t jdelahayes/runpod-comfyui:latest .
