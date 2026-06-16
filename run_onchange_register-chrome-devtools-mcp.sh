#!/bin/sh
# chezmoi-managed: register the user-scoped chrome-devtools MCP server if missing.
# Pairs with the chrome-debug fish function, which launches Chrome with remote
# debugging on :9222. ~/.claude.json itself is NOT synced (it holds account/state).
command -v claude >/dev/null 2>&1 || exit 0
claude mcp get chrome-devtools >/dev/null 2>&1 && exit 0
claude mcp add-json chrome-devtools \
  '{"type":"stdio","command":"npx","args":["-y","chrome-devtools-mcp@latest","--browser-url=http://127.0.0.1:9222"],"env":{}}' \
  -s user
