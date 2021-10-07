#!/bin/sh
# Toggle clipnotify in the background. Once event happens, run contents
# of clipboard through convert-links.pl

toggle_clipnotify_on() {
    notify-send "Clipnotify toggled on"

    while clipnotify; do
        convert-links.pl
    done
}

toggle_clipnotify_off() {
    notify-send "Clipnotify toggled off"
    killall clipnotify
    killall clipnotify.sh
}

PROCESS_NUM=$(pidof clipnotify | wc -l)

# Check if clipnotify is currently running
if [ "$PROCESS_NUM" -eq 1 ]; then
    toggle_clipnotify_off
else
    toggle_clipnotify_on
fi
