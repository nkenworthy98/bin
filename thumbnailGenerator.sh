#!/usr/bin/env bash
# Generate small jpg files to act as thumbnails
# for any mp4 files returned by the find command
set -euo pipefail

find . -type f -name '*.mp4' -exec ffmpegthumbnailer -i {} -t 50% -o {}.jpg \;
