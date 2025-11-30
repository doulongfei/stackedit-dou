# 自动构建与发布（GitHub Actions）

本仓库新增了一个 GitHub Actions 工作流：`.github/workflows/release.yml`。

功能概述：
- 支持手动触发（workflow_dispatch），可选择 release 类型：patch / minor / major。
- 在工作流中会执行：
  - 安装依赖并构建前端（npm run build）
  - 打包构建产物（压缩 dist + server + package.json）
  - 自动执行 `npm version <type>` 来 bump 版本并创建 tag & commit（commit message 包含 [skip ci]）
  - 推送 commit 与 tag 回 `master` 分支
  - 基于 tag 创建 GitHub Release 并上传打包产物

如何使用：
1. 打开 GitHub 仓库页面 → Actions → 选择 "Build, Package and Release" 工作流。
2. 点击 "Run workflow"，选择或确认 `release_type`（默认 patch），然后运行。
3. 工作流成功后会在仓库里创建一个新的 commit 和 tag（vX.Y.Z），并创建对应的 Release，Release 中包含构建产物压缩包。

注意事项：
- 工作流会把生成的 commit 推回 `master` 分支，请确保这是你期望的流程。你也可修改 workflow 文件把分支改为 `main` 或其它分支。
- 自动提交时会使用 `npm version`，这会修改 `package.json` 的 version 字段并创建一个 Git tag。
- 如果你希望自动化触发发布，也可以把流程改为在合并 PR 到 `master` 时触发（当前为手动触发）。

如需我把流程改成自动在每次合并到 master 时执行，或把后端一起构建为容器镜像并上传到 registry（比如 Docker Hub / GitHub Packages），我可以继续帮你实现。
