#!/bin/sh
# Clear clipboard contents

xclip -i /dev/null -selection primary
xclip -i /dev/null -selection secondary
xclip -i /dev/null -selection clipboard
