#!/bin/bash

# shellcheck disable=SC2034
set -e -u -o pipefail

: "${CFG_OS:=$(uname -s)}"

if [[ -n ${CFG_OSID:-} ]]; then
    true
elif [[ $(uname -s) = *CYGWIN* ]]; then
    CFG_OSID=cygwin
else
    eval "$(sed -n s/^ID=/CFG_OSID=/p /etc/os-release)"
fi

: "${CFG_WSL=$([[ $(uname -r) = *-microsoft-* ]] && echo 1 || echo)}"

: "${CFG_DEVENV:=devenv}"
: "${CFG_CACHE:=cache}"
: "${CFG_BINDIR:=devenv/bin}"

: "${CFG_DOTNET_NATIVE=$([[ -n $(command -v dotnet) ]] && echo 1 || echo)}"
: "${CFG_DOTNET_VERSION:=$([[ -n $CFG_DOTNET_NATIVE ]] && dotnet --version || echo 9.0)}"
: "${CFG_NODEJS_NATIVE=$([[ -n $(command -v node) ]] && echo 1 || echo)}"

: "${CFG_LSP="csharp-ls powershell-es pyright bash-language-server shellcheck clangd"}"

while IFS= read -r var; do
    if [[ -n ${!var:-} ]]; then
        printf "override %s = %s\n" "$var" "${!var}"
    else
        printf "override %s =\n" "$var"
    fi
done < <(set | sed -n -e 's/^\(CFG_\w\+\)=.*/\1/p' | sort)
