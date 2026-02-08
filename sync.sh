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
echo "🔍 搜索 Markdown 文件中的图片引用..."
IMAGE_FILES=$(grep -r "!\[\[.*\.png\]\]" content/ | cut -d: -f1 | uniq)

TOTAL_IMAGES=0

if [ -n "$IMAGE_FILES" ]; then
    echo "📄 发现 $(echo "$IMAGE_FILES" | wc -l) 个文件包含图片引用"
    
    # 处理每个包含图片引用的文件
    for FILE in $IMAGE_FILES; do
        echo "🔄 处理文件: $FILE"
        
        # 读取文件内容
        FILE_CONTENT=$(cat "$FILE")
        
        # 使用 grep 提取完整的图片链接（包含空格）
        IMAGES_IN_FILE=$(echo "$FILE_CONTENT" | grep -o "!\[\[.*\.png\]\]" | sed 's/!\[\[//;s/\]\]//')
        
        if [ -n "$IMAGES_IN_FILE" ]; then
            # 直接处理图片（假设只有一个图片引用）
            TOTAL_IMAGES=$((TOTAL_IMAGES + 1))
            IMAGE="$IMAGES_IN_FILE"
            SOURCE_IMAGE="/Users/zhengjing/Documents/正靖的私人笔记/$IMAGE"
            DEST_IMAGE="content/images/$IMAGE"
            
            if [ -f "$SOURCE_IMAGE" ]; then
                echo "📄 复制图片: $IMAGE"
                cp "$SOURCE_IMAGE" "$DEST_IMAGE"
            else
                echo "⚠️  找不到图片: $IMAGE"
                # 尝试查找所有可能的图片文件
                POSSIBLE_IMAGES=$(find "/Users/zhengjing/Documents/正靖的私人笔记" -name "*$IMAGE*" -o -name "*$(echo "$IMAGE" | cut -d' ' -f1)*")
                if [ -n "$POSSIBLE_IMAGES" ]; then
                    echo "🔍 可能的图片文件:"
                    echo "$POSSIBLE_IMAGES"
                fi
            fi
            
            # 更新文件中的图片链接
            echo "🔄 更新文件中的图片链接..."
            # 使用 perl 代替 sed 来处理包含空格的正则表达式
            perl -i -pe 's/!\[\[(.*?\.png)\]\]/!\[\[images\/\1\]\]/g' "$FILE"
        fi
    done
    
    echo "✅ 处理完成，共发现 $TOTAL_IMAGES 个图片引用"
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