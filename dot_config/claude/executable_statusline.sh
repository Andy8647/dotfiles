#!/usr/bin/env bash
# Hybrid statusline — everything renders through coralline (~/.claude/coralline/):
#   - DeepSeek sessions (claude-sk) -> coralline-sk.conf  (permafrost cache pills)
#   - everything else (native claude) -> coralline.conf
# Branch on the session model, NOT on proxy reachability (the permafrost proxy
# stays up in the background, so reachability can't tell the two session types
# apart). The proxy itself is unaffected by this file — this only picks which
# coralline config renders the readout.
set -euo pipefail

INPUT=$(cat)

if printf '%s' "$INPUT" | grep -qi deepseek; then
    CONF="$HOME/.claude/coralline-sk.conf"
else
    CONF="$HOME/.claude/coralline.conf"
fi

printf '%s' "$INPUT" | CORALLINE_CONFIG="$CONF" bash "$HOME/.claude/coralline/statusline.sh"
