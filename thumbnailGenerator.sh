#!/bin/sh
# Generate small jpg files to act as thumbnails
# for any mp4 files returned by the find command

find . -type f -name '*.mp4' -exec ffmpegthumbnailer -i {} -t 50% -o {}.jpg \;
