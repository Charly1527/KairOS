#!/bin/bash

USER_HOME=$(getent passwd kairos | cut -d: -f6)
USER_ID=$(id -u kairos)

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"

sudo -u kairos dbus-launch gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/kairos/olimpo-dark.png"
