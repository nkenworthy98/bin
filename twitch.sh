#!/bin/sh
# Script to choose twitch stream to watch through dmenu

CHANNEL_LIST=$(reflex-curses -f)
# Use dmenu to ask user to select a channel to watch
SELECTED_CHANNEL=$(echo "$CHANNEL_LIST" | dmenu -l 20 -i -p "Twitch Stream?")

play_stream() {
	CHANNEL=$1

	# Don't even attempt to run streamlink if a channel isn't selected
	if [ "$CHANNEL" != "" ]; then
		streamlink https://www.twitch.tv/"$CHANNEL" || print_error "$CHANNEL"
	fi
}

print_error() {
	CHANNEL=$1

	notify-send 'twitch.sh' "Error trying to play $CHANNEL through streamlink"
}

play_stream "$SELECTED_CHANNEL"
