#!/bin/bash

# 1. 构建前端
echo "开始构建前端..."
npm run build

if [ $? -ne 0 ]; then
    echo "前端构建失败"
    exit 1
fi

# 2. 安装 PyInstaller (如果需要)
# echo "安装/检查 PyInstaller..."
# pip install pyinstaller

# 3. 使用 PyInstaller 打包
echo "开始打包可执行文件..."
pyinstaller --name stackedit --onefile \
    --add-data "dist:dist" \
    --add-data "static:static" \
    --add-data "server/.env.dev:server" \
    --add-data "server/.env.prod:server" \
    --hidden-import github \
    --hidden-import gitea \
    --hidden-import gitee \
    --hidden-import gitlab \
    --hidden-import pdf \
    --hidden-import pandoc \
    --paths server \
    --clean \
    server/app.py

if [ $? -eq 0 ]; then
    echo "打包成功！可执行文件位于 dist/stackedit"
else
    echo "打包失败"
    exit 1
fi
