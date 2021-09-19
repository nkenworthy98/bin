#!/usr/bin/env bash
# Script to ask user a certain string to search for.
# Filenames/filepaths in the mpd music directory that contain that
# string will be output to the screen again through dmenu if
# there's more than 1 match. If there's more than 1 match, the
# user makes a selection from the list displayed and that song
# starts playing. If there was only 1 match, that song will
# start playing without asking the user to make a selection
set -euo pipefail

SEARCH_STRING=$(printf "" | dmenu -p "String to search for?" -l 20)
MATCHING_SONGS=$(mpc listall | grep -i "$SEARCH_STRING")

# Play song if there's only 1 match
# Else, ask user to choose which song to play
if [[ $(echo "$MATCHING_SONGS" | wc -l) -eq 1 ]]
then
    mpc searchplay filename "$MATCHING_SONGS"
else
    PLAY_SONG=$(echo "$MATCHING_SONGS" | dmenu -p "Song?" -l 20 -i)
    mpc searchplay filename "$PLAY_SONG"
fi
