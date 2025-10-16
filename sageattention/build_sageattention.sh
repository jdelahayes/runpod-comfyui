#!/bin/bash
set -e  # Exit the script if any statement returns a non-true return value

#Install CUDA 12.8
echo "Install CUDA 12.8 ..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
apt-get update
apt-get install -y --no-install-recommends cuda-toolkit-12-8 git python3.12 python3.12-venv python3-pip python3-dev

#Install SageAttention
echo "Build SageAttention ..."
cd /sageattention
git clone https://github.com/thu-ml/SageAttention.git
cd SageAttention 

# python3.12 -m venv .venv
# source .venv/bin/activate
# pip install --no-cache-dir packaging setuptools torch

# Patch to set Target GPU Architectures
patch setup.py < ../force_target.patch

export EXT_PARALLEL=4 NVCC_APPEND_FLAGS="--threads 8" MAX_JOBS=32
python3.12 setup.py bdist_wheel
