#!/bin/bash
set -e

mkdir -p ~/mytmpversion
export TMPDIR=~/mytmpversion


# 当前脚本所在目录（支持相对路径执行）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查是否提供了至少一个包名
if [ $# -lt 1 ]; then
    echo "❗ Usage: $0 <package_name1> [package_name2] [...]"
    exit 1
fi

# 提供一次虚拟环境
VENV_DIR="$HOME/pyenvs/tmpbuild_version_single"
DIST_DIR="$HOME/pyenvs/store"

# 清理旧虚拟环境
if [ -d "$VENV_DIR" ]; then
    echo "🧹 Removing old virtualenv at $VENV_DIR"
    rm -rf "$VENV_DIR"
fi

if [ ! -d "$DIST_DIR" ]; then
    mkdir -p "$DIST_DIR"
fi

# 清理旧虚拟环境
if [ -d "$DIST_DIR/tmpbuild_version_single" ]; then
    echo "🧹 Removing old virtualenv at $DIST_DIR/tmpbuild_version_single"
    rm -rf "$DIST_DIR/tmpbuild_version_single"
fi

# 创建新的虚拟环境
echo "📦 Creating virtualenv..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# 安装工具和指定版本的包
echo "⬆️ Installing pip setuptools wheel twine"
pip install --upgrade pip setuptools wheel twine

deactivate

sleep 5

cp -r "$VENV_DIR" "$DIST_DIR"

rm -rf "$VENV_DIR"

for PACKAGE in "$@"; do
    echo "🔁 Processing package: $PACKAGE"

    # 执行 00get_pkg_version.py 获取版本列表
    echo "🔄 Running 00get_pkg_version.py for $PACKAGE..."
    if ! python3 "$SCRIPT_DIR/00get_pkg_version.py" "$PACKAGE"; then
        echo "❌ Failed to get versions for $PACKAGE"
        continue
    fi

    VERSION_FILE="$SCRIPT_DIR/${PACKAGE}.log"
    if [ ! -f "$VERSION_FILE" ]; then
        echo "⚠️ Version file for $PACKAGE not found. Skipping."
        continue
    fi

    while IFS= read -r version; do
        echo "🔁 Processing version: $version"
        
        # 清理旧虚拟环境
        if [ -d "$VENV_DIR" ]; then
            echo "🧹 Removing old virtualenv at $VENV_DIR"
            rm -rf "$VENV_DIR"
        fi

        echo "📦 Copy new virtualenv..."
        cp -r "$DIST_DIR/tmpbuild_version_single" "$VENV_DIR" 
        source "$VENV_DIR/bin/activate"

        echo "⬆️ Installing $PACKAGE==$version"
        if ! pip install --verbose "$PACKAGE==$version"; then
            echo "⚠️ Failed to install $PACKAGE==$version"
            deactivate
            continue
        fi

        UPLOAD_SCRIPT="$SCRIPT_DIR/01upload_built_wheels.py"
        if [ -f "$UPLOAD_SCRIPT" ]; then
            echo "🚀 Running upload_built_wheels.py for $PACKAGE==$version"
            if ! python "$UPLOAD_SCRIPT"; then
                echo "⚠️ Failed to run upload_built_wheels.py for $PACKAGE==$version"
                deactivate
                continue
            fi
        else
            echo "⚠️ upload_built_wheels.py not found in $SCRIPT_DIR"
            deactivate
            continue
        fi

        deactivate
        sleep 5
        echo "🗑️ Removing $VENV_DIR"
        rm -rf "$VENV_DIR" || echo "❌ Failed to remove $VENV_DIR"

        echo "✅ Done for $PACKAGE==$version"

        echo "Removing tmp..........."

        rm -rf "~/mytmpversion/*" || echo "❌ Failed to remove mytmpversion"
        
        echo "---------------------------------------------"
    done < "$VERSION_FILE"

    rm -f "$VERSION_FILE"
    echo "🗑️ Removed version file for $PACKAGE: $VERSION_FILE"
    echo "✅ All done for $PACKAGE!"
    echo "============================================="
done
