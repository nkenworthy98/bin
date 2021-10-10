#!/bin/sh
# Script to choose twitch stream through dmenu

CHOICES=$(reflex-curses -f)
CHANNEL_NAME=$(echo "$CHOICES" | dmenu -l 20 -i -p "Twitch Stream?") # displays channel name in dmenu

if [ "$CHANNEL_NAME" != "" ]
then
	streamlink https://www.twitch.tv/"$CHANNEL_NAME" 480p || \
		streamlink https://www.twitch.tv/"$CHANNEL_NAME" best || \
			notify-send "Error trying to play $CHANNEL_NAME through streamlink"
fi
