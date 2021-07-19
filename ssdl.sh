#!/usr/bin/env bash
set -euo pipefail
# This script recursively downloads a static site
#
# EXAMPLES:
# Single site:
#
# ssdl.sh "$WEBSITE"
#
# Parallel downloads (requires GNU parallel):
#   (where sites.txt contains URLs on each line of file)
#
# cat sites.txt | parallel ssdl.sh {}

wget -r -np -p -E -k -K "$1"
