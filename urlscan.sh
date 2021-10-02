#!/bin/bash
# Handle links depending on what their url contains or
# what the file extension is.

ORIGINAL_LINK="$1"
INVIDIOUS_SITE=$(grii.sh)

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
	*"twitch.tv"* | \
	*"odysee.com"* | \
	*"videos.lukesmith.xyz"* | \
	*"bitchute.com"*)
		chosenProgram=mpv
		;;
	*)
		;;
esac

echo -n "$ORIGINAL_LINK" | xclip -selection c
notify-send "Link has been copied to clipboard."

case $chosenProgram in
	mpv)
		mpv "$ORIGINAL_LINK" ||
			iformat-mpv.sh "$ORIGINAL_LINK" ||
				notify-send "Error when opening link"
		;;
	mpv-invidious)
		mpv "${ORIGINAL_LINK/https:\/\/www.youtube.com/https:\/\/$INVIDIOUS_SITE}" ||
			iformat-mpv.sh "$ORIGINAL_LINK" ||
				notify-send "Error when opening link"
		;;
	sxiv)
		curl -o /tmp/sxivtmpfile "$ORIGINAL_LINK" && sxiv -a /tmp/sxivtmpfile
		;;
	*)
		# Convert links to free alternatives
		convert-links.sh

		# Uses my script xcc.sh to clear clipboard
		sleep 25;
		xcc.sh
		;;
esac
