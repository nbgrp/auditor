#!/usr/bin/env sh

set -eu

cd "$(realpath "$(dirname "$0")")"

find . -mindepth 1 -maxdepth 1 -type d -exec composer update --working-dir={} \;
