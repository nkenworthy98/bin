#!/usr/bin/env bash
set -euo pipefail

MUSIC_DIR=".Music/"
STUFF_TO_REMOVE="$HOME"/"$MUSIC_DIR"

# Clear current playlist before adding directories based on substring
mpc clear

SEARCH_STRING=$(printf "" | dmenu -p "String to add in MPD?" -l 20)

# Filter out directories with the given string
MATCHING_SONGS=$(find "$HOME"/"$MUSIC_DIR" -type d | grep -i "$SEARCH_STRING")

FILTERED_SONG_NAMES=($(echo ${MATCHING_SONGS//$STUFF_TO_REMOVE/}))

mpc add "${FILTERED_SONG_NAMES[@]}"
