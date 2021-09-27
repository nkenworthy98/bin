#!/usr/bin/env bash
# Get Random Invidious Instance
#
# Make sure to run uii.sh before running this in order to grab
# latest invidious instances data
set -euo pipefail

INVIDIOUS_JSON_PATH="$HOME/bin/txt-files/invidious.json"

# Grab a random invidious instance where the 30dRatio is greater than 95
jq -r '.[][1] | select(.monitor."30dRatio" > 95) | .uri' "$INVIDIOUS_JSON_PATH" | shuf -n 1
