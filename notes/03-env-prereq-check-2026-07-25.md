# 环境前提检查报告（2026-07-25）

只读检查；未安装组件、未改权限、未启动 VM。

## 总评

**尚不能开始完整 QEMU+KVM / Firecracker 实验。**  
Windows 11 + BIOS 虚拟化已就绪，但 **WSL/WSL2 未安装**，因此内核、`/dev/kvm`、发行版均无法验证。需先安装 WSL2（建议 Ubuntu 24.04）并确认嵌套虚拟化后再做第 0 课 Linux 侧检查。

## 逐项结论

| # | 检查项 | 结论 | 依据摘要 |
| --- | --- | --- | --- |
| 1 | Windows 版本（Win11 / build） | **满足** | Win11 专业版，Build **26200** |
| 2 | BIOS/UEFI 虚拟化 | **满足** | Hyper-V Requirements 四项均为 Yes；`HyperVRequirementVirtualizationFirmwareEnabled=True` |
| 3 | WSL 已安装且为 WSL2 | **不满足** | `wsl --status` exit 50：子系统未安装 |
| 4 | WSL 内核较新 | **无法判断** | 无可用发行版 / 未安装 WSL |
| 5 | 嵌套虚拟化 / `/dev/kvm` | **无法判断** | 依赖 WSL2，当前无法进入 Linux |
| 6 | Ubuntu 22.04/24.04 | **不满足** | 无已注册发行版 |

补充：`HyperVisorPresent=False`（当前未加载 Hyper-V 管理程序）。安装并启用 WSL2 / Virtual Machine Platform 后通常会变为 True，属预期变化。

## 关键命令输出摘要

```
Caption / OS Name : Microsoft Windows 11 专业版
Version / Build   : 10.0.26200 (Build 26200)
Architecture      : 64-bit / x64-based PC

Hyper-V Requirements:
  VM Monitor Mode Extensions: Yes
  Virtualization Enabled In Firmware: Yes
  Second Level Address Translation: Yes
  Data Execution Prevention Available: Yes

HyperVisorPresent: False

wsl --status / wsl -l -v:
  exit=50
  未安装适用于 Linux 的 Windows 子系统。
  可通过运行 “wsl.exe --install” 进行安装。
  https://aka.ms/wslinstall
```

## 最短修复步骤

1. **以管理员 PowerShell** 安装 WSL2 + Ubuntu（推荐 24.04）：
   ```powershell
   wsl --install -d Ubuntu-24.04
   ```
   或默认发行版：`wsl --install`，然后按提示重启并完成 Ubuntu 首次用户创建。
2. 确认版本：
   ```powershell
   wsl -l -v
   wsl --status
   wsl uname -r
   ```
   发行版 VERSION 应为 **2**；内核建议 ≥ 5.15（越新越好，便于 `/dev/kvm`）。
3. 在 WSL 内检查 KVM：
   ```bash
   ls -l /dev/kvm
   egrep -c '(vmx|svm)' /proc/cpuinfo
   ```
   若无 `/dev/kvm`：在 **.wslconfig** 启用嵌套虚拟化后 `wsl --shutdown` 再开：
   ```ini
   [wsl2]
   nestedVirtualization=true
   ```
4. 回到仓库重跑：
   ```powershell
   .\experiments\00-env-check\check-env.ps1
   wsl -- bash ./experiments/00-env-check/check-env.sh
   ```

## 下一步建议

- 先完成上述 WSL2 安装与 `/dev/kvm` 验证，再进入路线图第 0/1 周实验。
- 在拿到 `/dev/kvm` 之前：可读笔记与源码对照；Windows 侧 QEMU 若使用 TCG/WHPX，**不能**替代 Firecracker 所需的 Linux KVM 路径。
