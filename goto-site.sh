#!/bin/sh
# Quickly navigate to either nitter/teddit pages using dmenu

BROWSER="firefox"
NITTER_BASE_URL=$(grni.sh)
TEDDIT_BASE_URL="teddit.net"
SITE_CHOICE=$(printf "%s\n%s" "nitter" "teddit" | dmenu -i -l 2 -p "Site?")

if [ "$SITE_CHOICE" = "nitter" ]; then
    NITTER_USERNAME=$(printf "" | dmenu -p "Nitter Username?")

    # Format URL to look like https://nitter.net/username
    GOTO_URL=$(printf "https://%s/%s" "$NITTER_BASE_URL" "$NITTER_USERNAME")
    "$BROWSER" "$GOTO_URL"

# Using elif instead of else in case I want to add more sites in the
# future
elif [ "$SITE_CHOICE" = "teddit" ]; then
    TEDDIT_SUBREDDIT=$(printf "" | dmenu -p "Teddit Subreddit?")

    # Format URL to look like https://teddit.net/r/subreddit
    GOTO_URL=$(printf "https://%s/r/%s" "$TEDDIT_BASE_URL" "$TEDDIT_SUBREDDIT")
    "$BROWSER" "$GOTO_URL"
fi


