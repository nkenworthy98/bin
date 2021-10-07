#!/bin/sh
# Start playing all my music in a random order

# Clear queue
mpc clear

# Because I'm using git-annex to handle my music,
# I need to avoid adding all filepaths containing
# ".git" in them, so I don't have any duplicate songs
# in the queue.
mpc listall | grep -v "\.git" | ashuffle -q 100 -f -
