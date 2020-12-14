#!/bin/sh
# curl_and_gpgverify.sh - Verifies the GPG file signature.

# shellcheck shell=sh
set -e

usage()
{
    cat <<USAGE >&2
Usage:
    ./curl_and_gpgverify.sh [-v] <url/to/signature> <url/to/file> [keyserver]

Description:
    This downloads file to current directory with its GPG signature and verifies.
    The keyservers used by default is hkps://keyserver.ubuntu.com.

    Use -v option to see the GPG details.

Requires:
    curl, gnupg packages.

Examples:
    PARIGP_PREFIX=http://pari.math.u-bordeaux.fr/pub/pari/ ./curl_and_gpgverify.sh -v "$PARIGP_PREFIX/GP2C/gp2c-0.0.12.tar.gz.asc"\
                                                                                      "$PARIGP_PREFIX/GP2C/gp2c-0.0.12.tar.gz"
USAGE
    exit "$1"
}


if [ "$1" = "-v" ]; then
    curl_opts=
    gpg_redirection=

    shift
else
    curl_opts=-s
    gpg_redirection=1> /dev/null 2>&1
fi

keyserver=${3:-hkps://keyserver.ubuntu.com}

curl $curl_opts --remote-name-all -L "$1" -L "$2"

signature=$(basename "$1")
file=$(basename "$2")
if ! output=$(gpg --verify "$signature" "$file" 2>&1); then
    key_footprint=$(echo "$output" | grep -Eo '([0-9A-Z]{16,40})')
    gpg --keyserver "$keyserver" --recv-key "$key_footprint" $gpg_redirection

    gpg --verify "$signature" "$file" $gpg_redirection
fi
