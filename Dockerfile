# syntax=docker/dockerfile:1

# 基础镜像使用官方预构建版本
ARG OPENCLAW_BASE_TAG=latest
FROM ghcr.io/openclaw/openclaw:${OPENCLAW_BASE_TAG}

# 在这里安装你需要的包
# 官方镜像是 node:24-bookworm，可以 apt install
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl jq ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 注意：OPENCLAW_EXTENSIONS 可以用来预装扩展依赖
# RUN --mount-type=tmpfs,target=/root/.npm \
#     OPENCLAW_EXTENSIONS="extension-name" && openclawctl install

USER root
RUN chown -R node:node /home/node
USER node