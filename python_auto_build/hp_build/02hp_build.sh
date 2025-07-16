#!/bin/bash
set -e

mkdir -p ~/mytmphp
export TMPDIR=~/mytmphp

export PYODIDE=1
# 当前脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGE_LIST="$SCRIPT_DIR/hp_pkgs.txt"
FAILED_LIST="$SCRIPT_DIR/failed_hp.log"
UPLOAD_SCRIPT="$SCRIPT_DIR/00upload_built_wheels.py"

# 无限循环
while true; do
    echo "⏳ Starting new round at $(date)"

    # 清空失败记录
    > "$FAILED_LIST"

    if [ ! -f "$PACKAGE_LIST" ]; then
        echo "❌ File not found: $PACKAGE_LIST"
        exit 1
    fi

    while IFS= read -r PACKAGE_NAME || [[ -n "$PACKAGE_NAME" ]]; do
        PACKAGE_NAME=$(echo "$PACKAGE_NAME" | xargs)  # 去空白
        if [ -z "$PACKAGE_NAME" ]; then
            continue
        fi

        echo "🔁 Processing $PACKAGE_NAME"

        VENV_DIR="$HOME/pyenvs/tmpbuild_hp"
        DIST_DIR="$HOME/pyenvs/store"

        # 删除旧环境
        if [ -d "$VENV_DIR" ]; then
            echo "🧹 Removing old virtualenv at $VENV_DIR"
            rm -rf "$VENV_DIR"
        fi

        # 创建虚拟环境
        echo "📦 Copy virtualenv..."
        cp -r "$DIST_DIR/tmpbuild_hp" "$VENV_DIR"
        source "$VENV_DIR/bin/activate"

        # 安装当前包
        echo "📥 Installing $PACKAGE_NAME ..."
        if ! pip install --upgrade --verbose "$PACKAGE_NAME"; then
            echo "❌ Failed: $PACKAGE_NAME"
            echo "$PACKAGE_NAME" >> "$FAILED_LIST"
            deactivate
            rm -rf "$VENV_DIR"
            echo "---------------------------------------------"
            continue
        fi

        # 调用上传脚本（如果存在）
        if [ -f "$UPLOAD_SCRIPT" ]; then
            echo "🚀 Running upload script for $PACKAGE_NAME"
            python "$UPLOAD_SCRIPT"
        else
            echo "⚠️  Upload script not found: $UPLOAD_SCRIPT"
        fi

        deactivate

        sleep 2

        echo "🗑️  Removing $VENV_DIR"
        rm -rf "$VENV_DIR" || echo "⚠️ Failed Remove $VENV_DIR"

        echo "✅ Done for $PACKAGE_NAME"

        echo "Removing tmp..........."

        rm -rf "~/mytmphp/*" || echo "❌ Failed to remove mytmpversion"
        
        echo "---------------------------------------------"
    done < "$PACKAGE_LIST"

    echo "🎉 Round finished at $(date)"
    if [ -s "$FAILED_LIST" ]; then
        echo "❗ Some packages failed:"
        cat "$FAILED_LIST"
    else
        echo "✅ All packages installed successfully!"
    fi

    echo "🕒 Sleeping for 12 hours..."
    sleep 43200  # 12 小时
done
