#!/usr/bin/env bash
# Statusline — renders through coralline (~/.claude/coralline/) using ~/.claude/coralline.conf.
# (The old DeepSeek/claude-sk branch + coralline-sk.conf were removed 2026-07-25 when
#  permafrost was decommissioned.)
set -euo pipefail

INPUT=$(cat)
printf '%s' "$INPUT" | CORALLINE_CONFIG="$HOME/.claude/coralline.conf" bash "$HOME/.claude/coralline/statusline.sh"
