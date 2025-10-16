#!/bin/bash

docker run -it -v ./workspace:/workspace --gpus all -p 8888:8888 -p 8188:8188 jdelahayes/runpod-comfyui:latest