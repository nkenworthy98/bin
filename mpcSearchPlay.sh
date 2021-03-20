#!/usr/bin/env bash
set -euo pipefail

SEARCH_STRING=$(printf "" | dmenu -p "String to search for?" -l 20)
MATCHING_SONGS=$(mpc listall | grep -i "$SEARCH_STRING")


# Checks to see if search string only returns 1 value
if [[ $(echo "$MATCHING_SONGS" | wc -l) -eq 1 ]]
then
    mpc searchplay filename "$MATCHING_SONGS"
else
    PLAY_SONG=$(echo "$MATCHING_SONGS" | dmenu -p "Song?" -l 20 -i)
    mpc searchplay filename "$PLAY_SONG"
fi
