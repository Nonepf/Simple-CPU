# Simple-CPU
My CPU implementation while learning DDCA.

---
## 1. 项目说明

这是一个动手实现 CPU 的小项目，根据 *Digital Design and Computer Architecture*(DDCA) 一书中关于三种类型 CPU 的描述，自己使用 SystemVerilog 进行实现，并在 Questa 上面进行仿真。

除了测试使用的汇编代码使用 AI 生成外，所有代码均由个人独立编写。

此项目所设计的 CPU 支持以下指令：

| 指令类型    |       |       |       |      |       |
| ------- | ----- | ----- | ----- | ---- | ----- |
| 分支      | `beq` |       |       |      |       |
| 内存访问    | `lw`  | `sw`  |       |      |       |
| `R` 型指令 | `add` | `sub` | `and` | `or` | `slt` |

---
## 2. 进度

- [x] 单周期 CPU
- [x] 多周期 CPU
- [-] 流水线 CPU

流水线 CPU 的主要设计已经完成，但还是没有跑出来，存在 bug.