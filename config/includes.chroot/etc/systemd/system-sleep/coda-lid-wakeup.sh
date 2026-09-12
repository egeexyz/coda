#!/bin/sh
# Prevent USB mouse/keyboard movement from waking the laptop when the lid is closed

case "$1/$2" in
    pre/*)
        if grep -qi "closed" /proc/acpi/button/lid/*/state 2>/dev/null; then
            for dev in /sys/bus/usb/devices/*/power/wakeup; do
                if [ -w "$dev" ]; then
                    echo disabled > "$dev" 2>/dev/null
                fi
            done
        fi
        ;;
    post/*)
        # Re-enable USB wakeup on resume once lid is opened
        for dev in /sys/bus/usb/devices/*/power/wakeup; do
            if [ -w "$dev" ]; then
                echo enabled > "$dev" 2>/dev/null
            fi
        done
        ;;
esac
