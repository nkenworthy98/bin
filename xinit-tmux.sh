#!/bin/sh

# Purpose of this script is to check if tmux has a running server
# already. If it does, connect to that server. Else, start up
# an instance of tmux.
# For my purposes, I'll be using it with the 'st' command
# in my xinitrc because st seems to have problems running
# the statement if it's checking for error codes.

tmux a -t 0 || tmux
