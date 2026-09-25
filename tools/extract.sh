#!/bin/bash

set -e -u -o pipefail

readonly ARC=${1:?arc path required}
readonly DST=${2:?dst path required}
readonly STRIP_COMPONENTS=${3:-0}

rm -rf "$DST"
mkdir -p "$DST"

case "$ARC" in
*.zip)
    if (( STRIP_COMPONENTS <= 0 )); then
        unzip -o -d "$DST" "$ARC"
    else
        tmpdir="$DST".temp
        trap 'rm -rf "$tmpdir"' EXIT
        mkdir -p "$tmpdir"
        unzip -o -d "$tmpdir" "$ARC"
        depth=$((STRIP_COMPONENTS + 1))
        find "$tmpdir" -mindepth "$depth" -maxdepth "$depth" -exec mv -t "$DST" {} +
    fi
;;
*.tar|*.tar.*)
    tar xvf "$ARC" -C "$DST" --strip-components="$STRIP_COMPONENTS"
;;
*.gz)
    if (( STRIP_COMPONENTS > 0 )); then
        return 0
    fi
    dstname=$(basename "$ARC")
    gunzip -k "$ARC" -c > "$DST/${dstname%.gz}"
;;
*)
    echo >&2 "unsupported archive ${ARC@Q}"
    return 1
;;
esac
