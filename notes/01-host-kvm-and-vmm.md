# 第一课：宿主、KVM 与 VMM 的边界

## 本课问题

运行 QEMU 或 Firecracker 时，到底是谁在执行 guest 指令？Windows、WSL2、Linux、KVM 和 VMM 各负责什么？

## 最小心智模型

```text
guest kernel / application
        │ 虚拟 CPU、RAM、设备
QEMU 或 Firecracker（用户态 VMM）
        │ ioctl(/dev/kvm)；设备后端 I/O
Linux KVM + 调度器 + 内存管理
        │ VT-x/AMD-V 等硬件能力
physical CPU / memory / devices
```

- **VMM** 创建并配置虚拟机，维护用户态设备模型，处理 VM exit。
- **KVM** 是 Linux 内核虚拟化基础设施，借助硬件虚拟化运行 vCPU。
- **CPU** 在 KVM 路径中直接执行大部分非特权 guest 指令；敏感事件退出到 KVM/VMM。
- **TCG** 是 QEMU 的另一条 CPU 执行路径，可软件翻译 guest 指令，不要求 `/dev/kvm`，但通常更慢。
- **Firecracker** 只走 Linux/KVM 路径；没有 KVM 就不能用 TCG 降级运行 microVM。

## Windows 与 WSL2

Windows 原生 QEMU 可以使用 TCG，也可能使用 WHPX；这不等价于 Linux KVM。Firecracker 的目标运行环境是 Linux/KVM。

WSL2 自身运行在轻量虚拟机中。它适合安装编译工具、读源码、运行 QEMU TCG；能否在 WSL2 里进一步使用 `/dev/kvm` 属于嵌套虚拟化问题，应以实验结果为准。若不可用，选择：

1. 继续在 WSL2 做源码阅读与 QEMU TCG 实验；
2. 使用支持嵌套虚拟化且暴露 KVM 的 Linux VM；
3. 使用原生 Linux 或远程 Linux/KVM 主机完成 Firecracker 实验。

## 动手

在仓库根目录运行：

```bash
bash experiments/00-env-check/check-env.sh
```

逐项回答：

1. 当前 shell 是 Windows、WSL2、Linux VM 还是原生 Linux？
2. CPU 架构是什么？Linux 是否报告 `vmx`（Intel）或 `svm`（AMD）？
3. `/dev/kvm` 是否存在？当前用户是否可读写？
4. `qemu-system-x86_64`、Rust、Firecracker 哪些已安装？
5. 当前环境可做 QEMU TCG、QEMU+KVM、Firecracker+KVM 中的哪些实验？

## 理解 `/dev/kvm` 的三个结果

- **不存在**：当前 Linux 内核没有可用/暴露的 KVM 设备；安装用户态工具不会自动解决。
- **存在但不可读写**：通常是用户组或设备权限问题。先查看所有权，不要直接用宽泛的 `chmod 777`。
- **可读写**：只是必要条件；仍需匹配 CPU 架构、可用内核能力和正确 VMM 配置。

## QEMU 与 Firecracker 的第一个对照

| 问题 | QEMU | Firecracker |
| --- | --- | --- |
| 无 KVM 能否运行 | 可选择 TCG | 不可运行 microVM |
| 谁提供 CPU 路径 | TCG 或加速器（Linux 常用 KVM） | KVM |
| 设备为什么不同 | 追求广泛机器兼容和用途 | 只保留 microVM 需要的精简集合 |
| 配置入口 | CLI/QMP/机器模型 | API + 显式资源配置 |

## 课后记录模板

```text
环境：
虚拟化层级：
/dev/kvm 结果：
可执行的三类路径：
我原先的误解：
一个仍待验证的问题：
```

下一课将从“进程启动”走到“第一个 vCPU 进入 guest”，重点找 VM 创建、guest RAM 注册和 vCPU 运行三个事件。
