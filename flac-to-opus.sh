#!/usr/bin/env bash
set -euo pipefail
# This script copies a specified directory,
# converts all flac files to opus, and then removes
# the copied flac files

# This removes trailing "/", which
# can cause some issues with the copy command below
ORIG_PATH=${1%/}
OPUS_PATH="$ORIG_PATH [OPUS]"

cp -r "$ORIG_PATH" "$OPUS_PATH"

# Convert all "*.flac" files to opus
find "$OPUS_PATH" -name "*.flac" -type f -exec opusenc '{}' '{}'.opus \;
find "$OPUS_PATH" -name "*.flac" -type f -exec rm '{}' \;

# Removes the ".flac" substring from all the "*.flac.opus" files
find "$OPUS_PATH" -name "*.flac.opus" -type f -exec rename '.flac' '' '{}' \;

# Update any ".cue" files to have "opus" instead of "flac"
# Only necessary if the flac files are accompanied with
# cue files specifying different tracks in a CD
find "$OPUS_PATH" -name "*.cue" -exec sed -i 's/.flac/.opus/g' {} \;
