# 基于官方预构建镜像，安装额外工具
FROM ghcr.io/openclaw/openclaw:latest

USER root

# 安装额外 apt 包
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl jq ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 安装 Playwright Chromium（browser automation）
RUN mkdir -p /home/node/.cache/ms-playwright && \
    PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright \
    node /app/node_modules/playwright-core/cli.js install --with-deps chromium && \
    chown -R node:node /home/node/.cache/ms-playwright

RUN chown -R node:node /home/node
USER node