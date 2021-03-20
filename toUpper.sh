#!/usr/bin/env bash

# Takes clipboard, makes every letter uppercase,
# and saves that to the clipboard
xclip -selection c -o | tr a-z A-Z | xclip -selection c
notify-send "Contents of clipboard changed to all uppercase"
