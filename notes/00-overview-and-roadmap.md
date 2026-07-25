# QEMU × Firecracker 对照总览与路线

## 先建立正确模型

两者都能承载虚拟机，但目标不同：

- **QEMU**：通用机器模拟器与虚拟化器。TCG 可以翻译 guest 指令，允许跨架构运行；配合 KVM 时，普通 guest 指令主要由真实 CPU 执行，QEMU 负责 VM 编排和丰富的机器/设备模型。
- **Firecracker**：运行于 Linux/KVM 之上的精简 VMM，面向快速启动、高密度和多租户 microVM。它不是纯模拟器，不提供 QEMU 那样的跨架构 TCG，也不追求完整 PC 兼容设备集合。

对照学习时，不问“谁更强”，而问“相同虚拟机职责为何采用不同边界”。

## 架构差异速览

| 维度 | QEMU | Firecracker |
| --- | --- | --- |
| 核心目标 | 通用、兼容、可移植、设备丰富 | microVM、低开销、快速启动、攻击面小 |
| CPU 执行 | TCG 软件翻译，或 KVM/其他加速器 | Linux KVM |
| 机器模型 | PC、服务器、开发板等大量平台 | 极简 x86_64/aarch64 microVM |
| 设备模型 | PCI、USB、显示、存储、网络等广泛支持 | 精简 virtio 与少量必要设备 |
| 控制面 | CLI、QMP、机器配置体系 | REST API 驱动的显式配置 |
| 实现重心 | C 为主，成熟且庞大的兼容体系 | Rust，组件和权限边界更克制 |
| 安全策略 | 可配置沙箱与隔离，功能面取决于配置 | jailer、seccomp、精简设备面与资源限制 |

## 七个共同底层主题

每个主题都用“概念 → 两边调用链 → 可观测实验 → 安全含义”学习。

1. **启动**：宿主进程入口、配置解析、VM 创建、内核/固件加载、vCPU 起跑点。
2. **CPU 虚拟化**：特权级、VM entry/exit、KVM ioctl、vCPU 线程；再对比 QEMU TCG 翻译块。
3. **内存**：guest physical address、host virtual address、内存槽、页表、MMIO 与脏页。
4. **设备**：设备模型、总线、virtio 队列、配置空间，以及“少设备为何更安全”。
5. **中断**：中断控制器、事件注入、irqfd/ioeventfd、virtio 通知。
6. **I/O**：PIO/MMIO、同步/异步 I/O、零拷贝机会、块与网络后端。
7. **安全边界**：guest→VMM→kernel→hardware 的信任链、进程权限、syscall/设备攻击面。

## 第一阶段：四周最小路线

### 第 0 课：环境与边界

- 运行 `experiments/00-env-check`。
- 画出 Windows/WSL2/Linux/KVM/CPU 的层级。
- 判定当前机器适合哪类实验，而不是强行启动 Firecracker。

### 第 1 周：一台 VM 如何开始运行

- QEMU：先观察命令行、machine、accelerator、内存和 vCPU 的配置关系。
- Firecracker：观察 API 配置顺序与 KVM VM/vCPU 创建。
- 产物：两张启动时序草图和一份“首次进入 guest 前发生了什么”的对照笔记。

### 第 2 周：CPU 与内存

- 跟踪 KVM 的 `/dev/kvm`、`KVM_CREATE_VM`、内存 region、`KVM_CREATE_VCPU`、`KVM_RUN`。
- 单独理解 QEMU TCG 的翻译块概念，避免把 TCG 与 KVM 路径混为一谈。
- 产物：guest 地址到宿主地址的映射图；列出触发 VM exit 的例子。

### 第 3 周：设备、中断与 I/O

- 用 virtio block/network 作为共同样本。
- 对比 QEMU 丰富设备模型与 Firecracker 精简设备集合。
- 产物：一次 virtqueue 通知从 guest 到后端再返回中断的路径。

### 第 4 周：安全边界与综合复盘

- 比较 QEMU 最小化配置与 Firecracker jailer/seccomp/资源约束。
- 区分 KVM 提供的 CPU/内存隔离和 VMM 用户态设备模型的攻击面。
- 产物：威胁模型、可观测证据，以及下一阶段源码阅读清单。

## 阅读方法

每次只追一条主线，记录：入口、关键数据结构、系统调用/`ioctl`、线程边界、退出条件。先运行发布版二进制和小实验，再 checkout 固定源码版本；不要从仓库目录树第一页漫读。

## 第一阶段完成标准

- 能准确解释 QEMU TCG、QEMU+KVM、Firecracker+KVM 三种路径的区别。
- 能解释 `/dev/kvm` 不存在、存在但无权限、CPU 不支持虚拟化三种状态。
- 能画出 vCPU、guest RAM、virtio 设备和中断的最小关系图。
- 能说明 Firecracker 缩小攻击面的手段及代价。
