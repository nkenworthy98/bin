#!/bin/sh

BRIGHTNESS=$(cat /tmp/brightness)
light -S "$BRIGHTNESS"
