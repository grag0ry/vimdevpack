#!/bin/sh

git=$1
[ -z "$git" ] && git=git

set -x
$git reset .
$git checkout .
$git fetch origin
default_branch=$(LANG=C $git remote show origin \
                | awk '$1 == "HEAD" && $2 == "branch:" {print $3}')
$git checkout "$default_branch"
$git checkout .
$git reset --hard origin/"$default_branch"
$git clean -fdx
$git pull
