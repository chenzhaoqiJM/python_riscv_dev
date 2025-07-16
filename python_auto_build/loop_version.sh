#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_FOLDER="$SCRIPT_DIR/version_build"
LOG_DIR="$SCRIPT_DIR/logs_version_build"
FAILED_FILE="$SCRIPT_DIR/failed_version_build.txt"

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

        # 同时输出到终端和日志文件
        if bash "$script" 2>&1 | tee "$log_file"; then
            echo "✅ $script_name completed successfully."
        else
            echo "❌ $script_name FAILED. See $log_file"
            echo "$script_name" >> "$FAILED_FILE"
        fi
    done

    echo "⏳ All scripts finished. Sleeping for 24h..."
    sleep 86400
done
