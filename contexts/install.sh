#!/usr/bin/env zsh

# Install Contexts
echo "Installing Contexts..."

brew install --cask contexts

# Configure Contexts
echo "Configuring Contexts..."

# Welcome
defaults write com.contextsformac.Contexts "CTPreferenceLaunchAtLogin" -bool true

# Appearance
defaults write com.contextsformac.Contexts "CTAppearanceTheme" -string "CTAppearanceNamedAuto"
defaults write com.contextsformac.Contexts "CTPreferenceAppearanceContentSizeCategory" -int 3

# General
defaults write com.contextsformac.Contexts "CTPreferenceInputSourceIdToUse" -string "kCTInputSourceIdNone"
defaults write com.contextsformac.Contexts "CTPreferenceSidebarShowDockIconStatus" -int 1
defaults write com.contextsformac.Contexts "CTPreferenceWorkspaceEnableAlternativeSwitchingMethod" -int 1
defaults write com.contextsformac.Contexts "CTPreferenceWorkspacePressDockIconWhenActivatingApplication" -int 1

# Rules
defaults write com.contextsformac.Contexts "CTPreferenceWorkspaceGrouping" -string "CTWorkspaceGroupingOne"
defaults write com.contextsformac.Contexts "CTWorkspaceShowApplicationsWithNoWindows" -int 1

# Sidebar
defaults write com.contextsformac.Contexts "CTPreferenceSidebarDisplayMode" -string "CTDisplayModeNone"

# Panel
defaults write com.contextsformac.Contexts "CTPreferencePanelDisplayMode" -string "CTDisplayModeActiveScreen"
defaults write com.contextsformac.Contexts "CTPreferencePanelRecentItemsSwitcherKeyType" -string "CTItemKeyTypeNone"
defaults write com.contextsformac.Contexts "CTPreferencePanelWidth" -int 6
defaults write com.contextsformac.Contexts "CTPreferencePanelChangeSelectionOnScrollEnabled" -int 0
defaults write com.contextsformac.Contexts "CTPreferencePanelUpdatesSelectionOnMouseMove" -int 0

# Search
defaults write com.contextsformac.Contexts "CTKeyboardEventCommandModeActive" -int 0
defaults write com.contextsformac.Contexts "CTPreferenceSearchShortcutFunctionKeyEnabled" -int 0

# Gestures
defaults write com.contextsformac.Contexts "CTPreferenceInputDoubleTouchSwitchGestureActive" -int 0

echo "Contexts installation and configuration complete!"
echo "Restart Contexts to apply changes"
