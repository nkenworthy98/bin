#!/bin/bash
# Script to display mpc status information through dunst

status=$(mpc status)

notify-send "$status"
# echo -e "$status" | timeout 4s dmenu -l 3 -p "Current Song: " dunst

exit
