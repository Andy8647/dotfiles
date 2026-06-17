#!/usr/bin/env bash
# Hybrid statusline:
#   - DeepSeek sessions (claude-sk) -> permafrost cache stats
#   - everything else (native claude) -> claude-hud
# Branch on the session model, NOT on proxy reachability (the proxy stays up in
# the background, so reachability can't tell the two session types apart).
set -euo pipefail

INPUT=$(cat)

# Native claude / non-deepseek -> claude-hud
if ! printf '%s' "$INPUT" | grep -qi deepseek; then
    # Resolve node regardless of how it was installed (PATH first, then common
    # locations — brew, nodejs.org installer, nvm, volta, system). The statusline
    # may run with a minimal PATH, hence the absolute-path fallbacks.
    node_bin=$(command -v node 2>/dev/null || true)
    if [[ -z "$node_bin" ]]; then
        for c in /opt/homebrew/bin/node /usr/local/bin/node "$HOME/.volta/bin/node" "$HOME"/.nvm/versions/node/*/bin/node /usr/bin/node; do
            [[ -x "$c" ]] && { node_bin="$c"; break; }
        done
    fi
    plugin_dir=$(ls -d "$HOME"/.claude/plugins/cache/claude-hud/claude-hud/*/ 2>/dev/null | awk -F/ '{ print $(NF-1) "\t" $0 }' | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n | tail -1 | cut -f2-)
    if [[ -n "$node_bin" && -n "$plugin_dir" ]]; then
        exec "$node_bin" "${plugin_dir}dist/index.js" <<<"$INPUT"
    fi
    # node or plugin not found -> render nothing rather than erroring
    exit 0
fi

# DeepSeek session -> permafrost stats
STATS=$(curl -fsS "http://127.0.0.1:8787/permafrost/stats" 2>/dev/null || true)
if [[ -z "$STATS" ]]; then
    echo "❄ permafrost: starting…"
    exit 0
fi

# DeepSeek account balance, cached 60s (statusline refreshes too often to hit the API every time)
BAL_CACHE="${TMPDIR:-/tmp}/deepseek_balance.json"
BALANCE=""
if [[ -n "${ANTHROPIC_AUTH_TOKEN:-}" ]]; then
    if [[ -f "$BAL_CACHE" ]] && [[ $(( $(date +%s) - $(stat -f %m "$BAL_CACHE" 2>/dev/null || echo 0) )) -lt 60 ]]; then
        BALANCE=$(cat "$BAL_CACHE")
    else
        BALANCE=$(curl -fsS --max-time 2 "https://api.deepseek.com/user/balance" \
            -H "Authorization: Bearer ${ANTHROPIC_AUTH_TOKEN}" 2>/dev/null || true)
        [[ -n "$BALANCE" ]] && printf '%s' "$BALANCE" > "$BAL_CACHE"
    fi
fi

# USD->CNY rate for display (adjust as needed)
USD_CNY="${PERMAFROST_USD_CNY:-7.2}"

STATS="$STATS" SESSION="$INPUT" RATE="$USD_CNY" BALANCE="$BALANCE" python3 <<'PY'
import json, os
try:
    s = json.loads(os.environ["STATS"])
except Exception:
    print("❄ permafrost: parse err"); raise SystemExit
try:
    sess = json.loads(os.environ["SESSION"])
except Exception:
    sess = {}
rate = float(os.environ.get("RATE", "7.2"))

hit = s.get("hit_rate", 0) * 100
saved = s.get("saved_usd", 0) * rate
saved_pct = s.get("saved_pct", 0)
cost = s.get("cost_usd", 0) * rate
churn = "  ⚠ churn" if s.get("prefix_changes", 0) else ""
model = (sess.get("model") or {}).get("display_name") or (sess.get("model") or {}).get("id") or "deepseek"

# account balance (CNY)
bal_str = ""
try:
    bal = json.loads(os.environ.get("BALANCE", "") or "{}")
    for info in bal.get("balance_infos", []):
        if info.get("currency") == "CNY":
            bal_str = f" · 余额 ¥{float(info['total_balance']):.2f}"
            break
except Exception:
    pass

print(f"❄ {hit:.0f}% hit · ¥{cost:.3f} spent · ¥{saved:.2f} saved ({saved_pct:.0f}%){churn}{bal_str} | {model}")
PY
