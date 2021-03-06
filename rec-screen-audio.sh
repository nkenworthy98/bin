#!/bin/sh
# Script to record both the screen and audio.
# It also asks the user (via dmenu) what the
# name of the recording should be.

RECORDING_NAME=$(printf "" | dmenu -p "Name of recording?")

# ffmpeg -f x11grab -video_size 1366x768 -framerate 30 -i $DISPLAY -f pulse -i default -c:v libtheora -qscale:v 10 -c:a libvorbis -qscale:a 5 "$RECORDING_NAME".ogv
ffmpeg -f x11grab -video_size 1366x768 -framerate 25 -i "$DISPLAY" -f pulse -i default -c:v libx264 -preset ultrafast -c:a aac "$RECORDING_NAME".mp4
