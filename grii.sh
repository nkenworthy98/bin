#!/bin/sh
# Get Random Invidious Instance
#
# Make sure to run uii.sh before running this in order to grab
# latest invidious instances data

INVIDIOUS_JSON_PATH="$HOME/bin/txt-files/invidious.json"

# Grab a random invidious instance where the 30dRatio is greater than 95
# Also, get rid of https in link because convert-links.sh adds it back in
jq -r '.[][1] | select(.monitor."30dRatio" > 95) | .uri' "$INVIDIOUS_JSON_PATH" | grep -v "vid\." | sed 's#https://##g' | shuf -n 1
