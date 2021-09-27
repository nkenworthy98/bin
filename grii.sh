#!/usr/bin/env bash
# Get Random Invidious Instance
#
# Make sure to run uii.sh before running this in order to grab
# latest invidious instances data
set -euo pipefail

# Grab a random invidious instance where the 30dRatio is greater than 95
jq -r '.[][1] | select(.monitor."30dRatio" > 95) | .uri' txt-files/invidious.json | shuf -n 1
