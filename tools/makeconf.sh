#!/bin/bash

# shellcheck disable=SC2034
set -e -u -o pipefail

instr-trim() {
    local -n str=$1
    str="${str#"${str%%[![:space:]]*}"}"
    str="${str%"${str##*[![:space:]]}"}"
}

str-trim() { local s=$1; instr-trim s; print "%s\n" "$s"; }

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
if [[ -n $CFG_DOTNET_NATIVE ]]; then
    CFG_DOTNET_SDKS=$(dotnet --list-sdks | awk '{print $1}')
else
    : "${CFG_DOTNET_SDKS:="LTS"}"
fi

: "${CFG_NODEJS_NATIVE=$([[ -n $(command -v node) ]] && echo 1 || echo)}"

if [[ -z ${CFG_LSP+DEFINED} ]]; then
    lsp=(csharp-ls powershell-es pyright bash-language-server clangd roslyn-ls)
    CFG_LSP=
    CFG_LSP_NATIVE=
    for t in "${lsp[@]}"; do
        [[ -n $(command -v "$t") ]] && CFG_LSP_NATIVE+=$t$' ' || CFG_LSP+=$t$' '
    done
    instr-trim CFG_LSP
    instr-trim CFG_LSP_NATIVE
fi

if [[ -z ${CFG_TOOLS+DEFINED} ]]; then
    tools=(shellcheck tree-sitter)
    CFG_TOOLS=
    CFG_TOOLS_NATIVE=
    for t in "${tools[@]}"; do
        [[ -n $(command -v "$t") ]] && CFG_TOOLS_NATIVE+=$t$' ' || CFG_TOOLS+=$t$' '
    done
    instr-trim CFG_TOOLS
    instr-trim CFG_TOOLS_NATIVE
fi

while IFS= read -r var; do
    if [[ -n ${!var:-} ]]; then
        printf "override %s = %s\n" "$var" "${!var}"
    else
        printf "override %s =\n" "$var"
    fi
done < <(set | sed -n -e 's/^\(CFG_\w\+\)=.*/\1/p' | sort)
