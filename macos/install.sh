#!/usr/bin/env bash

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `./macos/install.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


###############################################################################
# General UI/UX
###############################################################################

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "America/Chicago" > /dev/null 2>&1

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
# Possible values: `WhenScrolling`, `Automatic` and `Always`

# Set liquid glass to tinted
defaults write NSGlobalDomain NSGlassDiffusionSetting -int 1

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Enable Reduce Motion to minimize the movement of user interface elements
defaults write com.apple.universalaccess reduceMotion -bool true


###############################################################################
# Trackpad
###############################################################################

# System Preferences > Trackpad > Point & Click > Tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# System Preferences > Trackpad > Point & Click >Look up & data detectors
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -bool false

# System Preferences > Trackpad > Point & Click > Secondary click
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

# System Preferences > Trackpad > Point & Click > Force Click and haptic feedback
defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -bool false
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool true

# Speed up Trackpad Tracking Speed
defaults write NSGlobalDomain com.apple.trackpad.scaling -int 2


###############################################################################
# Mouse
###############################################################################

# Speed up Mouse Tracking Speed
defaults write NSGlobalDomain com.apple.mouse.scaling -float 2

# Set a slightly faster Scrolling Speed
defaults write NSGlobalDomain com.apple.scrollwheel.scaling -float 0.5

# Unset Natural Scrolling for Mouse
defaults write NSGlobalDomain com.apple.swipescrolldirection -int 2


###############################################################################
# Keyboard
###############################################################################

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Disable "bonk" sound when using CTRL+CMD+DOWN in Electron apps
mkdir -p ~/Library/KeyBindings
sudo ln -s ~/.dotfiles/macos/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict


###############################################################################
# Screen
###############################################################################

# Save screenshots to a folder on the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop/Screenshots"

# Enable subpixel font rendering on non-Apple LCDs and fix blurry thin type.
# http://osxdaily.com/2018/09/26/fix-blurry-thin-fonts-text-macos-mojave/
# TODO: Still a problem in macOS Tahoe?
# defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO
# defaults -currentHost write -g AppleFontSmoothing -int 1


###############################################################################
# Sound
###############################################################################

# Disable the sound effects on boot
sudo nvram StartupMute=%01

# System Preferences > Sound > Alert volume
defaults write NSGlobalDomain com.apple.sound.beep.volume -int 0

# System Preferences > Sound > Play user interface sound effects
defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -int 0


###############################################################################
# Finder
###############################################################################

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
# defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Disable actions when double-clicking a window’s title
defaults write NSGlobalDomain AppleActionOnDoubleClick -string "None"

# Disable the click wallpaper to show the desktop feature
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Set grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 58" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 58" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 58" ~/Library/Preferences/com.apple.finder.plist

# Set the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist


###############################################################################
# Dock
###############################################################################

# Wipe all (default) app icons from the Dock
# This is only really useful when setting up a new Mac, or if you don’t use
# the Dock to launch apps.
#defaults write com.apple.dock persistent-apps -array

# Set the icon size of Dock items to 64 pixels
defaults write com.apple.dock tilesize -int 64

# Enable magnification of dock icons
defaults write com.apple.dock magnification -bool true

# Set magnification icon size of Dock items to 88 (64 + 24)
defaults write com.apple.dock largesize -int 88

# Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "genie"

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Disable all Hot Corners
defaults write com.apple.dock wvous-tl-corner -int 0 # Top left
defaults write com.apple.dock wvous-tr-corner -int 0 # Top right
defaults write com.apple.dock wvous-bl-corner -int 0 # Bottom left
defaults write com.apple.dock wvous-br-corner -int 0 # Bottom right


###############################################################################
# Kill affected applications
###############################################################################

for app in "cfprefsd" \
	"Dock" \
	"SystemUIServer" \
	"Terminal" \
	"TextEdit" \
	"Finder"; do
	killall "${app}" &> /dev/null
done
echo "Done. Note that some of these changes require a logout/restart to take effect."
