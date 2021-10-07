#!/bin/sh
# Update Nitter Instances

MD_DEST="$HOME/bin/txt-files/nitter.md"

curl https://raw.githubusercontent.com/wiki/zedeus/nitter/Instances.md > "$MD_DEST"
