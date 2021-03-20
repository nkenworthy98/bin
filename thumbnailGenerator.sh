#!/usr/bin/env bash
set -euo pipefail

# find . -type f -name '*.jpg' -o -name '*.png' -exec echo '{}'.testout \;
find . -type f -name '*.mp4' -exec ffmpegthumbnailer -i {} -t 50% -o {}.jpg \;
