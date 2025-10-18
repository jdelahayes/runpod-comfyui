#!/bin/bash
set -e  # Exit the script if any statement returns a non-true return value

COMFYUI_DIR="/opt/ComfyUI"
COMFYUI_TAG="v0.3.65"

CUSTOM_NODES=(
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper"
    "https://github.com/crystian/ComfyUI-Crystools"
    "https://github.com/kk8bit/KayTool"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
)

# Clone ComfyUI if not present
echo "Cloning ComfyUI ..."
mkdir -p "$COMFYUI_DIR"
git clone --depth 1 -b $COMFYUI_TAG https://github.com/comfyanonymous/ComfyUI.git $COMFYUI_DIR

# Install ComfyUI-Manager
echo "Cloning ComfyUI-Manager ..."
mkdir -p "$COMFYUI_DIR/custom_nodes"
cd "$COMFYUI_DIR/custom_nodes"
git clone --depth 1 -b main https://github.com/ltdrdata/ComfyUI-Manager.git

for repo in "${CUSTOM_NODES[@]}"; do
    repo_name=$(basename "$repo")
    echo "Cloning $repo_name ..."
    cd "$COMFYUI_DIR/custom_nodes"
    git clone --depth 1 "$repo"
done

# Install comfyUI requirements
echo "Install ComfyUI requirements ..."
cd "$COMFYUI_DIR"
pip install --no-cache-dir -r requirements.txt

# Install custom nodes
for node_dir in $COMFYUI_DIR/custom_nodes/*; do

    if [ -d "$node_dir" ]; then

        cd "$node_dir"
        
        # Check for requirements.txt
        if [ -f "requirements.txt" ]; then
            echo "Installing requirements.txt for $node_dir ..."
            pip install --no-cache-dir -r requirements.txt
        fi
        
        # Check for install.py
        if [ -f "install.py" ]; then
            echo "Running install.py for $node_dir ..."
            python install.py
        fi
        
        # Check for setup.py
        if [ -f "setup.py" ]; then
            echo "Running setup.py for $node_dir ..."
            pip install --no-cache-dir -e .
        fi
    fi
done

pip cache purge