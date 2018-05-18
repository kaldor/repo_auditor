#!/usr/bin/env bash

set -e -u

for archive in "$@"; do
tar -tf "$archive" | sort | uniq -d -i -
done
