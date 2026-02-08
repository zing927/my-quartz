#!/bin/bash

# 一键发布脚本：同步 -> 构建 -> 提交 -> 推送

echo "🚀 开始一键发布流程..."

# 1. 同步 Obsidian 内容
echo "📝 步骤 1: 同步 Obsidian 内容..."
./sync.sh

# 2. 构建网站
echo "🔨 步骤 2: 构建网站..."
npm run build

# 恢复 favicon.ico 文件
if [ -f "favicon.ico" ]; then
    echo "🔖 恢复 favicon.ico 文件..."
    cp favicon.ico public/favicon.ico
fi

# 3. 提交到 Git
echo "📦 步骤 3: 提交到 Git..."
git add .
git commit -m "更新内容 - $(date '+%Y-%m-%d %H:%M:%S')"

# 4. 推送到 GitHub
echo "🚀 步骤 4: 推送到 GitHub..."
git push origin main

echo "✅ 发布完成！Vercel 将在几分钟内自动部署。"
echo "🌐 访问 https://my-quartz-nu.vercel.app/ 查看最新版本"