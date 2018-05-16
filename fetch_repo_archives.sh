#!/usr/bin/env bash

set -e -u

branch=master
force=false
while getopts "c:b:f" arg; do
  case "$arg" in
    c) cache=$OPTARG;;
    b) branch=$OPTARG;;
    f) force=true;;
  esac
done
shift $((OPTIND-1))

fetch_archive() {
  repo=$1
  dest=$2

  tmp=$(mktemp -dt audit_archive_XXXXXX)
  trap 'rm -rf "$tmp"' RETURN
  trap 'echo Fatal error while fetching $repo' EXIT
  git archive --format=tar --remote="$repo" -o "$tmp/archive.tar" "$branch"
  gzip "$tmp/archive.tar"
  mv "$tmp/archive.tar.gz" "$dest"
  trap - EXIT
  return 0
}

for repo in "$@"; do
  dest=$cache/$(basename "$repo" .git).tgz
  if [[ -f "$dest" ]] && ! $force; then
    echo "Skipping $repo, $dest found locally, use -f to overwrite"
    continue
  fi
  if ! git ls-remote --exit-code "$repo" > /dev/null; then
    echo "Skipping $repo, could not fetch $branch"
    continue
  fi
  fetch_archive "$repo" "$dest"
done