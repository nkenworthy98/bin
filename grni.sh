#!/usr/bin/env bash
# Get Random Nitter Instance
#
# Make sure to run uni.sh to get
# latest nitter.md
set -euo pipefail

NITTER_INSTANCES_PATH="$HOME/bin/txt-files/nitter.md"

# This assumes the nitter link comes before the Unicode check box,
# which shows if an instance is updated.
perl -ne 'if (/https:\/\/(?<link>[\w\.]+).*✅/){print "$+{link}\n";}' "$NITTER_INSTANCES_PATH" | shuf -n 1
