#!/bin/sh
# Script to display mpc status information as a notification

notify-send 'mpcStatus.sh' "$(mpc status)"
