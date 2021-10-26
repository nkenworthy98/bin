#!/bin/sh
# Toggle clipnotify in the background. Once event happens, run contents
# of clipboard through convert-links.pl

toggle_clipnotify_on() {
    notify-send "ToCS2 clip toggled on"
    rm /tmp/tocs2-exp.txt
    xcc.sh # Script to clear clipboard contents

    while clipnotify; do
        printf "%s\n" "$(xclip -selection clipboard -o)" >> /tmp/tocs2-exp.txt
        # xcc.sh
    done
}

toggle_clipnotify_off() {
    notify-send "ToCS2 clip toggled off"
    killall clipnotify
    killall clipnotify.sh
    killall tocs2-exp-clip.sh
}

PROCESS_NUM=$(pidof clipnotify | wc -l)

# Check if clipnotify is currently running
if [ "$PROCESS_NUM" -eq 1 ]; then
    toggle_clipnotify_off
else
    toggle_clipnotify_on
fi
