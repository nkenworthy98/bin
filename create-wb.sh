#!/bin/sh
# Create a new wine bottle. Also, if you run this as suggested below, it
# will set your current WINEPREFIX to whatever you pass into create-wb.sh
#
# Usage:
#
#   export WINEPREFIX=$(create-wb.sh "wine-bottle-name")

WINE_PREFIX_ROOT="$HOME/.local/share/wineprefixes/"
NEW_WINE_BOTTLE="$1"

if [ "$NEW_WINE_BOTTLE" = "" ]; then
    # Send output message to stderr, so it doesn't get assigned to WINEPREFIX
    # environment variable if an argument isn't passed in
    echo "ERROR: Wine bottle name must be passed in" 1>&2
    exit 1
fi

# Format the WINEPREFIX string
NEW_WINEPREFIX=$(printf "%s%s" "$WINE_PREFIX_ROOT" "$NEW_WINE_BOTTLE")

# Create the directory for the wine bottle if it hasn't been created already
mkdir -p "$NEW_WINEPREFIX"

echo "$NEW_WINEPREFIX"
