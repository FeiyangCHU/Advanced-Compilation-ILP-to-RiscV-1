#!/bin/bash
set -u

# Defaults
CHECK=0
MODE="quiet"

# Option parsing
while [[ "${1:-}" == -* ]]; do
    case "$1" in
        --check)
            CHECK=1
            shift
            ;;
        --verbose)
            MODE="verbose"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ $# -lt 1 ]; then
    echo "Usage:"
    echo "  mel.sh [--check] [--verbose] <hir|directory>"
    exit 1
fi

path="$1"

run_with_timeout() {
    local timeout_s="$1"
    local name="$2"
    local mode="$3"
    shift 3
    local cmd=( "$@" )

    timeout "${timeout_s}s" "${cmd[@]}" > output.txt
    status=$?

    if [ $status -eq 124 ]; then
        [ "$mode" = "verbose" ] && \
            echo "Error: $name timed out (possible infinite loop)"
        rm -f output.txt
        return 124
    elif [ $status -ne 0 ]; then
        [ "$mode" = "verbose" ] && \
            echo "Error: $name failed"
        return $status
    fi

    return 0
}

semantic_diff() {
    local name="$1"
    local print_file="$2"
    local mode="$3"
    local rc_fail="$4"

    if ! diff -q "$print_file" output.txt >/dev/null; then
        [ "$mode" = "verbose" ] && {
            echo "Error: $name semantic diff"
            diff "$print_file" output.txt
        }
        rm -f output.txt
        return "$rc_fail"
    fi

    rm -f output.txt
    return 0
}

# pipeline for a single .hir file

process_hir() {
    local hir_file="$1"

    local input_dir input_base
    input_dir="$(dirname "$hir_file")"
    input_base="$(basename "$hir_file" .hir)"

    local print_file="$input_dir/$input_base.print"
    local lir_file="$input_dir/$input_base.lir"
    local rv_file="$input_dir/$input_base.s"
    local exec_file="$input_dir/$input_base.exe"

    run_with_timeout 30 "Linearization" "$MODE" \
                     dune exec ./bin2/transform.exe "$hir_file" -- \
                     --lin \
                     --lir
    status=$?
    semantic_diff "LIR" "$print_file" "$MODE" 6 || return 6
    if [ "$status" -ne 0 ]; then return $status; fi

    run_with_timeout 30 "riscv generation" "$MODE" \
                     dune exec ./bin2/transform.exe "$lir_file" -- \
                     --to-riscv \
                     --no-eval

    if [ "$status" -ne 0 ]; then return $status; fi

    # ---- CFG / INTER rendering ----
    for cfg in "$input_dir/$input_base".*.cfg; do
        [ -e "$cfg" ] || continue
        dot -Tpng "$cfg" -o "${cfg%.cfg}_cfg.png"
        rm "$cfg"
    done

    for inter in "$input_dir/$input_base".*.inter; do
        [ -e "$inter" ] || continue
        dot -Tpng "$inter" -o "${inter%.inter}_inter.png"
        rm "$inter"
    done

    # ---- RISCV semantics ----
    if [ "$CHECK" -eq 1 ]; then
        riscv64-linux-gnu-gcc -static "$rv_file" ../riscv/runtime.c -o "$exec_file" || return 8

        run_with_timeout 1 "RISCV (qemu)" "$MODE" \
            qemu-riscv64 "$exec_file" || return 8

        semantic_diff "RISCV" "$print_file" "$MODE" 8 || return 8
    fi

    return 0
}

# ---- Directory mode ----
if [ -d "$path" ]; then
    dir="$path"

    shopt -s nullglob
    hir_files=("$dir"/*.hir)
    shopt -u nullglob

    if [ ${#hir_files[@]} -eq 0 ]; then
        echo "No .hir files found in directory: $dir"
        exit 1
    fi

    total=0
    failed=0

    for hir in "${hir_files[@]}"; do
        ((total++))
        process_hir "$hir"
        rc=$?
        printf "Compiling: %s ==> " "$hir"
        if [ "$rc" -eq 0 ]; then
            printf "OK\n"
        else
            printf "FAILED "
            ((failed++))
            case $rc in
                5) printf "(during linearization)\n";;
                6) printf "(during linear semantic check)\n";;
                7) printf "(during lowering)\n";;
                8) printf "(during riscv semantic check)\n" ;;
                *) printf "(unexpectedly??)\n" ;;
            esac
        fi
    done

    echo
    echo "Summary for directory: $dir"
    echo "  Total:  $total"
    echo "  Failed: $failed"
    exit 0
# ---- Single-file mode ----
elif [ -f "$path" ]; then
    hir_file="$(realpath "$path")"
    process_hir "$hir_file"
    exit $?

else
    echo "Path is neither a file nor a directory: $path"
    exit 1
fi
