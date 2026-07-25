#!/usr/bin/env bash
# Read-only environment check for QEMU/Firecracker learning.
set -u

ok=0
warn=0

section() { printf '\n== %s ==\n' "$1"; }
found() { printf '[OK]   %s\n' "$1"; ok=$((ok + 1)); }
missing() { printf '[INFO] %s\n' "$1"; warn=$((warn + 1)); }
first_line() { "$@" 2>&1 | awk 'NR == 1 { print; exit }'; }

section "Host"
kernel="$(uname -s 2>/dev/null || printf unknown)"
release="$(uname -r 2>/dev/null || printf unknown)"
arch="$(uname -m 2>/dev/null || printf unknown)"
printf 'kernel: %s %s\narch:   %s\n' "$kernel" "$release" "$arch"

mode="unknown"
case "$kernel" in
    MINGW*|MSYS*|CYGWIN*)
        mode="Windows POSIX shell (Git Bash/MSYS/Cygwin); not a Linux/KVM host"
        ;;
    Linux)
        if grep -qi microsoft /proc/version 2>/dev/null; then
            mode="WSL2/WSL (KVM availability must be tested, not assumed)"
        else
            mode="Linux environment"
        fi
        ;;
    *)
        mode="Unix-like environment"
        ;;
esac
printf 'mode:   %s\n' "$mode"

section "Hardware virtualization hints"
case "$kernel" in
    Linux)
        if [ -r /proc/cpuinfo ] && grep -Eq '(^|[[:space:]])(vmx|svm)([[:space:]]|$)' /proc/cpuinfo; then
            found "CPU flags expose vmx/svm to this Linux environment"
        else
            missing "vmx/svm is not visible (may be unsupported, disabled, or hidden by nesting)"
        fi
        ;;
    *)
        missing "Skipping Linux CPU flag check outside a Linux kernel"
        ;;
esac

section "KVM"
case "$kernel" in
    Linux)
        if [ -e /dev/kvm ]; then
            found "/dev/kvm exists: $(ls -l /dev/kvm 2>/dev/null)"
            if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
                found "current user can read and write /dev/kvm"
            else
                missing "/dev/kvm exists but current user lacks read/write access"
            fi
        else
            missing "/dev/kvm does not exist; Firecracker and QEMU+KVM are unavailable here"
        fi
        ;;
    *)
        missing "/dev/kvm is a Linux interface; use WSL2 or a Linux host for this check"
        ;;
esac

section "Tools"
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
    found "QEMU: $(first_line qemu-system-x86_64 --version)"
elif command -v qemu-system-aarch64 >/dev/null 2>&1; then
    found "QEMU: $(first_line qemu-system-aarch64 --version)"
else
    missing "QEMU system emulator not found on PATH"
fi

if command -v rustc >/dev/null 2>&1; then
    found "Rust: $(first_line rustc --version)"
else
    missing "rustc not found on PATH"
fi

if command -v cargo >/dev/null 2>&1; then
    found "Cargo: $(first_line cargo --version)"
else
    missing "cargo not found on PATH"
fi

if command -v firecracker >/dev/null 2>&1; then
    found "Firecracker: $(first_line firecracker --version)"
else
    missing "firecracker binary not found on PATH"
fi

if command -v git >/dev/null 2>&1; then
    found "Git: $(first_line git --version)"
else
    missing "git not found on PATH"
fi

section "Interpretation"
printf '%s\n' \
  '- QEMU TCG can work without /dev/kvm.' \
  '- QEMU+KVM and Firecracker require usable Linux KVM.' \
  '- Firecracker is a KVM-based VMM, not a pure emulator.' \
  '- Missing tools are observations only; this script changes nothing.'

printf '\nSummary: %d checks OK, %d informational gaps.\n' "$ok" "$warn"
exit 0
