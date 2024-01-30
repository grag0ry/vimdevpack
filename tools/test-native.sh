#!/bin/sh

(
    set -e
    case "$1" in
        dotnet)
            bin=$(which $1)
            test -n "$bin"
            test -x "$bin"
            version=$2
            [ "$("$bin" --version | cut -d"." -f1)" = "$version" ]
            true
            ;;
        *)
            bin=$(which $1)
            test -n "$bin"
            test -x "$bin"
            true
            ;;
    esac
) 2>/dev/null
[ $? -eq 0 ] && echo native || echo local

