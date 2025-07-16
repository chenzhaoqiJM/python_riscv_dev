#!/usr/bin/env python3
import os
import subprocess
from pathlib import Path
from datetime import datetime
import shutil

# === 配置项 ===
PIP_CACHE_DIR = os.path.expanduser("~/.cache/pip/wheels")
# 如果目录不存在则创建
os.makedirs(PIP_CACHE_DIR, exist_ok=True)
RECORD_FILE = os.path.expanduser("~/.upload_whl_log.txt")
PYPI_REPO = "gitlab"  # ~/.pypirc 的名称

def find_built_wheels():
    print("🔍 Searching for built wheels in pip cache...")
    whls = list(Path(PIP_CACHE_DIR).rglob("*.whl"))
    whls = [w for w in whls if w.is_file()]
    if not whls:
        print("⚠️  No .whl files found.")
    return whls

def upload_whl(whl_path: Path):
    print(f"🚀 Uploading {whl_path.name} to PyPI repo: {PYPI_REPO}")
    subprocess.run(
        ["twine", "upload", "-r", PYPI_REPO, str(whl_path)],
        check=True
    )
    with open(RECORD_FILE, "a") as f:
        f.write(f"{datetime.now()} {whl_path.name}\n")

def clean_pip_cache():
    print("🧹 Cleaning pip cache directory...")
    shutil.rmtree(PIP_CACHE_DIR)
    os.makedirs(PIP_CACHE_DIR, exist_ok=True)

def main():
    whl_files = find_built_wheels()
    for whl_path in whl_files:
        try:
            upload_whl(whl_path)
        except subprocess.CalledProcessError:
            print(f"❌ Upload failed for {whl_path.name}")
        else:
            whl_path.unlink()  # 删除该 .whl 文件

    clean_pip_cache()

if __name__ == "__main__":
    main()
