#!/bin/sh
# This script allows users to interactively select the format
# of a video that can be played through mpv (using youtube-dl) by asking
# the user (through dmenu) which format they would like to watch
# the video in, and then plays that video using mpv.

# Sends the format code and resolution to dmenu
FORMAT_LIST=$(youtube-dl -F "$1" | ytdl-formats.pl | perl -lane 'print "$F[0] -- $F[2]"')
USER_CHOICE=$(echo "$FORMAT_LIST" | dmenu -l 10 -i -p "Pick format: (Format Code -- Resolution)")

# Gets the format code based on the users's choice
SELECTED_FORMAT=$(echo "$USER_CHOICE" | perl -lane 'print "$F[0]"')

# Plays video in the format the the user selected in mpv
mpv "$1" --ytdl-format="$SELECTED_FORMAT"
