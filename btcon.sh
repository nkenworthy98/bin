#!/bin/sh
# Toggle bluetooth connection
#
# Configure the BT_MAC_ADDRESS variable with your bluetooth device's MAC address
# Assume connect unless --disconnect is passed in

toggle_btcon_on() {
    BT_DEVICE="$1"

    print_connection_message "connect"
    bluetoothctl connect "$BT_DEVICE" || print_error_message "connect"
}

toggle_btcon_off() {
    BT_DEVICE="$1"

    print_connection_message "disconnect"
    bluetoothctl disconnect "$BT_DEVICE" || print_error_message "disconnect"
}

print_connection_message() {
    CONNECT_OR_DISCONNECT="$1"

    # Append either "to" or "from" to the CONNECT_OR_DISCONNECT string depending
    # on whether or not device is connecting or disconnecting
    # This is so the notification message can say either "connect to" or
    # "disconnect from"
    if [ "$CONNECT_OR_DISCONNECT" = "connect" ]; then
        CONNECT_OR_DISCONNECT=$(printf "%s to" "$CONNECT_OR_DISCONNECT")
    else
        CONNECT_OR_DISCONNECT=$(printf "%s from" "$CONNECT_OR_DISCONNECT")
    fi

    notify-send "btcon.sh" "Attempting to $CONNECT_OR_DISCONNECT bluetooth device..."
}

print_error_message() {
    CONNECT_OR_DISCONNECT="$1"

    notify-send "btcon.sh" "Error when trying to $CONNECT_OR_DISCONNECT"
}

BT_MAC_ADDRESS=""

if [ "$1" = "--disconnect" ]; then
    toggle_btcon_off "$BT_MAC_ADDRESS"
else
    toggle_btcon_on "$BT_MAC_ADDRESS"
fi
