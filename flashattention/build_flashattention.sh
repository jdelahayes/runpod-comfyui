#!/bin/bash
set -e  # Exit the script if any statement returns a non-true return value

apt update
apt install git python3.12 python3.12-dev python3.12-venv

git clone https://github.com/Dao-AILab/flash-attention
cd flash-attention/hopper/
python3.12 -m venv .venv
source .venv/bin/activate
pip install setuptools packaging
pip install torch==2.8.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
pip install ninja

python3.12 setup.py bdist_wheel
