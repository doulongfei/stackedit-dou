# 使用 PyInstaller 打包后端（生成单文件可执行）

本节说明如何为 `server/` 使用 PyInstaller 生成单文件可执行，并如何部署到 Linux 服务器。

重要提示：PyInstaller 打包只会包含 Python 运行时与 Python 依赖；像 `pandoc`、`wkhtmltopdf` 这类系统级二进制不会被打包，目标主机上仍需预先安装它们。

## 构建步骤（在与目标平台相同的 Linux 系统上执行）

1. 确保 Node.js 可用并先构建前端：

```bash
npm ci
npm run build
```

2. 使用仓库中提供的脚本在隔离 venv 中构建单文件二进制：

```bash
./scripts/pyinstaller_build.sh --name stackedit-server
```

脚本会生成一个 tar 包，名称形如：
`stackedit-server-<version>-<UTC_TIMESTAMP>-linux-x86_64.tar.gz`。

## 在目标服务器上部署单文件二进制

1. 上传 tar 包并解压：

```bash
tar xzf stackedit-server-*.tar.gz
```

2. 使用仓库附带的安装脚本把可执行文件安装为 systemd 服务：

```bash
sudo ./scripts/install_binary.sh /path/to/stackedit-server --target /opt/stackedit --port 8080
```

3. 查看服务日志并确认运行：

```bash
sudo systemctl status stackedit
sudo journalctl -u stackedit -f
```

## 常见问题与限制
- PyInstaller 二进制与构建平台绑定：必须在与目标相同架构和兼容 libc 的 Linux 环境中构建（在 x86_64 Linux 上构建用于 x86_64 Linux）。建议使用相同发行版或官方 manylinux 基础镜像进行构建。
- 需要确保系统上安装了 `pandoc`、`wkhtmltopdf` 等 externals，或修改代码跳过或替换这些功能。
- 单文件可执行启动时会把打包内的资源 (dist, server) 解压到临时目录（sys._MEIPASS），请不要直接依赖外部文件路径，或在运行时提供覆盖的 `.env` 文件位于可执行同目录。

如果你希望 CI 自动构建该二进制并把产物上传到 Release，我可以继续帮你把这个流程加入 GitHub Actions。此流程对于生成可执行文件会要求在 CI runner 使用合适的构建环境（例如 ubuntu-latest）。
