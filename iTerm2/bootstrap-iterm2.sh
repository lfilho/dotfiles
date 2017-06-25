#!/usr/bin/env bash

# Make iTerm understand italics
tic ~/.yadr/iTerm2/xterm-256color.terminfo

# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/.yadr/iTerm2"
# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# Add shortcut to Dock
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/iTerm.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# reset the preferences cache
killall cfprefsd
