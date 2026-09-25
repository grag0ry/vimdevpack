#!/bin/bash

set -e -u -o pipefail

readonly plugin=${1:?plugin path required}
readonly state=${2:?state path required}
readonly branch=${3:-}

head=$(git -C "$plugin" rev-parse HEAD); readonly head
if [[ -n $branch ]]; then
    git -C "$plugin" fetch --depth=1 --prune origin "+refs/heads/$branch:refs/remotes/origin/$branch"
    git -C "$plugin" reset --hard "origin/$branch";
else
    git -C "$plugin" fetch --depth=1 --prune origin
    git -C "$plugin" remote set-head origin -a
    git -C "$plugin" reset --hard origin/HEAD
fi

if [[ $head != "$(git -C "$plugin" rev-parse HEAD)" ]]; then
    git -C "$plugin" clean -fdx
    touch "$state"
fi
