# syntax=docker/dockerfile:1

# 基础镜像使用官方预构建版本
ARG OPENCLAW_BASE_TAG=latest
FROM ghcr.io/openclaw/openclaw:${OPENCLAW_BASE_TAG}

USER root

# 确保 apt 缓存目录存在且可写
RUN mkdir -p /var/lib/apt/lists/partial && \
    chmod 755 /var/lib/apt/lists && \
    chmod 755 /var/lib/apt/lists/partial

# 在这里安装你需要的包
# 官方镜像是 node:24-bookworm，可以 apt install
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl jq ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN chown -R node:node /home/node
USER node