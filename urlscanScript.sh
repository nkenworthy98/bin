#!/bin/bash
# Script that takes the buffer from tmux, runs urlscan, and plays/views the file in mpv or sxiv

# chosenProgram=$(echo -e "mpv\\nsxiv" | dmenu -i -p "What program should the link be opened with")
#

# Might include functionality to randomly choose from a few sites
# Might do this by using an array and randomly selecting one of the elements
# INVIDIOUS_SITE=invidious.kavin.rocks
INVIDIOUS_SITE=localhost:3000

ORIGINAL_LINK=$1

# if [[ ( "$1" =~ \.png$ ) || ( "$1" =~ \.jpg$ ) || ( "$1" =~ \.gif$ ) ]]; then
# 	chosenProgram=sxiv
# else
# 	chosenProgram=mpv
# fi

# if [[ ( "$1" =~ \.png$ ) || ( "$1" =~ \.jpg$ ) || ( "$1" =~ \.gif$ ) ]]; then

case $ORIGINAL_LINK in
	*".png" | \
	*".jpg" | \
	*".gif")
		chosenProgram=sxiv
		;;
	*"youtube.com"*)
		chosenProgram=mpv-invidious
		;;
	*"clips.twitch.tv"* | \
	*"streamable.com"* | \
	*"odysee.com"* | \
	*"videos.lukesmith.xyz"* | \
	*"bitchute.com"*)
		chosenProgram=mpv
		;;
	*)
		;;
esac

# Check to see if link is from YouTube.
# If it is,
# if [[ $1 == *"youtube.com"* ]]; then
# 	ORIGINAL_LINK=${ORIGINAL_LINK/www.youtube.com/$INVIDIOUS_SITE}
# fi


# notify-send "$1 is now opening in $chosenProgram"
case $chosenProgram in 
	mpv)
		#Dmenu prompt asks what kind of format the link should be opened in
		# theFormat=$(echo -e "worst\naudio\nbest" | dmenu -p "Which quality?")
		# if [ $theFormat != "audio" ]; then
		# 	# mpv "$1" # --ytdl-format="$theFormat"
		# 	torsocks mpv $ORIGINAL_LINK # --ytdl-format="$theFormat"
		# else
		# 	# mpv "$1" --ytdl-format=worst --vid=no
		# 	torsocks mpv $ORIGINAL_LINK --ytdl-format=worst --vid=no
		# fi
		# mpv "$ORIGINAL_LINK" # --ytdl-format=worst
		mpv "$ORIGINAL_LINK" || notify-send "Error when opening link"
		;;
	mpv-invidious)
		mpv "${ORIGINAL_LINK/https:\/\/www.youtube.com/http:\/\/$INVIDIOUS_SITE}" || notify-send "Error when opening link"
		;;
	mpv-bitchute)
		mpv "$ORIGINAL_LINK" || notify-send "Error when opening link"
		;;
	sxiv)
		curl -o /tmp/sxivtmpfile "$ORIGINAL_LINK" && sxiv -a /tmp/sxivtmpfile
		;;
	*)
		echo -n "$ORIGINAL_LINK" | xclip -selection c
		notify-send "Link has been copied to clipboard. Clipboard will be cleared in 25 seconds."

		# Convert links to free alternatives
		convert-links.sh

		sleep 25;
		xclip -i /dev/null -selection c
		;;
esac
# urlscan --run 'urlscanScript.sh {}' /tmp/tmux-buffer

