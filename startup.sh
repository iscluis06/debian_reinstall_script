#!/bin/bash

compton &
flatpak run com.dropbox.Client &
systemctl --user start xfce4-notifyd
