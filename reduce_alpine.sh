#!/bin/sh
# reduce_alpine.sh - Reduces the Alpine system to specified batch of executables/folders.

# shellcheck shell=sh
set -e

usage()
{
  cat <<USAGE >&2
Usage:
    ./reduce_alpine.sh <targetdir> <names...>

Description:
    This places all the folders recursively, files, and executables along with their dependencies
    to the target folder if missed.

Examples:
    ./reduce_alpine.sh /target busybox sh ash /etc java
USAGE
  exit "$1"
}

minify()
{
  echo "$@" | xargs -n1 echo | sort | uniq
}

resolve()
{
  echo "$@" | xargs -n1 readlink -f
}


if [ $# -lt 2 ]; then
  usage 1
fi


target_dir=$1
mkdir -p "$target_dir"
shift

# Locate the dependencies of the executables.
executables=
others=
for name in "$@"; do
  path=$(which "$name" || true)
  if [ "$path" ]; then
    executables="$executables $path"
  else
    others="$others $name"
  fi
done
resolved_executables=$(resolve "$executables")
executables=$(minify "$resolved_executables $executables")
others=$(minify "$others")

deps=$(echo "$executables" |\
       xargs -n1 ldd |\
       awk '/statically/{next;} /=>/ { print $3; next; } { print $1 }')
resolved_deps=$(resolve "$deps")
deps=$(minify "$resolved_deps $deps")


# Rsync.
apk update
apk add --no-cache rsync

# shellcheck disable=SC2086
rsync -Rr --links $others /etc/ssl "$target_dir"

# shellcheck disable=SC2086
rsync -R --links $executables $deps "$target_dir"

apk del rsync
