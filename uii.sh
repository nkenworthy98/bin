#!/usr/bin/env bash
# Update Invidious Instances
set -euo pipefail

curl "https://api.invidious.io/instances.json?pretty=1&sort_by=type,users" > txt-files/invidious.json
