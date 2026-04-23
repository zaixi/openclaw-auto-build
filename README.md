# openclaw-auto-build

自动构建 OpenClaw 自定义镜像，同步上游官方发布版本。

## 功能

- 自动同步 OpenClaw 官方最新 release
- 自定义构建（安装额外包、预装扩展等）
- 推送到 Docker Hub
- 每天凌晨自动检查更新

## 使用方法

### 1. Fork 本仓库

### 2. 配置 Secrets

在 GitHub 仓库 Settings → Secrets 中添加：

| Name | 说明 |
|------|------|
| `DOCKERHUB_USERNAME` | Docker Hub 用户名 |
| `DOCKERHUB_TOKEN` | Docker Hub Access Token（不是密码）|

获取 Token：[Docker Hub Account Settings](https://hub.docker.com/settings/security) → Access Tokens → New Token

### 3. 自定义包（可选）

编辑 `Dockerfile`，通过构建参数添加你需要的包和扩展：

```dockerfile
ARG OPENCLAW_DOCKER_APT_PACKAGES="git curl jq ffmpeg"
ARG OPENCLAW_EXTENSIONS=""
```

| 参数 | 说明 |
|------|------|
| `OPENCLAW_DOCKER_APT_PACKAGES` | 额外的 apt 包（空格分隔），如 `git curl jq ffmpeg` |
| `OPENCLAW_EXTENSIONS` | 预装的扩展名（空格分隔），如 `openclaw-tavily openclaw-qqbot` |

这些参数由官方镜像在构建时处理，比直接 apt-get 更简洁。

### 4. 启用 Action

在 GitHub 仓库的 Actions 页面启用 Workflow，然后手动触发一次：

- 进入 Actions → Build and Push Custom OpenClaw Image → Run workflow

## 手动触发更新

如果你想立即检查上游是否有新版本，可以：

1. 进入 Actions 页面
2. 点击 "Build and Push Custom OpenClaw Image"
3. 点击 "Run workflow"
4. 选择 `main` 分支，点击 Run

## 定时任务

默认每天 UTC 02:00（北京时间 10:00）检查一次上游更新。如果检测到新版本会自动构建并推送。

## 输出镜像

```
docker.io/<your-username>/openclaw-custom:latest
docker.io/<your-username>/openclaw-custom:<version>
```

## 本地测试构建

```bash
docker build -t openclaw-custom:test .
docker run -it openclaw-custom:test bash
```