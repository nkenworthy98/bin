#!/bin/sh

# 4 Attack Members plus 2 Support Members
CHARS_IN_TACTICS_MENU=6

COUNT=0
while [ "$COUNT" -lt "$CHARS_IN_TACTICS_MENU" ]; do
    tocs2-exp.sh

    # Type the letter 'd' to simulate moving right in the menu
    xdotool type --clearmodifiers --delay 100 d
    COUNT=$((COUNT + 1))
done
