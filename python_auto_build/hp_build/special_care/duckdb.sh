#!/bin/bash
set -e

export PYODIDE=1
# 当前脚本所在目录（支持相对路径执行）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
pip install --upgrade --verbose setuptools wheel build twine

pip install duckdb --upgrade --verbose --global-option=--disable-jemalloc

# 构建包（你可以用 pip install 或 python -m build）
# 例：pip install ./yourpkg 或 python -m build

# 自动调用同目录下的 upload 脚本
UPLOAD_SCRIPT="$SCRIPT_DIR/../00upload_built_wheels.py"
if [ -f "$UPLOAD_SCRIPT" ]; then
    echo "🚀 Running upload_built_wheels.py..."
    python "$UPLOAD_SCRIPT"
else
    echo "⚠️  upload_built_wheels.py not found in $SCRIPT_DIR"
fi

echo "✅ Done."
