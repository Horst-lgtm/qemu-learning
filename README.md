# QEMU × Firecracker 底层学习实验室

**[在线阅读（GitBook）](https://horst.gitbook.io/horst-docs)**

通过对照拆解 QEMU 与 Firecracker，系统学习虚拟机启动、CPU 虚拟化、内存、设备、中断、I/O 和安全边界。

QEMU 是通用机器模拟器与虚拟化器：既能通过 TCG 做跨架构指令翻译，也能通过 KVM 等加速器运行硬件虚拟化 guest。Firecracker 是面向 microVM 的 Linux/KVM 虚拟机监控器（VMM），不是“纯模拟器”；它用 Rust 实现精简设备模型，主动缩小功能面与攻击面。

## 第一阶段目标

先建立可重复的 Linux/KVM 实验环境和统一问题清单，再读启动主线。不要一开始下载和编译两个大型源码树。

1. 运行安全的环境检查，理解 Windows、WSL2、Linux 与 KVM 的边界。
2. 用相同问题对照两者：进程如何启动、VM 如何创建、vCPU 如何运行、guest 内存如何映射、设备如何暴露。
3. 跑通最小 guest 后，再按需获取源码并定位调用链。

详细路线见 [notes/00-overview-and-roadmap.md](notes/00-overview-and-roadmap.md)，第一课见 [notes/01-host-kvm-and-vmm.md](notes/01-host-kvm-and-vmm.md)。

## 立即开始

Windows 主机推荐使用 **WSL2 + Linux 发行版** 做阅读、构建和 QEMU 软件模拟实验。Firecracker 需要 Linux/KVM；WSL2 中是否能访问 `/dev/kvm` 取决于 Windows/WSL 版本、内核及嵌套虚拟化配置，不能仅凭“运行在 WSL2”推定可用。最稳定的完整实验环境仍是启用 KVM 的原生 Linux 或 Linux 虚拟机/远程主机。

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\experiments\00-env-check\check-env.ps1
wsl -- bash ./experiments/00-env-check/check-env.sh
```

或在 Linux/WSL2 中运行：

```bash
bash ./experiments/00-env-check/check-env.sh
```

脚本只读取系统信息和工具版本，不安装软件、不修改配置、不启动虚拟机。

## 目录

- `notes/`：架构总览、路线和逐课笔记。
- `experiments/`：可重复的小实验；`00-env-check` 是起点。
- `SUMMARY.md` / `book.json`：GitBook（HonKit）目录与书籍元数据，便于本地预览或同步到 GitBook Cloud。
- `qemu/`：后续可选的 QEMU 源码目录，已被 Git 忽略。
- `firecracker/`：后续可选的 Firecracker 源码目录，已被 Git 忽略。
- `resources/`：后续整理官方文档、论文和调用链索引。

## 笔记做成 GitBook

可以。本仓库已按经典 GitBook 风格组织：`SUMMARY.md` 是侧栏目录，现有路线与实验笔记已编入。

本地预览（需 Node.js）：

```bash
npm run serve
```

Windows PowerShell：

```powershell
.\scripts\preview-book.ps1
```

发布到 GitBook Cloud 时，优先用官方 **Git Sync** 绑定 GitHub/GitLab，不要把 `gittoken` 或 `.env` 提交进仓库。详细步骤见 [notes/02-how-to-publish-gitbook.md](notes/02-how-to-publish-gitbook.md)。

## 后续获取源码

完成环境检查后再按需获取，避免现在下载巨型仓库：

```bash
git clone --filter=blob:none --no-checkout https://gitlab.com/qemu-project/qemu.git qemu
git clone --filter=blob:none --no-checkout https://github.com/firecracker-microvm/firecracker.git firecracker
```

随后选择明确版本（优先稳定 tag），记录 commit，再执行稀疏或完整 checkout。

