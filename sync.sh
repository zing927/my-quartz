#!/bin/bash

# Obsidian 到 GitHub 自动同步脚本

cd /Users/zhengjing/Documents/my-quartz

# 使用 rsync 同步 Obsidian 的 public 文件夹到 Quartz，只处理有变化的文件
echo "📁 同步 Obsidian 内容到 Quartz（增量同步）..."
mkdir -p content
rsync -av --delete --exclude='index.md' "/Users/zhengjing/Documents/正靖的私人笔记/public/" content/

# 自动处理 Obsidian 图片文件
echo "🖼️  自动处理 Obsidian 图片..."
mkdir -p content/images

# 创建图片缓存目录和日志文件
mkdir -p .cache

# 查找所有 Markdown 文件中引用的 Obsidian 图片链接
echo "🔍 搜索 Markdown 文件中的图片引用..."
IMAGE_FILES=$(grep -r "!\[\[.*\.png\]\]" content/ | cut -d: -f1 | uniq)

TOTAL_IMAGES=0
PROCESSED_IMAGES=0

if [ -n "$IMAGE_FILES" ]; then
    echo "📄 发现 $(echo "$IMAGE_FILES" | wc -l) 个文件包含图片引用"
    
    # 创建临时文件存储所有图片引用
    TEMP_IMAGES=$(mktemp)
    
    # 收集所有图片引用
    for FILE in $IMAGE_FILES; do
        # 使用 grep 提取完整的图片链接（包含空格）
        IMAGES_IN_FILE=$(grep -o "!\[\[.*\.png\]\]" "$FILE" | sed 's/!\[\[//;s/\]\]//')
        if [ -n "$IMAGES_IN_FILE" ]; then
            echo "$IMAGES_IN_FILE" >> "$TEMP_IMAGES"
        fi
    done
    
    # 去重图片引用
    UNIQUE_IMAGES=$(sort "$TEMP_IMAGES" | uniq)
    TOTAL_IMAGES=$(echo "$UNIQUE_IMAGES" | wc -l)
    
    if [ "$TOTAL_IMAGES" -gt 0 ]; then
        echo "🔄 处理 $TOTAL_IMAGES 个唯一图片引用..."
        
        # 并行处理图片复制
        echo "$UNIQUE_IMAGES" | while IFS= read -r IMAGE; do
            PROCESSED_IMAGES=$((PROCESSED_IMAGES + 1))
            echo "[$PROCESSED_IMAGES/$TOTAL_IMAGES] 处理图片: $IMAGE"
            
            SOURCE_IMAGE="/Users/zhengjing/Documents/正靖的私人笔记/$IMAGE"
            DEST_IMAGE="content/images/$IMAGE"
            
            # 检查图片是否已经存在（缓存机制）
            if [ ! -f "$DEST_IMAGE" ] || [ "$SOURCE_IMAGE" -nt "$DEST_IMAGE" ]; then
                if [ -f "$SOURCE_IMAGE" ]; then
                    echo "📄 复制图片: $IMAGE"
                    cp "$SOURCE_IMAGE" "$DEST_IMAGE"
                else
                    echo "⚠️  找不到图片: $IMAGE"
                fi
            else
                echo "ℹ️  图片已存在且未修改: $IMAGE"
            fi
        done
        
        # 更新所有 Markdown 文件中的图片链接
        echo "🔄 更新 Markdown 文件中的图片链接..."
        for FILE in $IMAGE_FILES; do
            # 使用 perl 代替 sed 来处理包含空格的正则表达式
            perl -i -pe 's/!\[\[(.*?\.png)\]\]/!\[\[images\/\1\]\]/g' "$FILE"
        done
        echo "✅ 图片链接更新完成"
    fi
    
    # 清理临时文件
    rm "$TEMP_IMAGES"
    
    echo "✅ 处理完成，共发现 $TOTAL_IMAGES 个图片引用"
else
    echo "ℹ️  没有发现图片引用"
fi

echo "🔨 开始构建 Quartz..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ 构建成功"
    
    # 恢复 favicon.ico 文件
    if [ -f "favicon.ico" ]; then
        echo "🔖 恢复 favicon.ico 文件..."
        cp favicon.ico public/favicon.ico
    fi
    
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