# ILP to RISC-V Compiler

A full-stack compiler that translates ILP (Imperative Language with Procedures) programs into RISC-V assembly. The compilation pipeline consists of two stages, implemented as independent sub-projects.

## Pipeline Overview

```
ILP Source → [ilp_to_tree] → Tree IR → [tree_to_risc] → RISC-V Assembly
```

### Stage 1: ILP → Tree (`ilp_to_tree/`, Java)

Compiles ILP programs into a Tree intermediate representation. ILP is a dynamically-typed language supporting int, float, bool, string, functions, and objects, while Tree IR operates on only int and float types. To bridge this gap, the compiler performs:

- **Static Type Inference** — infers types for all expressions in the ILP program using a flexible type system.
- **Overloading Resolution & Monomorphization** — resolves overloaded operators and monomorphizes generic constructs into concrete typed representations.
- **Code Emission** — generates Tree IR from the resolved, typed ILP representation.

### Stage 2: Tree → RISC-V (`tree_to_risc/`, OCaml)

Compiles the Tree IR down to RISC-V assembly. This backend performs:

- **Linearization** — transforms tree-structured IR into a linear sequence of instructions with explicit control flow.
- **Instruction Selection** — maps Tree IR nodes to RISC-V instructions.
- **Liveness Analysis** — computes variable liveness for register allocation.
- **Register Allocation** — assigns physical RISC-V registers to virtual registers, spilling to memory when necessary.

## Quick Start

```bash
chmod +x configure.sh && ./configure.sh   # Install dependencies
make                                       # Build both sub-projects
```

Compile an ILP source file to RISC-V:

```bash
./jamel.sh Samples/u01-1.ilpml
```

Compile with checkpoint verification:

```bash
./jamel.sh --check Samples/u01-1.ilpml
```

Run all tests:

```bash
make test
```

### Sub-project Quick Start

**ilp_to_tree** (ILP → Tree):

```bash
cd ilp_to_tree
make
./ja.sh Samples/u01-1.ilpml          # Produce .hir (Tree IR)
./ja.sh --check Samples/u01-1.ilpml  # Verify checkpoint
make test
```

**tree_to_risc** (Tree → RISC-V):

```bash
cd tree_to_risc
make
./mel.sh Samples/u01-1.hir           # Produce .s (RISC-V assembly)
./mel.sh --check Samples/u01-1.hir   # Verify checkpoints
make test
```

## Project Structure

```
Advanced-Compilation-ILP-to-RiscV/
├── ilp_to_tree/          # Stage 1: ILP → Tree IR (Java)
│   ├── ilp1/             #   Core compiler modules
│   ├── ilp2/             #   Extended compiler modules
│   └── Samples/          #   ILP test programs
├── tree_to_risc/         # Stage 2: Tree IR → RISC-V (OCaml)
│   ├── vmlib/            #   Tree IR frontend library
│   ├── compilelib/       #   Compilation backend library
│   └── Samples/          #   Tree IR test programs
├── Samples/              # Shared ILP samples
├── jamel.sh              # Full pipeline driver script
└── configure.sh          # Dependency installer script
```



# ILP 到 RISC-V 编译器

一个完整的全栈编译器，将 ILP（带过程的命令式语言）程序翻译为 RISC-V 汇编代码。编译流水线分为两个阶段，以两个独立的子项目实现。

## 流水线概览

```
ILP 源码 → [ilp_to_tree] → Tree IR → [tree_to_risc] → RISC-V 汇编
```

### 第一阶段：ILP → Tree (`ilp_to_tree/`, Java)

将 ILP 程序编译为 Tree 中间表示。ILP 是一种动态类型语言，支持 int、float、bool、string、函数和对象，而 Tree IR 仅支持 int 和 float 两种类型。为弥合这一差异，编译器执行以下步骤：

- **静态类型推导** — 使用灵活的类型系统推导 ILP 程序中所有表达式的类型。
- **重载解析与单态化** — 解析重载运算符，将泛型构造单态化为具体类型表示。
- **代码生成** — 从已解析、已类型化的 ILP 表示生成 Tree IR。

### 第二阶段：Tree → RISC-V (`tree_to_risc/`, OCaml)

将 Tree IR 编译为 RISC-V 汇编代码。此后端执行以下步骤：

- **线性化** — 将树形结构的 IR 转换为具有显式控制流的线性指令序列。
- **指令选择** — 将 Tree IR 节点映射到 RISC-V 指令。
- **活跃性分析** — 计算变量的活跃性信息，为寄存器分配做准备。
- **寄存器分配** — 将虚拟寄存器分配到物理 RISC-V 寄存器，必要时溢出到内存。

## 快速开始

```bash
chmod +x configure.sh && ./configure.sh   # 安装依赖
make                                       # 编译两个子项目
```

编译 ILP 源文件到 RISC-V：

```bash
./jamel.sh Samples/u01-1.ilpml
```

带检查点验证的编译：

```bash
./jamel.sh --check Samples/u01-1.ilpml
```

运行全部测试：

```bash
make test
```

### 子项目快速开始

**ilp_to_tree** (ILP → Tree)：

```bash
cd ilp_to_tree
make
./ja.sh Samples/u01-1.ilpml          # 生成 .hir（Tree IR）
./ja.sh --check Samples/u01-1.ilpml  # 验证检查点
make test
```

**tree_to_risc** (Tree → RISC-V)：

```bash
cd tree_to_risc
make
./mel.sh Samples/u01-1.hir           # 生成 .s（RISC-V 汇编）
./mel.sh --check Samples/u01-1.hir   # 验证检查点
make test
```

## 项目结构

```
Advanced-Compilation-ILP-to-RiscV/
├── ilp_to_tree/          # 第一阶段：ILP → Tree IR（Java）
│   ├── ilp1/             #   核心编译器模块
│   ├── ilp2/             #   扩展编译器模块
│   └── Samples/          #   ILP 测试程序
├── tree_to_risc/         # 第二阶段：Tree IR → RISC-V（OCaml）
│   ├── vmlib/            #   Tree IR 前端库
│   ├── compilelib/       #   编译后端库
│   └── Samples/          #   Tree IR 测试程序
├── Samples/              # 共享 ILP 示例
├── jamel.sh              # 完整流水线驱动脚本
└── configure.sh          # 依赖安装脚本
```
