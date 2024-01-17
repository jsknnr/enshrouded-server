#!/bin/bash
export DISPLAY=:1.0

Xvfb :1 -screen 0 1024x768x16 &
env wineboot --init /nogui
winetricks corefonts
winetricks sound=disabled
winetricks -q --force vcrun2022
wine winecfg -v win10
rm -rf /home/steam/.cache
