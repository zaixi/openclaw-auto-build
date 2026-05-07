# openclaw-auto-build

自动构建 OpenClaw 自定义镜像，同步上游官方发布版本。

> 基于 [justlovemaki/openclaw-china-docker](https://github.com/justlovemaki/openclaw-china-docker) 修改。

## 功能

- 自动同步 OpenClaw 官方最新 release
- 预装国内 IM 插件（QQ、钉钉、企业微信、NapCat）
- 预装 AI 常用工具（Playwright、FFmpeg、Agent Reach 等）
- 推送到 Docker Hub + GitHub Container Registry（GHCR）
- 每1小时检查一次上游更新，有新版本自动构建推送

## 使用方法

### 1. Fork 本仓库

### 2. 配置 Secrets

在 GitHub 仓库 Settings → Secrets and variables → Actions 中添加：

| Name | 说明 |
|------|------|
| `DOCKERHUB_USERNAME` | Docker Hub 用户名 |
| `DOCKERHUB_TOKEN` | Docker Hub Access Token（不是密码）|
| `GHCR_PAT` | GitHub Personal Access Token（需拥有 `packages: write` 权限）|

获取 Docker Hub Token：[Docker Hub Account Settings](https://hub.docker.com/settings/security) → Access Tokens → New Token

### 3. 自定义配置

编辑 `build.conf` 配置镜像加速源：

```bash
# npm 镜像源
OPENCLAW_NPM_REGISTRY="https://registry.npmmirror.com"
# pip 镜像源
OPENCLAW_PIP_INDEX_URL="https://pypi.npmmirror.com"
```

> **注意：** 本镜像的 apt/npm/pip 包和预装扩展均为 [Dockerfile](Dockerfile) 内硬编码，如需修改请直接编辑 Dockerfile。

### 4. 启用 Action

在 GitHub 仓库的 Actions 页面启用 Workflow，然后手动触发一次：

- 进入 Actions → Build and Push OpenClaw Image → Run workflow → 勾 **Force build** → Run

## 手动触发更新

1. 进入 Actions 页面
2. 点击 "Build and Push OpenClaw Image"
3. 点击 "Run workflow"
4. 可选：勾 **Force build** 强制构建，填 **Version** 指定版本
5. 点击 Run

## 定时任务

每1小时自动检查上游更新，有新版本自动构建并推送。

## 输出镜像

```
# Docker Hub
docker.io/<your-username>/openclaw:latest
docker.io/<your-username>/openclaw:<version>

# GitHub Container Registry
ghcr.io/<your-username>/openclaw:<version>
```

## 本地测试构建

```bash
docker build -t openclaw:test .
docker run -it openclaw:test bash
```

## 构建参数说明

| 参数 | 来源 | 说明 |
|------|------|------|
| `OPENCLAW_VERSION` | Workflow 自动检测 | OpenClaw npm 版本号 |
| `OPENCLAW_NPM_REGISTRY` | build.conf | npm registry 镜像源 |
| `OPENCLAW_PIP_INDEX_URL` | build.conf | pip index 镜像源 |

## 预装内容

| 类别 | 内容 |
|------|------|
| 基础工具 | bash, curl, git, jq, tmux, ripgrep, unzip |
| 运行环境 | Node.js, Python 3.12, Bun, uv |
| Docker | docker.io（用于沙箱模式）|
| 浏览器 | Chromium + Playwright（含中文 CJK 字体）|
| 媒体 | FFmpeg |
| 网络 | socat, openssh-client, gosu |
| OpenClaw 全局 | opencode-ai, clawhub, claude-code |
| 聊天插件 | openclaw-napcat, @soimy/dingtalk, @tencent-connect/openclaw-qqbot, @sunnoy/wecom |
| 其他 | Playwright Extra, mcporter, agent-browser, Pillium |

## 上游参考

- 原始仓库：[justlovemaki/openclaw-china-docker](https://github.com/justlovemaki/openclaw-china-docker)
- OpenClaw 官方：[openclaw/openclaw](https://github.com/openclaw/openclaw)
