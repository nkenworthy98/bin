#!/bin/sh
# Script to take screenshots. It asks the user
# (via dmenu) where the screenshot should be stored,
# what the name of the screenshot should be, and
# whether or not it should be fullscreen or a selection.

# Dependencies for this script:
#   find, dmenu, echo, maim/scrot, mv, dunst (for notify-send)

# List all directories inside screenshots for senior year.
# Pipe those into dmenu and have user choose which location they would like the screenshot saved.
SAVE_LOCATION=$(find "$HOME/Pictures/Screenshots/" -type d | dmenu -i -l 5 -p "Screenshot Location?")

# Ask user what name they would like for the screenshot.
# Needed printf in order to allow user to type their own name in dmenu. Not sure if there's a more efficient workaround.
NAME_OF_SCREENSHOT=$(printf "" | dmenu -p "Name of Screenshot?")

GET_CHOICE=$(printf "full\nselection" | dmenu -p "Screenshot Type")

# Take a screenshot 1 second after person enters name.
if [ "$GET_CHOICE" = "full" ]
then 
	maim -d 1 > "$SAVE_LOCATION"/"$NAME_OF_SCREENSHOT" 
	# scrot -d 1 "$NAME_OF_SCREENSHOT"
else 
	maim -s > "$SAVE_LOCATION"/"$NAME_OF_SCREENSHOT" 
	# If you want to manually select the region of the screenshot:
	# scrot -s "$NAME_OF_SCREENSHOT"
fi

# Needed if you use scrot instead of maim
# Be default, the file gets stored in the directory that the script is in (~/bin/ in my case),
#   so it needs to be moved to the right location once the screenshot is saved.
# mv "$NAME_OF_SCREENSHOT" "$SAVE_LOCATION"

# Notification is sent to the desktop telling user where the screenshot has been saved.
notify-send "Screenshot has been saved to '$SAVE_LOCATION'"
