FROM ubuntu:24.04 AS base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV SHELL=/bin/bash
ENV PYTHONUNBUFFERED=True
ENV DEBIAN_FRONTEND=noninteractive

# Set the default workspace directory
ENV RP_WORKSPACE=/workspace

# Override the default huggingface cache directory.
ENV HF_HOME="${RP_WORKSPACE}/.cache/huggingface/"

# Faster transfer of models from the hub to the container
ENV HF_HUB_ENABLE_HF_TRANSFER=1
ENV HF_XET_HIGH_PERFORMANCE=1

# modern pip workarounds
ENV PIP_BREAK_SYSTEM_PACKAGES=1
ENV PIP_ROOT_USER_ACTION=ignore

# Set TZ and Locale
ENV TZ=Etc/UTC

WORKDIR /

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Update and upgrade
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install -y --no-install-recommends \
    python3.12 python3.12-venv python3-pip python3-dev \
    curl wget rsync tmux \
    ca-certificates openssh-server \
    zip unzip \
    git git-lfs \
    vim nano \
    libgl1 libglib2.0-0 \
    build-essential gcc \
    ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#Disable Python Externally Managed (May use venv ?)
RUN rm -f /usr/lib/python3.12/EXTERNALLY-MANAGED

# Install uv
RUN pip install uv
# Configure uv to use copy instead of hardlinks
ENV UV_LINK_MODE=copy

# Install jupyterlab and common dependencies
RUN uv pip install --system --no-cache-dir \
    gdown ipykernel \
    jupyterlab jupyterlab-lsp jupyter-server jupyter-server-terminals jupyterlab_code_formatter \
    GitPython numpy pillow opencv-python diffusers huggingface_hub ninja onnx \
    && uv pip install --system --no-cache-dir torch==2.8.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 \
    && uv pip install --system --no-cache-dir https://github.com/mjun0812/flash-attention-prebuild-wheels/releases/download/v0.4.11/flash_attn-2.8.3+cu128torch2.8-cp312-cp312-linux_x86_64.whl \
    && uv cache clean

#FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 AS build_sageattention
#FROM base AS build_sageattention
#COPY sageattention/force_target_12.0.patch /sageattention/force_target.patch
#COPY --chmod=755 sageattention/build_sageattention.sh /sageattention/build_sageattention.sh
#RUN /sageattention/build_sageattention.sh

#FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 AS build_flashattention
#FROM base AS build_flashattention
#COPY --chmod=755 flashattention/build_flashattention.sh /flashattention/build_flashattention.sh
#RUN /flashattention/build_flashattention.sh

FROM base AS comfyui
#COPY --from=build_sageattention /sageattention/SageAttention/dist/sageattention-2.2.0-cp312-cp312-linux_x86_64.whl /sageattention/sageattention-2.2.0-cp312-cp312-linux_x86_64.whl
COPY sageattention/sageattention-2.2.0-cp312-cp312-linux_x86_64.whl /sageattention/sageattention-2.2.0-cp312-cp312-linux_x86_64.whl
RUN uv pip install --system --no-cache-dir /sageattention/sageattention-2.2.0-cp312-cp312-linux_x86_64.whl \
    && uv cache clean

#Install ComfyUI and custom nodes
COPY --chmod=755 comfyui/install_comfyui.sh /install_comfyui.sh
RUN bash /install_comfyui.sh
COPY comfyui/extra_model_paths.yaml /opt/ComfyUI/extra_model_paths.yaml
COPY comfyui/extra_args.txt.template /opt/ComfyUI/extra_args.txt.template

COPY --chmod=755 start.sh /start.sh
CMD ["/start.sh"]