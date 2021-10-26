#!/bin/sh
# Script to quickly grab current EXP and EXP until next level in
# The Legend of Heroes: Trails of Cold Steel II . Once these EXP values
# are captured, they are added together and then subtracted by 1, so I
# could plug that value into a memory editor (gameconqueror) to raise my characters levels
# quickly. In the game, if you try to raise your EXP value too high,
# your EXP seems to go down. The best thing to do seems to be to change your
# current EXP value to 1 below the EXP needed in order to level up.

# The image is scaled up, turned to black and white, and then the colors are inverted because black on white background seems
# to work better than white on black background
TEXT_OUTPUT=$(maim -g 150x61+2230+466 | convert +dither -colors 3 -colors 2 -colorspace gray -normalize -scale 300% -channel RGB -negate - - | tesseract --dpi 300 - - | perl -pe 's/\n/ /g' | awk '{print $1+$2-1}')

# Output value to screen as a notification and send to clipboard
notify-send "$TEXT_OUTPUT"
printf "%s" "$TEXT_OUTPUT" | xclip -selection c
