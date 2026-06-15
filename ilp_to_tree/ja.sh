#!/bin/bash
set -u

CHECK="0"
MODE="quiet"

print_input=false
output_file=""

# Parse options
while [[ "${1:-}" == -* ]]; do
    case "$1" in
        -o)
            if [ $# -lt 2 ]; then
                echo "Missing argument after -o"
                exit 1
            fi
            output_file="$2"
            shift 2
            ;;
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

    # timeout "${timeout_s}s" "${cmd[@]}" > output.txt
    "${cmd[@]}" > output.txt
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

compile_file() {
    local f="$1"
    local hir_file

    input_abs="$(realpath "$f")"
    input_dir="$(dirname "$input_abs")"
    input_base="$(basename "$input_abs" .ilpml)"

    if [ -n "$output_file" ]; then
        hir_file="$output_file"
    else
        hir_file="${f%.ilpml}.hir"
    fi

    local print_file="$input_dir/$input_base.print"


    java -cp out:Java/src:target/generated-sources/antlr4:Java/jars/* \
         com.paracamplus.ilp2.treecompiler.CompilerMain2 "$f" -o "$hir_file"
    rc=$?
    [ "$rc" -ne 0 ] && return "$rc"

    # ---- HIR semantics ----
    if [ "$CHECK" -eq 1 ]; then
        cd ../tree_to_risc || exit 4
        hir_args=()
        [ "$MODE" = "verbose" ] && hir_args+=(--error-verbose)
        run_with_timeout 1 HIR "$MODE" \
                         dune exec ./bin1/vm.exe "$hir_file" -- "${hir_args[@]}" || exit 4
        semantic_diff "HIR" "$print_file" "$MODE" 4
        rc=$?
        cd ../ilp_to_tree
        [ "$rc" -ne 0 ] && return "$rc"
    fi

    return 0
}

# ---- Directory mode ----
if [ -d "$path" ]; then

    if [ -n "$output_file" ]; then
        echo "Error: -o option cannot be used when compiling a directory"
        exit 1
    fi

    dir="$path"
    shopt -s nullglob
    ilpml_files=("$dir"/*.ilpml)
    shopt -u nullglob

    if [ ${#ilpml_files[@]} -eq 0 ]; then
        echo "No .ilpml files found in directory: $dir"
        exit 1
    fi

    total=0
    succeeded=0
    typeok=0
    resolveok=0
    failed=0

    for f in "${ilpml_files[@]}"; do
        ((total++))
        compile_file "$f"
        rc=$?
        printf "Compiling: %s ===>" "$f"

        if [ "$rc" -eq 0 ]; then
            printf " OK\n"
            ((succeeded++))
            ((typeok++))
            ((resolveok++))
        else
            printf "FAILED "
            ((failed++))
            case "$rc" in
                1) printf "(during typing)\n";;
                2) ((typeok++))
                   printf "(during resolution)\n";;
                3) ((typeok++))
                   ((resolveok++))
                   printf "(during compilation)\n";;
                42) printf "(unexpectedly??)\n" ;;
            esac
        fi

        if [ "$print_input" = true ]; then
            outfile="${f%.ilpml}.hir"
            echo "----- INPUT: $f -----"
            cat "$f"
            echo "----- OUTPUT: $outfile -----"
            if [ -f "$outfile" ]; then
                cat "$outfile"
            else
                echo "(output file not found)"
            fi
        fi
    done

    echo
    echo "Summary for directory: $dir"
    echo "  Total:       $total"
    echo "  Typing:      $typeok"
    echo "  Resolution:  $resolveok"
    echo "  Compilation: $succeeded"
    echo "  Failed:      $failed"

    exit 0

# ---- Single-file mode ----
elif [ -f "$path" ]; then
    infile="$path"
    MODE="verbose"
    compile_file "$infile"
    status=$?
    exit "$status"

else
    echo "Path is neither a file nor a directory: $path"
    exit 1
fi
