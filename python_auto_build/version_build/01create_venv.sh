#!/bin/bash
set -e

VENV_DIR="$HOME/pyenvs/tmpbuild_version"

# 清理旧虚拟环境
if [ -d "$VENV_DIR" ]; then
    echo "🧹 Removing old virtualenv at $VENV_DIR"
    rm -rf "$VENV_DIR"
fi

# 创建新的虚拟环境
echo "📦 Creating virtualenv..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# 安装工具和指定版本的包
echo "⬆️ Installing $package==$version"
pip install --upgrade pip setuptools wheel twine

deactivate

sleep 2

DIST_DIR="$HOME/pyenvs/store"

if [ ! -d "$DIST_DIR" ]; then
    mkdir -p "$DIST_DIR"
fi

cp -r "$VENV_DIR" "$DIST_DIR"

rm -rf "$VENV_DIR"