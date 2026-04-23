#!/usr/bin/env bash
set -euo pipefail

export HOME=/home/node
export LANG="${LANG:-en_US.UTF-8}"
export LANGUAGE="${LANGUAGE:-en_US:en}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export PLAYWRIGHT_BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-/home/node/.cache/ms-playwright}"

mkdir -p \
    /home/node/.openclaw \
    /home/node/.openclaw/extensions \
    /home/node/.openclaw/workspace \
    /home/node/.cache/ms-playwright

# 确保持久化目录权限正确
chown -R node:node /home/node/.openclaw /home/node/.cache 2>/dev/null || true

if [ "$#" -gt 0 ]; then
    exec "$@"
fi

exec su node -s /bin/bash -lc "openclaw"