#!/bin/bash
set -e  # Exit on any error
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
rm ~/.config/autostart/setup-flathub-remote.desktop