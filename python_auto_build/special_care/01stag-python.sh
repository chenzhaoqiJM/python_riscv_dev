#!/bin/bash
set -e

mkdir -p ~/mytmpstg
export TMPDIR=~/mytmpstg

# 当前脚本所在目录（支持相对路径执行）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# git dir
TARGET_DIR=~/ck/stag-python

# 创建上级目录（如果不存在）
mkdir -p "$(dirname "$TARGET_DIR")"


# 虚拟环境目录
VENV_DIR="$HOME/pyenvs/tmpbuild_special"

# 删除旧虚拟环境
if [ -d "$VENV_DIR" ]; then
    echo "🧹 Removing old virtualenv at $VENV_DIR"
    rm -rf "$VENV_DIR"
fi

# 创建新虚拟环境
echo "📦 Creating new virtualenv at $VENV_DIR"
python3 -m venv "$VENV_DIR"

# 激活虚拟环境
source "$VENV_DIR/bin/activate"

# 安装构建相关工具
echo "⬆️  Installing pip & build tools..."
pip install --verbose setuptools wheel build twine


# 克隆仓库到指定目录（递归包含子模块）
git clone --recursive https://github.com/ManfredStoiber/stag-python "$TARGET_DIR"

# 如果克隆成功，则进入该目录
if [ $? -eq 0 ]; then
    cd "$TARGET_DIR" || exit 1
else
    echo "Git clone failed."
    exit 1
fi

sleep 4

pip install . --verbose 

# 构建包（你可以用 pip install 或 python -m build）
# 例：pip install ./yourpkg 或 python -m build

# 自动调用同目录下的 upload 脚本
UPLOAD_SCRIPT="$SCRIPT_DIR/00upload_built_wheels.py"
if [ -f "$UPLOAD_SCRIPT" ]; then
    echo "🚀 Running upload_built_wheels.py..."
    python "$UPLOAD_SCRIPT"
else
    echo "⚠️  upload_built_wheels.py not found in $SCRIPT_DIR"
fi

rm -rf "~/mytmpstg" || echo "❌ Failed to remove mytmpstg"

deactivate

sleep 3

echo "🗑️  Removing $VENV_DIR"
rm -rf "$VENV_DIR" || echo "⚠️ Failed Remove $VENV_DIR"

echo "✅ Done."
