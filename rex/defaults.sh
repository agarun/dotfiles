#!/usr/bin/env bash
rex() { defaults write com.superlogical.rex "$@"; }

rex Workspace.interfaceStyle -string useTheme
rex Workspace.darkThemeID -string ink-meridian
rex Workspace.lightThemeID -string merino-light

rex Workspace.terminalFontPointSize -float 15
rex Workspace.terminalCursorStyle -string block
rex Workspace.terminalUseThemePalette -bool false
rex Workspace.cursorShadersEnabled -bool true
rex Workspace.cursorShader -string blaze

rex Workspace.showsActivePaneBorder -bool true
rex Workspace.inactivePaneFadeMode -string both
rex Workspace.usesStandardInactiveWindowPaneStyles -bool true

rex Workspace.tabStyle -string vertical
rex Workspace.tabIconCount -int 3
rex Workspace.tabIconTintMode -string off
rex Workspace.sidebarPosition -string left
