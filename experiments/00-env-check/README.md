# 实验 00：只读环境检查

目标是识别当前环境能运行哪条学习路径，不安装依赖、不修改权限、不启动 VM。

## Windows PowerShell

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\experiments\00-env-check\check-env.ps1
```

随后进入 WSL2 做 Linux 侧检查：

```powershell
wsl -- bash ./experiments/00-env-check/check-env.sh
```

如果 WSL 默认目录不是本仓库，请先在 WSL 中进入对应挂载路径，通常是：

```bash
cd /mnt/c/Users/wangz/Developer/qemu-learning
bash experiments/00-env-check/check-env.sh
```

## Linux / WSL2

```bash
bash experiments/00-env-check/check-env.sh
```

无需给脚本增加可执行权限。输出中的 `[INFO]` 表示能力缺失或尚未配置，不表示脚本失败。

## 判读矩阵

- 无 `/dev/kvm`：可以学习 QEMU TCG、源码和架构；不能在此环境运行 Firecracker microVM。
- `/dev/kvm` 存在但不可读写：先检查设备所有者和用户组，不要使用 `chmod 777`。
- `/dev/kvm` 可读写：可以继续准备 QEMU+KVM 和 Firecracker 实验。
- 没有 QEMU/Rust/Firecracker：先记录结果；下一步再按选择的 Linux 发行版安装，不由本实验自动处理。

请把输出和第一课末尾的记录模板一起保存到自己的学习笔记中。
