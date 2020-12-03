#!/bin/sh
# reduce_alpine.sh - Reduces the Alpine system to specified batch of executables/folders.

# shellcheck shell=sh
set -e

usage()
{
    cat <<USAGE >&2
Usage:
    ./reduce_alpine.sh [-v] <targetdir> <names...>

Description:
    This places all the folders recursively, files, and executables along with their dependencies
    to the target folder if missed.

    Use -v option to see the details.

Examples:
    ./reduce_alpine.sh -v /target busybox sh ash /etc/ssl node
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

if [ "$1" = "-v" ]; then
    verbose=1
    shift
else
    verbose=0
fi

target_dir=$1
mkdir -p "$target_dir"
shift

# Split the input names into set of executables and set of others (misc. files, dirs).
# As a result,
#     - $executables will contain original names along with their resolutions if possible.
#     - $others will contain only original names.
#     - both of $executables and $others contain only the unique values.
executables="/bin/sh /usr/bin/env /bin/busybox"
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

# Calculate the dynamic dependencies for set of executables.
# As a result, $deps will contain unique normalized paths.
# shellcheck disable=SC2016
deps=$(echo "$resolved_executables" |\
       xargs -n1 ldd 2> /dev/null |\
       awk '/statically/{next;} /=>/ { print $3; next; } { print $1 }' |\
       xargs -n1 -I@ sh -c 'which @ || echo @' |\
       xargs -n1 -I@ sh -c 'echo $(realpath $(dirname @))/$(basename @)')
resolved_deps=$(resolve "$deps")
deps=$(minify "$resolved_deps $deps")

if [ "$verbose" -eq "1" ]; then
    echo executables="$executables"
    echo deps="$deps"
    echo others="$others"
fi


# Rsync with target dir.
apk update
apk add --no-cache rsync

# shellcheck disable=SC2086
rsync -Rr --links $others "$target_dir"

# shellcheck disable=SC2086
rsync -R --links $executables $deps "$target_dir"

apk del rsync
