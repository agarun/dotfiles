#!/usr/bin/env bash
rex() { defaults write com.superlogical.rex "$@"; }
rex Workspace.terminalFontPointSize -float 15
rex Workspace.cursorShadersEnabled -bool true
rex Workspace.cursorShader -string blaze
rex Workspace.tabStyle -string vertical
rex Workspace.sidebarPosition -string left
