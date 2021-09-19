#!/usr/bin/env bash
# Script to change wallpaper. This script
# takes in the first argument of cw.sh
# and copies it to ~/.config/wallpaper.jpg, which
# is what I'm using to be the default wallpaper.
# My xinitrc takes this file and sets it using xwallpaper.
set -euo pipefail

cp "$1" ~/.config/wallpaper.jpg
