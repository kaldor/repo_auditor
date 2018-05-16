#!/usr/bin/env bash

set -e -u

function absolutePath {
  if [[ ! "$1" =~ ^/ ]]; then
    echo "$(pwd -P)/$1"
  else
    echo "$1"
  fi
}

while getopts "a:" arg; do
  case "$arg" in
    a) archive=$OPTARG;;
  esac
done
shift $((OPTIND-1))

absArchive=$(absolutePath "$archive")

absTool=$(absolutePath $(which "$1"))
shift 1

workdir=$(mktemp -dt audit_archive_XXXXXX)
trap 'rm -rf "$workdir"' EXIT

cd "$workdir"
unzip -q "$absArchive"
"$absTool" "$@"