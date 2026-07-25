# 本地预览 GitBook / HonKit 风格笔记（不读取、不上传任何 token）
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Error "需要先安装 Node.js（含 npm），然后重新运行本脚本。"
}

Write-Host "Starting local book preview (honkit serve)..."
npm run serve
