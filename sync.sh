#!/bin/bash

# Obsidian 到 GitHub 自动同步脚本

cd /Users/zhengjing/Documents/my-quartz

# 清空 content 并复制 Obsidian 的 public 文件夹，保持完全一致
echo "📁 同步 Obsidian 内容到 Quartz（完全覆盖）..."
mkdir -p content
rm -rf content/*
cp -r "/Users/zhengjing/Documents/正靖的私人笔记/public/"* content/

echo "🔨 开始构建 Quartz..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ 构建成功"
    
    echo "📝 提交到 Git..."
    git add .
    
    # 检查是否有更改
    if git diff --quiet && git diff --cached --quiet; then
        echo "ℹ️  没有更改需要提交"
    else
        git commit -m "更新内容 - $(date '+%Y-%m-%d %H:%M:%S')"
        
        echo "🚀 推送到 GitHub..."
        git push
        
        if [ $? -eq 0 ]; then
            echo "✅ 推送成功！Vercel 将在几分钟内自动部署"
        else
            echo "❌ 推送失败，请检查网络连接"
        fi
    fi
else
    echo "❌ 构建失败，请检查错误信息"
fi