#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_FOLDER="$SCRIPT_DIR/scripts"
LOG_DIR="$SCRIPT_DIR/logs"
FAILED_FILE="$SCRIPT_DIR/failed.txt"

# 确保日志目录存在并清空
mkdir -p "$LOG_DIR"
> "$FAILED_FILE"
rm -f "$LOG_DIR"/*.log

while true; do
    echo "🌀 Starting script execution at $(date)"

    for script in "$SCRIPTS_FOLDER"/*.sh; do
        script_name="$(basename "$script")"
        log_file="$LOG_DIR/${script_name}.log"

        echo "▶️ Running $script_name..."

        # 执行脚本并捕获输出和错误
        if bash "$script" >"$log_file" 2>&1; then
            echo "✅ $script_name completed successfully."
        else
            echo "❌ $script_name FAILED. See $log_file"
            echo "$script_name" >> "$FAILED_FILE"
        fi
    done

    echo "⏳ All scripts finished. Sleeping for 24h..."
    sleep 86400
done
