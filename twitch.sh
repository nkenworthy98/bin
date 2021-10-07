#!/bin/sh
# Script to choose twitch stream through dmenu

CHOICES=$(reflex-curses -f)
CHOSEN=$(echo "$CHOICES" | dmenu -l 20 -i -p "Twitch Stream?") # displays channel name, current game, title, and viewers in dmenu
CHANNEL_NAME=$(echo "$CHOSEN" | awk '{print $1}') # grabs the channel name from the selected option in dmenu

if [ "$CHANNEL_NAME" != "" ]
then
	streamlink https://www.twitch.tv/"$CHANNEL_NAME" 480p || \
		streamlink https://www.twitch.tv/"$CHANNEL_NAME" best || \
			notify-send "Error trying to play $CHANNEL_NAME through streamlink"
fi
