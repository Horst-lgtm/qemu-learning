#!/usr/bin/env bash
# 本地预览 GitBook / HonKit 风格笔记（不读取、不上传任何 token）
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v npm >/dev/null 2>&1; then
  echo "需要先安装 Node.js（含 npm），然后重新运行本脚本。" >&2
  exit 1
fi

echo "Starting local book preview (honkit serve)..."
npm run serve
