#!/usr/bin/env bash
# Clear clipboard contents
set -euo pipefail

xclip -i /dev/null -selection primary
xclip -i /dev/null -selection secondary
xclip -i /dev/null -selection clipboard
