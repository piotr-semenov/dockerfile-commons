#!/bin/sh
# reduce_alpine.sh - Reduces the Alpine system to specified batch of executables/folders.

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
    ./reduce_alpine.sh /target busybox sh ash java
USAGE
  exit $1
}

if [[ $# -lt 2 ]]; then
  usage 1
fi


target_dir=$1
mkdir -p $target_dir
shift

# Locate the dependencies of the executables.
executables=
others=
for name in $@; do
  path=$(which $name || true)
  if [[ $path ]]; then
    executables="$executables $path"
  else
    others="$others $name"
  fi
done
echo executables=$executables
echo others=$others

deps=$(echo $executables |\
       xargs -n1 readlink -f |\
       xargs -n1 ldd |\
       awk '/statically/{next;} /=>/ { print $3; next; } { print $1 }' |\
       sort | uniq |\
       xargs -n1 readlink -f)
echo deps=$deps


# Rsync.
apk update
apk add --no-cache rsync

rsync -Rr --links $others /etc/ssl $target_dir
rsync -R --copy-links $executables $deps $target_dir

apk del rsync
