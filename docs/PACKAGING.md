# 一键打包与安装说明

本项目提供两种一键整合前后端并可快速部署的方式：

1. 打包成单个 tarball + 一键安装脚本（适用于 VPS/自有主机）
2. Docker 单镜像部署（适合现代云/容器平台）

---

## 1) 一键打包与安装（tarball）

生成打包文件：

```bash
# 在仓库根目录运行
./scripts/make_dist_package.sh

# 生成示例： stackedit-bundle-<version>-YYYYmmddTHHMMSSZ.tar.gz
```

在目标服务器上：

```bash
# 上传并解压
tar xzf stackedit-bundle-*.tar.gz
cd stackedit-bundle-*

# 然后以 root 或 sudo 运行安装脚本(可以指定安装目录/端口)
sudo ./scripts/install.sh --target /opt/stackedit --port 8080 --debug false
```

安装脚本将：
- 复制 `dist/`、`server/` 到目标目录（默认 `/opt/stackedit`）
- 创建 Python venv 并安装 `server/requirements.txt`
- 添加并启动 `systemd` 服务（`/etc/systemd/system/stackedit.service`）

注意：如果你的后端用到 `pandoc`、`wkhtmltopdf` 等本地二进制，请在安装前手动安装它们。

---

## 2) Docker 镜像（推荐用于容器平台）

仓库根目录已包含 `Dockerfile`。

构建并运行：

```bash
# 构建
docker build -t stackedit:latest .

# 运行（示例）
docker run -d -p 8080:8080 --name stackedit stackedit:latest
```

该镜像使用 multi-stage：先使用 Node 构建前端，再在 Python 运行时内安装依赖并使用 gunicorn 启动 Flask 后端。
