#!/usr/bin/env bash
# Update Invidious Instances
set -euo pipefail

JSON_DEST="$HOME/bin/txt-files/invidious.json"

curl "https://api.invidious.io/instances.json?pretty=1&sort_by=type,users" > "$JSON_DEST"
