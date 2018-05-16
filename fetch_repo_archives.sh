#!/usr/bin/env bash

set -e -u

branch=master
while getopts "c:b:" arg; do
  case "$arg" in
    c) cache=$OPTARG;;
    b) branch=$OPTARG;;
  esac
done
shift $((OPTIND-1))

for repo in "$@"; do
  archive=$(mktemp -t audit_archive_XXXXXX.tar)
  git archive --format=tar --remote="$repo" -o "$archive" "$branch" && mv "$archive" "$cache/$(basename "$repo" .git).tar" || (rm "$archive"; echo "fatal: $repo"  >&2)
done