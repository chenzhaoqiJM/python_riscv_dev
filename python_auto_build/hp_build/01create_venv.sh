#!/bin/bash
set -e

mkdir -p ~/mytmphp
export TMPDIR=~/mytmphp

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


VENV_DIR="$HOME/pyenvs/tmpbuild_hp"

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

# 自动调用同目录下的 upload 脚本
UPLOAD_SCRIPT="$SCRIPT_DIR/00upload_built_wheels.py"
if [ -f "$UPLOAD_SCRIPT" ]; then
    echo "🚀 Running upload_built_wheels.py..."
    python "$UPLOAD_SCRIPT"
else
    echo "⚠️  upload_built_wheels.py not found in $SCRIPT_DIR"
fi

deactivate

sleep 1

# 移动虚拟环境
DIST_DIR="$HOME/pyenvs/store"

if [ ! -d "$DIST_DIR" ]; then
    mkdir -p "$DIST_DIR"
fi

cp -r "$VENV_DIR" "$DIST_DIR"

rm -rf "$VENV_DIR"

echo "Removing tmp..........."

rm -rf "~/mytmphp/*" || echo "❌ Failed to remove mytmpversion"