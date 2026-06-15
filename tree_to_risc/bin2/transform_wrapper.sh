#!/bin/bash
# Wrapper to call the pre-built binary, avoiding dune exec startup delay
exec "$(dirname "$0")/../_build/default/bin2/transform.exe" "$@"
