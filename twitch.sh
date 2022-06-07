#!/bin/sh
# Script to choose twitch stream to watch through dmenu

CHANNEL_TITLES_LIST=$(cat "$HOME/.config/tfstat/tfstat.txt")
# Use dmenu to ask user to select channel(s) to watch
SELECTED_CHANNELS=$(echo "$CHANNEL_TITLES_LIST" | dmenu -l 20 -i -p "Twitch Stream?" | cut -d' ' -f1)

play_stream() {
	CHANNEL=$1

	streamlink https://www.twitch.tv/"$CHANNEL" || print_error "$CHANNEL"
}

print_error() {
	CHANNEL=$1

	notify-send 'twitch.sh' "Error trying to play $CHANNEL through streamlink"
}

for CHANNEL in $SELECTED_CHANNELS; do
	play_stream "$CHANNEL" &
done

# This will prevent hccs.pl from running unless a selection is made in dmenu
if [ "$SELECTED_CHANNELS" != "" ]; then
	hccs.pl
fi
exit 0
