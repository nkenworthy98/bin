#!/bin/bash
# Script to choose twitch stream through dmenu

#choices=$(cat ~/bin/currentlyLive.txt)
#choices=$(twitchy --non-interactive go | sed 's/<>?/ --- /g')

#choices=$(twitchy --non-interactive go | sed 's/<>?/ --- /g' | tr -cd '\11\12\15\40-\176')
choices=$(reflex-curses -f)
chosen=$(echo -e "$choices" | dmenu -l 20 -i -p "Twitch Stream?") # displays channel name, current game, title, and viewers in dmenu
channelName=$(echo "$chosen" | awk '{print $1}') # grabs the channel name from the selected option in dmenu

if [ "$channelName" != "" ]
then
	# mpv https://www.twitch.tv/"$channelName" --ytdl-format=360p
	streamlink https://www.twitch.tv/"$channelName" 480p || \
		streamlink https://www.twitch.tv/"$channelName" best || \
			notify-send "Error trying to play $channelName through streamlink"
fi
