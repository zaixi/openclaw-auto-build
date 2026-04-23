# 基于官方预构建镜像，添加扩展工具
FROM ghcr.io/openclaw/openclaw:latest

USER root

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright

# 安装额外工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    chromium \
    curl \
    ffmpeg \
    fonts-liberation \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    git \
    gosu \
    jq \
    locales \
    openssh-client \
    procps \
    unzip \
    docker-ce-cli \
    docker-compose-plugin && \
    sed -i 's/^# *en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    printf 'LANG=en_US.UTF-8\nLANGUAGE=en_US:en\nLC_ALL=en_US.UTF-8\n' > /etc/default/locale && \
    git config --system url."https://github.com/".insteadOf ssh://git@github.com/ && \
    rm -rf /var/lib/apt/lists/*

# 全局 Node 工具
RUN npm install -g \
    clawhub \
    playwright \
    playwright-extra \
    puppeteer-extra-plugin-stealth && \
    npm cache clean --force

# 安装 Homebrew（可选但有用）
RUN git clone --depth 1 https://github.com/Homebrew/brew /opt/homebrew-linux && \
    mkdir -p /opt/homebrew-linux/bin && \
    ln -sf /opt/homebrew-linux/bin/brew /usr/local/bin/brew && \
    chown -R node:node /opt/homebrew-linux

# 持久化目录
RUN mkdir -p \
    /home/node/.openclaw \
    /home/node/.openclaw/extensions \
    /home/node/.openclaw/workspace \
    /home/node/.cache/ms-playwright && \
    chown -R node:node /home/node

# entrypoint
COPY --chown=root:root docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 切换回 node 用户
RUN chown -R node:node /home/node
USER node

# 默认工作目录
WORKDIR /home/node

# 保留官方入口并优先用自定义 entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]