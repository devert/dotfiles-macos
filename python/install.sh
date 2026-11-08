#!/usr/bin/env zsh

# Install Python deps
brew install uv

# Install default system-wide Python with uv
uv python install
uv python install --default
