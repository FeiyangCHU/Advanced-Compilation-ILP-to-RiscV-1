#!/bin/bash

set -e

# Install javac (Java compiler)
if ! command -v javac &> /dev/null; then
    echo "Installing OpenJDK (javac)..."
    sudo apt install -y default-jdk
else
    echo "javac is already installed."
fi

# Install OPAM (OCaml package manager) if not installed
if ! command -v opam &> /dev/null; then
    echo "Installing OPAM..."
    sudo apt install -y opam
else
    echo "OPAM is already installed."
fi

# Initialize OPAM if not already initialized
if [ ! -d "$HOME/.opam" ]; then
    echo "Initializing OPAM..."
    opam init -y --disable-sandboxing
fi

# Always load OPAM environment
eval $(opam env)

# Check if OCaml 4.14.0 switch exists
if ! opam switch list | grep -q '4.14.0'; then
    echo "Creating OCaml 4.14.0 switch..."
    opam switch create 4.14.0
    eval $(opam env)
else
    echo "OCaml 4.14.0 switch already exists."
fi

# Install Menhir via OPAM if not installed
if ! opam list --installed | grep -q '^menhir'; then
    echo "Installing Menhir..."
    opam install -y menhir
else
    echo "Menhir is already installed."
fi

# Install Dune via OPAM if not installed
if ! opam list --installed | grep -q '^dune'; then
    echo "Installing Dune..."
    opam install -y dune
else
    echo "Dune is already installed."
fi

# Install Graphviz (dot)
if ! command -v dot &> /dev/null; then
    echo "Installing Graphviz..."
    sudo apt install -y graphviz
else
    echo "Graphviz (dot) is already installed."
fi

# Install QEMU
if ! command -v qemu-system-riscv64 &> /dev/null; then
    echo "Installing QEMU..."
    sudo apt install -y qemu qemu-system-misc qemu-user
else
    echo "QEMU is already installed."
fi

# Install RISC-V GCC toolchain
if ! command -v riscv64-linux-gnu-gcc &> /dev/null; then
    echo "Installing RISC-V GCC toolchain..."
    sudo apt install -y gcc-riscv64-linux-gnu
else
    echo "RISC-V GCC toolchain is already installed."
fi

echo "All requested packages have been installed successfully!"
