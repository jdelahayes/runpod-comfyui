FROM ubuntu:24.04 AS base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV SHELL=/bin/bash
ENV PYTHONUNBUFFERED=True
ENV DEBIAN_FRONTEND=noninteractive

# Set the default workspace directory
ENV RP_WORKSPACE=/workspace

# Override the default huggingface cache directory.
ENV HF_HOME="${RP_WORKSPACE}/.cache/huggingface/"

# Shared python package cache
ENV VIRTUALENV_OVERRIDE_APP_DATA="${RP_WORKSPACE}/.cache/virtualenv/"
ENV PIP_CACHE_DIR="${RP_WORKSPACE}/.cache/pip/"
ENV UV_CACHE_DIR="${RP_WORKSPACE}/.cache/uv/"

# Faster transfer of models from the hub to the container
ENV HF_HUB_ENABLE_HF_TRANSFER=1
ENV HF_XET_HIGH_PERFORMANCE=1

# modern pip workarounds
ENV PIP_BREAK_SYSTEM_PACKAGES=1
ENV PIP_ROOT_USER_ACTION=ignore

# Set TZ and Locale
ENV TZ=Etc/UTC

WORKDIR /

# Update and upgrade
RUN apt-get update --yes && \
    apt-get upgrade --yes

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# Install python 3.12, jupyterlab and common dependencies
RUN pip install --no-cache-dir \
    gdown ipykernel \
    jupyterlab jupyterlab-lsp jupyter-server jupyter-server-terminals jupyterlab_code_formatter \
    GitPython numpy pillow opencv-python diffusers huggingface_hub[cli] ninja onnx \
    && pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 \
    && pip install --no-cache-dir https://github.com/mjun0812/flash-attention-prebuild-wheels/releases/download/v0.4.11/flash_attn-2.8.3+cu128torch2.8-cp312-cp312-linux_x86_64.whl \
    && pip cache purge

#FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 AS build_sageattention
FROM base AS build_sageattention
COPY sageattention/force_target_12.0.patch /sageattention/force_target.patch
COPY --chmod=755 sageattention/build_sageattention.sh /sageattention/build_sageattention.sh
RUN /sageattention/build_sageattention.sh

FROM base AS comfyui
COPY --from=build_sageattention /sageattention/SageAttention/dist/sageattention-2.2.0-cp312-cp312-linux_x86_64.whl /sageattention/sageattention-2.2.0-cp312-cp312-linux_x86_64.whl
RUN pip install --no-cache-dir /sageattention/sageattention-2.2.0-cp312-cp312-linux_x86_64.whl

#Install ComfyUI and custom nodes
COPY --chmod=755 comfyui/install_comfyui.sh /install_comfyui.sh
RUN bash /install_comfyui.sh
COPY comfyui/extra_model_paths.yaml /opt/ComfyUI/extra_model_paths.yaml

COPY --chmod=755 start.sh /start.sh
CMD ["/start.sh"]