# 基于 node:24-slim，从 npm 直接安装 openclaw（避免官方预构建镜像的体积）
FROM node:24-slim

# 从 Python 官方镜像拷贝 Python 3.12 (确保使用与 node 镜像一致的 Debian Bookworm 版本)
COPY --from=python:3.12-slim-bookworm /usr/local /usr/local

WORKDIR /app
ENV BUN_INSTALL="/usr/local" \
    PATH="/usr/local/bin:$PATH" \
    DEBIAN_FRONTEND=noninteractive

# ──────────────── 系统依赖安装 ────────────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    chromium \
    curl \
    docker.io \
    build-essential \
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
    socat \
    tini \
    unzip && \
    sed -i 's/^# *en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    printf 'LANG=en_US.UTF-8\nLANGUAGE=en_US:en\nLC_ALL=en_US.UTF-8\n' > /etc/default/locale && \
    git config --system url."https://github.com/".insteadOf ssh://git@github.com/ && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    printf 'Asia/Shanghai\n' > /etc/timezone && \
    ln -sf /usr/local/bin/python3 /usr/local/bin/python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /root/.npm /root/.cache

# ──────────────── 工具安装（bun/uv/websockify/qmd）────────────────
RUN curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash && \
    curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh && \
    /usr/local/bin/python3 -m pip install --no-cache-dir websockify && \
    npm config set registry https://registry.npmmirror.com && \
    npm install -g opencode-ai@latest clawhub playwright playwright-extra puppeteer-extra-plugin-stealth @tobilu/qmd@1.1.6 && \
    npx playwright install chromium --with-deps && \
    npm cache clean --force

# ──────────────── Homebrew ────────────────
RUN mkdir -p /home/node/.linuxbrew/Homebrew && \
    git clone --depth 1 https://github.com/Homebrew/brew /home/node/.linuxbrew/Homebrew && \
    mkdir -p /home/node/.linuxbrew/bin && \
    ln -s /home/node/.linuxbrew/Homebrew/bin/brew /home/node/.linuxbrew/bin/brew && \
    chown -R node:node /home/node/.linuxbrew

# ──────────────── 用户目录与插件 seed ────────────────
RUN mkdir -p /home/node/.openclaw/workspace /home/node/.openclaw/extensions /home/node/.cache/ms-playwright && \
    chown -R node:node /home/node

USER node
ENV HOME=/home/node

# ──────────────── 插件预装（构建时 seed进去）───────────────
ARG OPENCLAW_SEED_EXTENSIONS=""
ARG CLAWHUB_TOKEN=""
RUN if [ -n "$CLAWHUB_TOKEN" ]; then clawhub login --token "$CLAWHUB_TOKEN"; fi && \
    mkdir -p /home/node/.openclaw/extensions && \
    if echo "$OPENCLAW_SEED_EXTENSIONS" | grep -q "napcat"; then \
        cd /home/node/.openclaw/extensions && \
        git clone --depth 1 -b v4.17.25 https://github.com/Daiyimo/openclaw-napcat.git napcat && \
        cd napcat && npm install --production && \
        timeout 300 openclaw plugins install --dangerously-force-unsafe-install -l . || true; \
    fi && \
    if echo "$OPENCLAW_SEED_EXTENSIONS" | grep -q "dingtalk"; then \
        timeout 300 openclaw plugins install --dangerously-force-unsafe-install @soimy/dingtalk || true; \
    fi && \
    if echo "$OPENCLAW_SEED_EXTENSIONS" | grep -q "@tencent-connect/openclaw-qqbot"; then \
        timeout 300 openclaw plugins install --dangerously-force-unsafe-install @tencent-connect/openclaw-qqbot@latest || true; \
    fi && \
    if echo "$OPENCLAW_SEED_EXTENSIONS" | grep -q "@tencent-weixin/openclaw-weixin-cli"; then \
        timeout 300 openclaw plugins install --dangerously-force-unsafe-install @tencent-weixin/openclaw-weixin-cli || true; \
    fi && \
    if echo "$OPENCLAW_SEED_EXTENSIONS" | grep -q "sunnoy"; then \
        timeout 300 openclaw plugins install --dangerously-force-unsafe-install @sunnoy/wecom || true; \
    fi && \
    find /home/node/.openclaw/extensions -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true

# 把预装的 extensions 固化到 seed 目录
RUN mkdir -p /home/node/.openclaw-seed && \
    cp -a /home/node/.openclaw/extensions /home/node/.openclaw-seed/ && \
    printf '%s\n' "latest" > /home/node/.openclaw-seed/extensions/.seed-version && \
    rm -rf /tmp/* /home/node/.npm /home/node/.cache

# ──────────────── 最终配置 ────────────────
USER root

COPY ./init.sh /usr/local/bin/init.sh
RUN sed -i 's/\r$//' /usr/local/bin/init.sh && \
    chmod +x /usr/local/bin/init.sh

ENV HOME=/home/node \
    TERM=xterm-256color \
    NODE_PATH=/usr/local/lib/node_modules \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    NODE_ENV=production \
    PATH="/home/node/.linuxbrew/bin:/home/node/.linuxbrew/sbin:/usr/local/lib/node_modules/.bin:${PATH}" \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright

EXPOSE 18789
WORKDIR /home/node

ENTRYPOINT ["/bin/bash", "/usr/local/bin/init.sh"]