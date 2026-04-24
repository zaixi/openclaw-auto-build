# openclaw-auto-build

自动构建 OpenClaw 自定义镜像，同步上游官方发布版本。

## 功能

- 自动同步 OpenClaw 官方最新 release
- 自定义构建（安装额外 apt/npm/pip 包、预装扩展等），全部通过 `build.conf` 配置
- 推送到 Docker Hub + GitHub Container Registry（GHCR）
- 每6小时检查一次上游更新，有新版本自动构建推送

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

编辑 `build.conf` 来自定义镜像内容，无需改动 Dockerfile：

```bash
# apt 包（空格分隔）
OPENCLAW_APT_PACKAGES="bash build-essential chromium curl git ..."

# npm 全局包（空格分隔）
OPENCLAW_NPM_PACKAGES="clawhub playwright opencode-ai ..."

# pip 包（空格分隔）
OPENCLAW_PIP_PACKAGES="websockify"

# 预装扩展（容器启动时安装，非构建时）
OPENCLAW_EXTENSIONS="openclaw-tavily openclaw-qqbot"

# 镜像加速
OPENCLAW_NPM_REGISTRY="https://registry.npmmirror.com"
OPENCLAW_PIP_INDEX_URL="https://pypi.npmmirror.com"
```

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

每6小时（`0 */6 * * *`，北京时间 02:00 / 08:00 / 14:00 / 20:00）自动检查上游更新，有新版本自动构建并推送。

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
| `OPENCLAW_APT_PACKAGES` | build.conf | 基础 apt 包 |
| `OPENCLAW_NPM_PACKAGES` | build.conf | npm 全局包 |
| `OPENCLAW_PIP_PACKAGES` | build.conf | pip 包 |
| `OPENCLAW_EXTENSIONS` | build.conf + ENV | 预装扩展（启动时检查安装） |
| `OPENCLAW_NPM_REGISTRY` | build.conf + ENV | npm registry |
| `OPENCLAW_PIP_INDEX_URL` | build.conf + ENV | pip index URL |
