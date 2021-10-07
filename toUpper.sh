#!/bin/sh
# Takes clipboard, makes every letter uppercase,
# and saves that to the clipboard

xclip -selection c -o | tr '[:lower:]' '[:upper:]' | xclip -selection c
notify-send "Contents of clipboard changed to all uppercase"
