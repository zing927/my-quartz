#!/bin/bash

# Obsidian 到 GitHub 自动同步脚本

cd /Users/zhengjing/Documents/my-quartz

# 使用 rsync 同步 Obsidian 的 public 文件夹到 Quartz，只处理有变化的文件
echo "📁 同步 Obsidian 内容到 Quartz（增量同步）..."
mkdir -p content
rsync -av --delete "/Users/zhengjing/Documents/正靖的私人笔记/public/" content/

# 自动处理 Obsidian 图片文件
echo "🖼️  自动处理 Obsidian 图片..."
mkdir -p content/images

# 查找所有 Markdown 文件中引用的 Obsidian 图片链接
IMAGE_LINKS=$(grep -r "!\[\[.*\.png\]\]" content/ | grep -o "\[\[.*\.png\]\]" | sed 's/\[\[//;s/\]\]//')

if [ -n "$IMAGE_LINKS" ]; then
    echo "🔍 发现 $(echo "$IMAGE_LINKS" | wc -l) 个图片引用"
    
    # 复制每个引用的图片到 content/images 目录
    for IMAGE in $IMAGE_LINKS; do
        SOURCE_IMAGE="/Users/zhengjing/Documents/正靖的私人笔记/$IMAGE"
        DEST_IMAGE="content/images/$IMAGE"
        
        if [ -f "$SOURCE_IMAGE" ]; then
            echo "📄 复制图片: $IMAGE"
            cp "$SOURCE_IMAGE" "$DEST_IMAGE"
        else
            echo "⚠️  找不到图片: $IMAGE"
        fi
    done
    
    # 更新 Markdown 文件中的图片链接格式
    echo "🔄 更新 Markdown 文件中的图片链接..."
    find content/ -name "*.md" -exec sed -i '' 's/!\[\[(Pasted image.*\.png)\]\]/!\[\[images\/\1\]\]/g' {} \;
    echo "✅ 图片链接更新完成"
else
    echo "ℹ️  没有发现图片引用"
fi

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