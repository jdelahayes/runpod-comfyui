#!/bin/bash
set -e  # Exit the script if any statement returns a non-true return value

RP_WORKSPACE="/workspace"
COMFYUI_DIR="/opt/ComfyUI"

#If missing workspace volume
mkdir -p $RP_WORKSPACE

#ComfyUI extra paths
mkdir -p $RP_WORKSPACE/models/checkpoints
mkdir -p $RP_WORKSPACE/models/clip
mkdir -p $RP_WORKSPACE/models/clip_vision
mkdir -p $RP_WORKSPACE/models/configs
mkdir -p $RP_WORKSPACE/models/controlnet
mkdir -p $RP_WORKSPACE/models/diffusion_models
mkdir -p $RP_WORKSPACE/models/unet
mkdir -p $RP_WORKSPACE/models/embeddings
mkdir -p $RP_WORKSPACE/models/loras
mkdir -p $RP_WORKSPACE/models/upscale_models
mkdir -p $RP_WORKSPACE/models/vae
mkdir -p $RP_WORKSPACE/models/text_encoders

echo "Starting Jupyter Lab on port 8888..."
nohup jupyter lab \
    --allow-root \
    --no-browser \
    --port=8888 \
    --ip=0.0.0.0 \
    --FileContentsManager.delete_to_trash=False \
    --FileContentsManager.preferred_dir=$RP_WORKSPACE \
    --ServerApp.root_dir=$RP_WORKSPACE \
    --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' \
    --IdentityProvider.token="${JUPYTER_PASSWORD:-}" \
    --ServerApp.allow_origin=* &> $RP_WORKSPACE/jupyter.log &
echo "Jupyter Lab started"

# Create default comfyui_args.txt if it doesn't exist
ARGS_FILE="$RP_WORKSPACE/comfyui_args.txt"
if [ ! -f "$ARGS_FILE" ]; then
    echo "# Add your custom ComfyUI arguments here (one per line)" > "$ARGS_FILE"
    echo "Created empty ComfyUI arguments file at $ARGS_FILE"
fi

# Start ComfyUI with custom arguments if provided
cd $COMFYUI_DIR
FIXED_ARGS="--listen 0.0.0.0 --port 8188 --disable-auto-launch --use-sage-attention" 
#--output-directory --input-directory --user-directory --temp-directory --base-directory --extra-model-paths-config

if [ -s "$ARGS_FILE" ]; then
    # File exists and is not empty, combine fixed args with custom args
    CUSTOM_ARGS=$(grep -v '^#' "$ARGS_FILE" | tr '\n' ' ')
    if [ ! -z "$CUSTOM_ARGS" ]; then
        echo "Starting ComfyUI with additional arguments: $CUSTOM_ARGS"
        nohup python3.12 main.py $FIXED_ARGS $CUSTOM_ARGS &> $RP_WORKSPACE/comfyui.log &
    else
        echo "Starting ComfyUI with default arguments"
        nohup python3.12 main.py $FIXED_ARGS &> $RP_WORKSPACE/comfyui.log &
    fi
else
    # File is empty, use only fixed args
    echo "Starting ComfyUI with default arguments"
    nohup python3.12 main.py $FIXED_ARGS &> $RP_WORKSPACE/comfyui.log &
fi

# Tail the log file
tail -f $RP_WORKSPACE/comfyui.log
