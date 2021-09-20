#!/usr/bin/env bash
# Start playing all my music in a random order
set -euo pipefail

# Clear queue
mpc clear

# Because I'm using git-annex to handle my music,
# I need to avoid adding all filepaths containing
# ".git" in them, so I don't have any duplicate songs
# in the queue.
NUMBER_OF_SONGS=$(mpc listall | grep -v "\.git" | wc -l)
mpc listall | grep -v "\.git" | ashuffle -q "$NUMBER_OF_SONGS" -f -
