# syntax=docker/dockerfile:1

# 基础镜像使用官方预构建版本
ARG OPENCLAW_BASE_TAG=latest
FROM ghcr.io/openclaw/openclaw:${OPENCLAW_BASE_TAG}

# 使用官方构建参数安装额外 apt 包和扩展依赖
# OPENCLAW_DOCKER_APT_PACKAGES: 额外的 apt 包（空格分隔）
# OPENCLAW_EXTENSIONS: 预装的扩展名（空格分隔）
ARG OPENCLAW_DOCKER_APT_PACKAGES="git curl jq ffmpeg"
ARG OPENCLAW_EXTENSIONS=""

# 官方镜像已处理 apt 安装，只需确保目录权限
USER root
RUN mkdir -p /var/lib/apt/lists/partial && \
    chmod 755 /var/lib/apt/lists && \
    chmod 755 /var/lib/apt/lists/partial

# 扩展依赖由镜像构建时处理
RUN chown -R node:node /home/node
USER node