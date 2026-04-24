# 基于官方预构建镜像，添加扩展工具
FROM ghcr.io/openclaw/openclaw:latest

USER root

# ──────────────── 构建参数（来自 build.conf）────────────────
ARG OPENCLAW_APT_PACKAGES=""
ARG OPENCLAW_NPM_PACKAGES=""
ARG OPENCLAW_PIP_PACKAGES=""
ARG OPENCLAW_EXTENSIONS=""
ARG OPENCLAW_NPM_REGISTRY=""
ARG OPENCLAW_PIP_INDEX_URL=""

# ──────────────── 环境变量 ────────────────
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Shanghai \
    PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright \
    OPENCLAW_EXTENSIONS="${OPENCLAW_EXTENSIONS}" \
    NPM_CONFIG_REGISTRY="${OPENCLAW_NPM_REGISTRY:-https://registry.npmmirror.com}" \
    PIP_INDEX_URL="${OPENCLAW_PIP_INDEX_URL:-https://pypi.npmmirror.com}" \
    NODE_PATH=/usr/local/lib/node_modules \
    PATH="/usr/local/bin:/usr/local/lib/node_modules/.bin:${PATH}"

# ──────────────── apt + pip + npm（统一层）────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        ${OPENCLAW_APT_PACKAGES} \
    && sed -i 's/^# *en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && printf 'LANG=en_US.UTF-8\nLANGUAGE=en_US:en\nLC_ALL=en_US.UTF-8\n' > /etc/default/locale \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && printf 'Asia/Shanghai\n' > /etc/timezone \
    && git config --system url."https://github.com/".insteadOf ssh://git@github.com/ \
    && ln -sf /usr/bin/python3 /usr/local/bin/python \
    && rm -rf /var/lib/apt/lists/* \
    && if [ -n "${OPENCLAW_PIP_PACKAGES}" ]; then \
        pip3 config set global.index-url "${PIP_INDEX_URL:-https://pypi.npmmirror.com}" \
        && pip3 install ${OPENCLAW_PIP_PACKAGES} \
        && pip cache purge; \
    fi \
    && if [ -n "${OPENCLAW_NPM_REGISTRY}" ]; then npm config set registry "${OPENCLAW_NPM_REGISTRY}"; fi \
    && if [ -n "${OPENCLAW_NPM_PACKAGES}" ]; then \
        npm install -g ${OPENCLAW_NPM_PACKAGES} \
        && npm cache clean --force; \
    fi

# ──────────────── Homebrew ────────────────
RUN git clone --depth 1 https://github.com/Homebrew/brew /opt/homebrew-linux \
    && mkdir -p /opt/homebrew-linux/bin \
    && ln -sf /opt/homebrew-linux/bin/brew /usr/local/bin/brew \
    && chown -R node:node /opt/homebrew-linux

# ──────────────── 持久化目录 + entrypoint ────────────────
COPY --chown=root:root docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh \
    && mkdir -p \
        /home/node/.openclaw \
        /home/node/.openclaw/extensions \
        /home/node/.openclaw/workspace \
        /home/node/.cache/ms-playwright \
    && chown -R node:node /home/node

USER node
WORKDIR /home/node

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
