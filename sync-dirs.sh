#!/usr/bin/env bash
set -euo pipefail

# Complete change from previous rsync script
# Sync to artix-desktop
ssh -o ConnectTimeout=3 nickartix@artix-desktop exit && \
    rsync -arvzP --files-from=bin/files-to-sync.txt ~/ nickartix@artix-desktop:~/

# Sync to manjaro-ideapad
ssh -o ConnectTimeout=3 nick@manjaro-ideapad exit && \
    rsync -arvzP --files-from=bin/files-to-sync.txt ~/ nick@manjaro-ideapad:~/

# Checks to see if encrypted drive is connected and mounted
ssh -o ConnectTimeout=3 nick-pi@nickpi '[ -d ~/mountDir/nick-storage/ ]' && \
    rsync -arvzP --files-from=bin/files-to-sync.txt ~/ nick-pi@nickpi:~/mountDir/nick-storage/
