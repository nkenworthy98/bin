#!/usr/bin/env bash
# This script converts links in your clipboard to their free alternatives
# youtube to invidious
# twitter to nitter
# reddit to teddit
# instagram to bibliogram
set -euo pipefail

LINK=$(xclip -selection c -o)

# Remove www. from all urls in clipboard because it seems
# to cause issues when accessing the alternative sites if www. is
# still in the url
FILTERED_LINK=${LINK/www./}

INVIDIOUS_INSTANCE="invidious.kavin.rocks"
NITTER_INSTANCE="nitter.domain.glass"

# /u at the end is required in order to be brought
# to the correct page
BIBLIOGRAM_INSTANCE="insta.trom.tf/u"

case "$FILTERED_LINK" in
    *"youtube.com"*)
        echo "${FILTERED_LINK/youtube.com/$INVIDIOUS_INSTANCE}" | xclip -selection c
        notify-send -h string:frcolor:#FA0000 "Youtube link converted to invidious link"
        ;;
    *"twitter.com"*)
        echo "${FILTERED_LINK/twitter.com/$NITTER_INSTANCE}" | xclip -selection c
        notify-send -h string:frcolor:#FAFAFA "Twitter link converted to nitter link"
        ;;
    *"reddit.com"*)
        echo "${FILTERED_LINK/reddit.com/teddit.net}" | xclip -selection c
        notify-send -h string:frcolor:#FF4500 "Reddit link converted to teddit link"
        ;;
    *"instagram.com"*)
        echo "${FILTERED_LINK/instagram.com/$BIBLIOGRAM_INSTANCE}" | xclip -selection c
        notify-send -h string:frcolor:#833BB4 "Instagram link converted to bibliogram link"
        ;;
    *)
        notify-send "Link in clipboard was not converted"
esac
