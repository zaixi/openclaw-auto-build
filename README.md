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

本镜像的 apt/npm/pip 包和预装扩展均为 [Dockerfile](Dockerfile) 内硬编码，如需修改请直接编辑 Dockerfile。

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
docker run --rm -it --entrypoint bash openclaw:test
```

## 持久化挂载

内置插件 seed 存放在 `/opt/openclaw-seed/npm`，启动时会同步到 `/home/node/.openclaw/extensions`。
因此即使将宿主机目录挂载到 `/home/node`，也不会遮住镜像内置插件 seed。
默认同步模式会以 seed 为准更新同名内置插件，并合并 `package.json` 与 `package-lock.json`：
seed 中的依赖版本优先生效，运行时额外安装插件的 npm 元数据会保留。

## 构建参数说明

| 参数 | 来源 | 说明 |
|------|------|------|
| `OPENCLAW_VERSION` | Workflow 自动检测 | OpenClaw npm 版本号 |
| `OPENCLAW_SEED_VERSION` | Docker build arg | 插件 seed 版本标记，默认按 OpenClaw 版本和 seed 内容生成 |

## 预装内容

| 类别 | 内容 |
|------|------|
| 基础工具 | bash, curl, git, jq, tmux, ripgrep, unzip, dk（已注释，沙箱用）|
| 运行环境 | Node.js, Python 3.12, uv |
| Docker | docker.io（用于沙箱模式）|
| 浏览器 | Chromium（浏览器引擎）+ Playwright（自动化框架）+ 反检测插件 — 两者同时使用，用于网页截图/自动化 |
| 媒体 | FFmpeg |
| 网络 | socat, openssh-client, gosu |
| OpenClaw 全局 | opencode-ai, clawhub, claude-code |
| 聊天插件 | openclaw-napcat, @soimy/dingtalk, @tencent-connect/openclaw-qqbot, @sunnoy/wecom, @tencent-weixin/openclaw-weixin |
| 其他 | Playwright Extra, mcporter, agent-browser, Pillium |

## 微信插件

镜像已预装官方微信插件 `@tencent-weixin/openclaw-weixin`，并通过 seed 同步到持久化的 `extensions` 目录。
微信账号绑定仍需在运行时交互扫码，可按官方安装助手执行：

```bash
npx -y @tencent-weixin/openclaw-weixin-cli install
```

## 上游参考

- 原始仓库：[justlovemaki/openclaw-china-docker](https://github.com/justlovemaki/openclaw-china-docker)
- OpenClaw 官方：[openclaw/openclaw](https://github.com/openclaw/openclaw)
