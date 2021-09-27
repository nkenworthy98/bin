#!/usr/bin/env bash
set -euo pipefail

# This is the text file containing all the directories that should be synced
FILES_TO_SYNC="$1"

# Complete change from previous rsync script
# Sync to artix-desktop
ssh -o ConnectTimeout=3 nickartix@artix-desktop exit && \
    rsync -arvzP --files-from="$FILES_TO_SYNC" ~/ nickartix@artix-desktop:~/

# Sync to manjaro-ideapad
ssh -o ConnectTimeout=3 nick@manjaro-ideapad exit && \
    rsync -arvzP --files-from="$FILES_TO_SYNC" ~/ nick@manjaro-ideapad:~/

# Checks to see if encrypted drive is connected and mounted
ssh -o ConnectTimeout=3 nick-pi@nickpi '[ -d ~/mountDir/nick-storage/ ]' && \
    rsync -arvzP --files-from="$FILES_TO_SYNC" ~/ nick-pi@nickpi:~/mountDir/nick-storage/
