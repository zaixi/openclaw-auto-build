#!/usr/bin/env bash
set -euo pipefail

export HOME=/home/node
export LANG="${LANG:-en_US.UTF-8}"
export LANGUAGE="${LANGUAGE:-en_US:en}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export TZ="${TZ:-Asia/Shanghai}"
export PLAYWRIGHT_BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-/home/node/.cache/ms-playwright}"

# 持久化目录
mkdir -p \
    /home/node/.openclaw \
    /home/node/.openclaw/extensions \
    /home/node/.openclaw/workspace \
    /home/node/.cache/ms-playwright

chown -R node:node /home/node/.openclaw /home/node/.cache 2>/dev/null || true

# 启动时检查并安装扩展（OPENCLAW_EXTENSIONS 以空格分隔）
if [ -n "${OPENCLAW_EXTENSIONS:-}" ]; then
    for ext in ${OPENCLAW_EXTENSIONS}; do
        if [ -d "/home/node/.openclaw/extensions/$ext" ]; then
            echo "[entrypoint] extension already installed: $ext"
        else
            echo "[entrypoint] installing extension: $ext"
            openclaw extension install "$ext" || echo "[entrypoint] failed to install: $ext"
        fi
    done
fi

if [ "$#" -gt 0 ]; then
    exec "$@"
fi

exec su node -s /bin/bash -lc "openclaw"
