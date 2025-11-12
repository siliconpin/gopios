#!/bin/bash
plasma-apply-lookandfeel --apply org.kde.breezedark.desktop
rm ~/.config/autostart/set-dark-mode.desktop
#chattr -i /usr/bin/pacman
