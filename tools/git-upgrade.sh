#!/bin/sh

git=$1
[ -z "$git" ] && git=git

branch=$2
if [ -z "$branch" ]; then
    branch=$(LANG=C $git remote show origin \
                | awk '$1 == "HEAD" && $2 == "branch:" {print $3}')
fi

set -x
$git reset .
$git checkout .
$git fetch origin
$git checkout "$branch"
$git checkout .
$git reset --hard origin/"$branch"
$git clean -fdx
$git pull
