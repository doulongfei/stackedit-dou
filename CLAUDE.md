# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

StackEdit AI 中文版 —— 功能丰富的 Markdown 编辑器，支持多云端同步、离线编辑和 AI 写作辅助。

**技术栈**：Vue 3 + Vuex 4 + Vite（前端）、Flask 3（后端 Python）、IndexedDB（本地持久化）、Service Worker（离线支持）

## 常用命令

### 前端开发
```bash
npm install          # 安装依赖（需要 Node 18+）
npm run dev          # 启动开发服务器（localhost:5173，热重载）
npm run build        # 生产构建（同时编译样式）
npm run build-style  # 仅编译样式 bundle
npm run preview      # 预览生产构建
```

### 后端开发
```bash
pip install -r server/requirements.txt   # 安装 Python 依赖
python server/app.py                     # 开发模式启动（需要在 server/ 目录下）
```

### Docker 构建
```bash
docker build -t stackedit .
docker run -p 8080:8080 stackedit
```

### 发布构建（CI）
- GitHub Actions `release.yml`：手动触发，选择版本类型（patch/minor/major），自动构建并创建 GitHub Release
- GitHub Actions `pyinstaller-build.yml`：构建 Linux x86_64 单文件二进制

## 架构概述

### 前端层（`src/`）

**组件（`src/components/`）**：`App.vue` → `Layout.vue`（主布局）→ `Editor.vue`（编辑器）+ `Explorer.vue`（文件树）+ `NavigationBar.vue`。Modal 系统独立，在 `modals/` 目录下有多种变体。

**状态管理（`src/store/`）**：15+ 个 Vuex 模块，各自管理独立域：
- `content.js` / `contentState.js`：文档内容与编辑状态
- `workspace.js`：多 provider 工作区管理
- `syncLocation.js`：同步目标配置
- `chatgpt.js`：AI 功能状态
- `layout.js`、`notification.js`、`modal.js`、`theme.js`：UI 状态

**服务层（`src/services/`）**：业务逻辑核心：
- `syncSvc.js`：跨 provider 同步编排（冲突解决基于 diff-match-patch）
- `localDbSvc.js`：IndexedDB 封装（主要本地存储）
- `editorSvc.js`：编辑器操作服务
- `chatGptSvc.js`：ChatGPT API 集成
- `providers/`：各云端 provider 实现（GitHub、Gitee、Gitea、GitLab、Google Drive）

**Markdown 扩展（`src/extensions/`）**：markdown-it 插件系统，支持 KaTeX 数学公式、Mermaid 图表、Prism 代码高亮等。

### 后端层（`server/`）

轻量 Flask 应用，主要职责：
- OAuth2 流程代理（`/oauth2/*` 路由，对应 `github.py`、`gitee.py`、`gitea.py`、`gitlab.py`）
- 导出功能：`/pdfExport`（wkhtmltopdf）、`/pandocExport`（Pandoc）
- 配置端点：`/conf`（向前端暴露运行时配置）
- 静态资源托管（生产模式）

**环境变量**（通过 `server/conf.py` 加载）：
- OAuth：`GITHUB_CLIENT_ID/SECRET`、`GITEE_CLIENT_ID/SECRET`、`GITEA_CLIENT_ID/URL`、`GITLAB_CLIENT_ID/URL`
- 导出工具路径：`PANDOC_PATH`、`WKHTMLTOPDF_PATH`
- 服务器：`LISTENING_PORT`（默认 8080）、`DEBUG_FLAG`

### Vite 开发代理

`vite.config.js` 将以下路径代理到后端（`localhost:8080`）：`/oauth2`、`/pdfExport`、`/pandocExport`、`/conf`、`/themes`、`/api/chatgpt`。

### 数据流

1. 文档内容 → IndexedDB（离线持久化）+ Service Worker（PWA）
2. 云端同步 → `syncSvc.js` 调用各 provider → OAuth2 由 Flask 后端处理
3. AI 辅助 → `chatGptSvc.js` → 后端 `/api/chatgpt` 代理 → ChatGPT API

### 关键配置文件
- `src/data/constants.js`：全局常量
- `src/data/features.js`：功能开关列表
- `src/data/defaults/`：默认配置值
- `public/`：静态资源（落地页、OAuth 回调页、主题 CSS）
