#!/bin/bash
INVIDIOUS_SITE=localhost:3000

ORIGINAL_LINK=$1

if [ "$ORIGINAL_LINK" == "" ]; then
	exit
fi

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

# notify-send "$1 is now opening in $chosenProgram"
case $chosenProgram in 
	mpv)
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
