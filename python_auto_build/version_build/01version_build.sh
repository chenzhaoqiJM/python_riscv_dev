#!/bin/bash
set -e

mkdir -p ~/mytmpversion
export TMPDIR=~/mytmpversion

# 当前脚本所在目录（支持相对路径执行）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 执行 00get_spacemit_pkgs.py 获取包名列表
echo "🔄 Running 00get_spacemit_pkgs.py to get package names..."
python3 "$SCRIPT_DIR/00get_spacemit_pkgs.py"

# 检查 packages.log 是否成功生成
if [ ! -f "$SCRIPT_DIR/packages.log" ]; then
    echo "⚠️ packages.log not found. Exiting."
    exit 1
fi

# 检查 skip_pkgs.txt 是否存在
if [ -f "$SCRIPT_DIR/skip_pkgs.txt" ]; then
    skip_pkgs=$(<"$SCRIPT_DIR/skip_pkgs.txt")  # 读取跳过的包名
else
    skip_pkgs=()  # 如果没有 skip_pkgs.txt，则不跳过任何包
fi

# 读取包名并遍历
while IFS= read -r package; do
    # 检查当前包是否在 skip_pkgs.txt 中
    if echo "$skip_pkgs" | grep -qw "$package"; then
        echo "⏭️ Skipping package: $package"
        continue  # 跳过当前包
    fi

    echo "🔁 Processing package: $package"

    # 执行 00get_pkg_version.py 获取版本列表
    echo "🔄 Running 00get_pkg_version.py for $package..."
    
    if ! python3 "$SCRIPT_DIR/00get_pkg_version.py" "$package"; then
        continue
    fi

    # 检查版本文件是否成功生成
    VERSION_FILE="$SCRIPT_DIR/${package}.log"
    if [ ! -f "$VERSION_FILE" ]; then
        echo "⚠️ Version file for $package not found. Skipping."
        continue
    fi

    # 读取版本并遍历
    while IFS= read -r version; do
        echo "🔁 Processing version: $version"

        # VENV_DIR="$HOME/pyenvs/tmpbuild_${package}_$version"
        VENV_DIR="$HOME/pyenvs/tmpbuild_version"

        # 清理旧虚拟环境
        if [ -d "$VENV_DIR" ]; then
            echo "🧹 Removing old virtualenv at $VENV_DIR"
            rm -rf "$VENV_DIR"
        fi

        DIST_DIR="$HOME/pyenvs/store"

        # 创建新的虚拟环境
        echo "📦 copy virtualenv..."
        # python3 -m venv "$VENV_DIR"
        cp -r "$DIST_DIR/tmpbuild_version" "$VENV_DIR" 
        source "$VENV_DIR/bin/activate"

        # 安装工具和指定版本的包
        echo "⬆️ Installing $package==$version"
        # pip install --upgrade pip setuptools wheel twine
        if ! pip install --verbose "$package==$version"; then
            echo "⚠️ Failed to install $package==$version" >> "$SCRIPT_DIR/failed.log"
            continue  # 如果安装失败，跳过当前包并继续处理下一个包
        fi

        # 执行上传脚本
        UPLOAD_SCRIPT="$SCRIPT_DIR/01upload_built_wheels.py"
        if [ -f "$UPLOAD_SCRIPT" ]; then
            echo "🚀 Running upload_built_wheels.py for $package==$version"
            if ! python "$UPLOAD_SCRIPT"; then
                echo "⚠️ Failed to run upload_built_wheels.py for $package==$version" >> "$SCRIPT_DIR/failed.log"
                continue  # 如果上传失败，跳过当前包并继续处理下一个包
            fi
        else
            echo "⚠️ upload_built_wheels.py not found in $SCRIPT_DIR" >> "$SCRIPT_DIR/failed.log"
            continue  # 如果上传脚本不存在，跳过当前包
        fi

        deactivate
        sleep 5
        echo "🗑️ Removing $VENV_DIR"

        rm -rf "$VENV_DIR" || echo "❌ Failed to remove $VENV_DIR"

        echo "✅ Done for $package==$version"

        echo "Removing tmp..........."

        rm -rf "~/mytmpversion/*" || echo "❌ Failed to remove mytmpversion"

        echo "---------------------------------------------"
    done < "$VERSION_FILE"

    # 删除版本文件
    rm -rf "$VERSION_FILE"
    echo "🗑️ Removed version file for $package: $VERSION_FILE"

    echo "✅ Done for $package"
    echo "---------------------------------------------"
done < "$SCRIPT_DIR/packages.log"

echo "🎉 All done!"
