# 基于官方预构建镜像，添加扩展工具
FROM ghcr.io/openclaw/openclaw:latest

USER root

# ──────────────── 构建参数（来自 build.conf）────────────────
ARG OPENCLAW_DOCKER_APT_PACKAGES=""
ARG OPENCLAW_EXTENSIONS=""
ARG OPENCLAW_INSTALL_DOCKER_CLI="0"
ARG OPENCLAW_INSTALL_BROWSER="0"
ARG OPENCLAW_NPM_REGISTRY=""
ARG OPENCLAW_PIP_INDEX_URL=""
ARG OPENCLAW_PIP_PACKAGES=""

# ──────────────── 环境变量 ────────────────
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Shanghai \
    PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright \
    NPM_CONFIG_REGISTRY="${OPENCLAW_NPM_REGISTRY:-https://registry.npmmirror.com}" \
    PIP_INDEX_URL="${OPENCLAW_PIP_INDEX_URL:-https://pypi.npmmirror.com}"

# ──────────────── 基础工具 ────────────────
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
    gnupg \
    jq \
    locales \
    openssh-client \
    procps \
    python3 \
    python3-pip \
    python3-venv \
    socat \
    tini \
    unzip \
    tzdata \
    ${OPENCLAW_DOCKER_APT_PACKAGES} && \
    sed -i 's/^# *en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    printf 'LANG=en_US.UTF-8\nLANGUAGE=en_US:en\nLC_ALL=en_US.UTF-8\n' > /etc/default/locale && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    printf 'Asia/Shanghai\n' > /etc/timezone && \
    git config --system url."https://github.com/".insteadOf ssh://git@github.com/ && \
    ln -sf /usr/bin/python3 /usr/local/bin/python && \
    rm -rf /var/lib/apt/lists/*

# ──────────────── Docker CLI ────────────────
RUN if [ "${OPENCLAW_INSTALL_DOCKER_CLI}" = "1" ]; then \
        apt-get update && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin && \
        rm -rf /var/lib/apt/lists/*; \
    fi

# ──────────────── Chromium 浏览器 ────────────────
RUN if [ "${OPENCLAW_INSTALL_BROWSER}" = "1" ]; then \
        apt-get update && apt-get install -y --no-install-recommends chromium && \
        rm -rf /var/lib/apt/lists/*; \
    fi

# ──────────────── pip 包（npmmirror 加速）───────────────
RUN if [ -n "${OPENCLAW_PIP_PACKAGES}" ]; then \
        pip3 config set global.index-url "${PIP_INDEX_URL:-https://pypi.npmmirror.com}" && \
        pip3 install ${OPENCLAW_PIP_PACKAGES} && \
        pip cache purge; \
    fi

# ──────────────── 全局 Node 工具（npmmirror 加速）───────────────
RUN if [ -n "${OPENCLAW_NPM_REGISTRY}" ]; then \
        npm config set registry "${OPENCLAW_NPM_REGISTRY}"; \
    fi && \
    npm install -g \
    clawhub \
    playwright \
    playwright-extra \
    puppeteer-extra-plugin-stealth && \
    npm cache clean --force

# ──────────────── Homebrew（可选但有用）───────────────
RUN git clone --depth 1 https://github.com/Homebrew/brew /opt/homebrew-linux && \
    mkdir -p /opt/homebrew-linux/bin && \
    ln -sf /opt/homebrew-linux/bin/brew /usr/local/bin/brew && \
    chown -R node:node /opt/homebrew-linux

# ──────────────── 预装扩展 ────────────────
RUN if [ -n "${OPENCLAW_EXTENSIONS}" ]; then \
        for ext in ${OPENCLAW_EXTENSIONS}; do \
            openclaw extension install "$ext" || true; \
        done; \
    fi

# ──────────────── 持久化目录 ────────────────
RUN mkdir -p \
    /home/node/.openclaw \
    /home/node/.openclaw/extensions \
    /home/node/.openclaw/workspace \
    /home/node/.cache/ms-playwright && \
    chown -R node:node /home/node

# ──────────────── entrypoint ────────────────
COPY --chown=root:root docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ──────────────── 切换回 node 用户 ────────────────
RUN chown -R node:node /home/node
USER node

WORKDIR /home/node

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
