#!/bin/bash
set -e  # 如果任何命令失败则退出
set -u  # 使用未定义变量时报错

echo "🔄 更新 apt 源并安装构建依赖..."
sudo apt update
sudo apt install -y \
    python3 python3-dev python3-pip python3-venv \
    build-essential libffi-dev libssl-dev \
    libbz2-dev libreadline-dev libsqlite3-dev \
    zlib1g-dev libncursesw5-dev libgdbm-dev \
    libnss3-dev liblzma-dev swig \
    autoconf automake libtool \
    zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev \
    tcl-dev tk-dev libharfbuzz-dev libfribidi-dev libxcb1-dev \
    clang lld ninja-build libxml2-dev libxslt1-dev \
    curl libjpeg-dev libhdf5-dev \
    gfortran libopenblas-dev \
    libgtk-3-dev python3-bs4

echo "✅ Python 依赖安装完成"

pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
pip config set global.extra-index-url https://git.spacemit.com/api/v4/projects/33/packages/pypi/simple


PYPIRC_PATH="$HOME/.pypirc"

# 如果存在先删除
if [ -f "$PYPIRC_PATH" ]; then
    echo "🧹 Removing existing $PYPIRC_PATH"
    rm -f "$PYPIRC_PATH"
fi

# 写入新内容
cat > "$PYPIRC_PATH" <<EOF
[distutils]
index-servers =
    gitlab

[gitlab]
repository = https://git.spacemit.com/api/v4/projects/33/packages/pypi
username = xxx
password = xxx
EOF



echo "📥 安装 Rust 工具链..."
# -y 自动确认安装
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

echo "🔁 加载 Rust 环境变量..."
source "$HOME/.cargo/env"

echo "⏫ 更新 Rust 工具链..."
rustup update

echo "✅ Rust 安装完成"

# 可选：输出版本验证
echo ""
echo "🧪 Python 版本：$(python3 --version)"
echo "🧪 Rust 版本：$(rustc --version)"
echo "🧪 Cargo 版本：$(cargo --version)"
