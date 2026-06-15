#!/bin/bash
set -u

stages=(
    typing
    resolution
    hir
    semantic_hir
    lir
    semantic_lir
    riscv
    semantic_riscv
)

stage_labels=(
    "Typing"
    "Resolution"
    "HIR Generation"
    "HIR Semantics "
    "LIR Generation"
    "LIR Semantic"
    "RiscV Generation"
    "RiscV Semantics"
)

CHECK=0
if [ "${1:-}" = "--check" ]; then
    CHECK=1
    shift
fi

color_gradient () {
    local pct=$1  # 0..100
    local r g b
    if [ "$pct" -le 50 ]; then
        r=5
        g=$(( pct * 5 / 50 ))
        b=0
    else
        r=$(( 5 - (pct-50) * 5 / 50 ))
        g=5
        b=0
    fi
    echo $(( 16 + 36*r + 6*g + b ))
}

progress_bar() {
    local value=$1
    local total=$2
    local width=20
    [ "$total" -eq 0 ] && total=1

    # Exact filled amount in "eighths of a block"
    local filled=$(( value * width * 8 / total ))
    local bar=""
    local i

    for ((i=0; i<width; i++)); do
        local remainder=$(( filled - i*8 ))
        local char=""
        if (( remainder >= 8 )); then
            char="█"
        elif (( remainder > 0 )); then
            case $remainder in
                1) char="▏" ;;
                2) char="▎" ;;
                3) char="▍" ;;
                4) char="▌" ;;
                5) char="▋" ;;
                6) char="▊" ;;
                7) char="▉" ;;
            esac
        else
            char=" "
        fi

        # Compute the block's percentage (0-100) along the bar for color
        local pct=$(( i * 100 / width ))
        local color
        color=$(color_gradient "$pct")
        # Append colored character
        if [ "$char" != " " ]; then
            bar+=$'\e[38;5;'"$color"$'m'"$char"$'\e[0m'
        else
            bar+=" "
        fi
    done

    printf "[%b] %3d/%d" "$bar" "$value" "$total"
}

# Check that an input path was provided
if [ $# -lt 1 ]; then
    echo "Bad usage, require 1 argument:"
    echo ".ilpml file or directory expected"
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
            echo "Error: $name execution failed"
        rm -f output.txt
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

process_file() {
    local file="$1"
    local mode="${2:-quiet}"

    local input_abs input_dir input_base
    input_abs="$(realpath "$file")"
    input_dir="$(dirname "$input_abs")"
    input_base="$(basename "$input_abs" .ilpml)"

    local hir_file="$input_dir/$input_base.hir"
    local print_file="$input_dir/$input_base.print"

    # ---- ILPML -> HIR (+ HIR semantics handled inside ja.sh) ----
    cd ilp_to_tree || exit 1
    ./ja.sh $([ "$CHECK" -eq 1 ] && echo --check) \
            $([ "$mode" = "verbose" ] && echo --verbose) \
            -o "$hir_file" "$input_abs"
    rc=$?
    cd ..
    [ "$rc" -ne 0 ] && return "$rc"

    # ---- HIR -> LIR -> RISCV ----
    if [ -f tree_to_risc/mel.sh ]; then # mel.sh is only distributed at step 2
        cd tree_to_risc || exit 1
        ./mel.sh $([ "$CHECK" -eq 1 ] && echo --check) \
                 $([ "$mode" = "verbose" ] && echo --verbose) \
                 "$hir_file"
        rc=$?
        cd ..
        return $rc
    fi
    return 5
}

# ---- Directory mode ----
if [ -d "$path" ]; then
    dir="$path"
    total=0
    typing_ok=0
    resolution_ok=0
    hir_ok=0
    semantic_hir_ok=0
    lir_ok=0
    semantic_lir_ok=0
    riscv_ok=0
    semantic_riscv_ok=0
    failed=0

    shopt -s nullglob
    ilpml_files=("$dir"/*.ilpml)
    shopt -u nullglob

    if [ ${#ilpml_files[@]} -eq 0 ]; then
        echo "No .ilpml files found in directory: $dir"
        exit 1
    fi

    for f in "${ilpml_files[@]}"; do
        ((total++))
        process_file "$f" quiet
        rc=$?
        printf "Compiling: %s ==> " "$f"

        if [ "$rc" -eq 0 ]; then
            printf "OK\n"
            for s in "${stages[@]}"; do
                (( ${s}_ok++ ))
            done
        else
            printf "FAILED (%s)\n" "${stage_labels[rc-1]}"
            ((failed++))
            for ((i=0; i<rc-1; i++)); do
                (( ${stages[i]}_ok++ ))
            done
        fi
    done

    echo
    echo "Summary for directory: $dir"
    echo "Total files: $total"
    echo
    printf "Typing           : "
    progress_bar "$typing_ok" "$total"
    echo
    printf "Resolution       : "
    progress_bar "$resolution_ok" "$total"
    echo
    printf "HIR Generation   : "
    progress_bar "$hir_ok" "$total"
    echo
    if [ "$CHECK" -eq 1 ]; then
        printf "HIR Semantics    : "
        progress_bar "$semantic_hir_ok" "$total"
        echo
    fi
    printf "LIR Generation   : "
    progress_bar "$lir_ok" "$total"
    echo
    if [ "$CHECK" -eq 1 ]; then
        printf "LIR Semantics    : "
        progress_bar "$semantic_lir_ok" "$total"
        echo
    fi
    printf "RISCV Generation : "
    progress_bar "$riscv_ok" "$total"
    echo
    if [ "$CHECK" -eq 1 ]; then
        printf "RISCV Semantics  : "
        progress_bar "$semantic_riscv_ok" "$total"
        echo
    fi
    printf "Failed        : $failed"
    echo

    printf "\nCode sizes:\n"
    # Count lines in the .ilpml, hir, lir and .s files
    # This is purely informative
    instr_count=$(find "$dir" -name '*.ilpml' -exec wc -l {} + 2>/dev/null | awk 'END{print $1+0}')
    printf "ilpml n° of lines: %s\n" "$instr_count"

    instr_count=$(find "$dir" -name '*.hir' -exec wc -l {} + 2>/dev/null | awk 'END{print $1+0}')
    printf "HIR n° of lines: %s\n" "$instr_count"

    instr_count=$(find "$dir" -name '*.lir' -exec wc -l {} + 2>/dev/null | awk 'END{print $1+0}')
    printf "LIR n° of lines: %s\n" "$instr_count"

    instr_count=$(find "$dir" -name '*.s' -exec wc -l {} + 2>/dev/null | awk 'END{print $1+0}')
    printf "riscv n° of lines: %s\n" "$instr_count"

# ---- Single-file mode ----
elif [ -f "$path" ]; then
    process_file "$path" verbose
    exit $?
else
    echo "Path is neither a file nor a directory: $path"
    exit 1
fi
