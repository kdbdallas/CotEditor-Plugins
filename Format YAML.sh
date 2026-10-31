#!/bin/zsh
#%%%{CotEditorXInput=AllText}%%%
#%%%{CotEditorXOutput=ReplaceAllText}%%%

set -o pipefail

# CotEditor may launch scripts without Homebrew's usual PATH entries.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# GUI apps may not inherit PATH entries initialized by the user's zsh profile
# (for example, Node installed through nvm, fnm, or Volta).
LOGIN_PATH="$(/bin/zsh -lic 'print -r -- $PATH' 2>/dev/null | /usr/bin/tail -n 1)"
if [[ -n "$LOGIN_PATH" ]]; then
    export PATH="$LOGIN_PATH:$PATH"
fi

DOCUMENT_PATH="${1:-$PWD/untitled.yaml}"
if [[ "$DOCUMENT_PATH" != /* ]]; then
    DOCUMENT_PATH="$PWD/$DOCUMENT_PATH"
fi

# Prettier uses this path to find project settings; YAML parsing is explicit.
FORMAT_PATH="$DOCUMENT_PATH"
if [[ "${DOCUMENT_PATH##*/}" != *.* ]]; then
    FORMAT_PATH="${DOCUMENT_PATH}.yaml"
fi

PRETTIER=""
SEARCH_DIR="$(dirname "$DOCUMENT_PATH")"
while [[ -n "$SEARCH_DIR" ]]; do
    if [[ -x "$SEARCH_DIR/node_modules/.bin/prettier" ]]; then
        PRETTIER="$SEARCH_DIR/node_modules/.bin/prettier"
        break
    fi
    [[ "$SEARCH_DIR" == "/" ]] && break
    SEARCH_DIR="$(dirname "$SEARCH_DIR")"
done

if [[ -z "$PRETTIER" ]]; then
    PRETTIER="$(command -v prettier 2>/dev/null || true)"
fi

# Also check npm's global bin directory when CotEditor did not inherit it.
if [[ -z "$PRETTIER" ]] && command -v npm >/dev/null 2>&1; then
    NPM_GLOBAL_PREFIX="$(npm prefix -g 2>/dev/null || true)"
    if [[ -n "$NPM_GLOBAL_PREFIX" && -x "$NPM_GLOBAL_PREFIX/bin/prettier" ]]; then
        PRETTIER="$NPM_GLOBAL_PREFIX/bin/prettier"
    fi
fi

if [[ -z "$PRETTIER" ]]; then
    print -u2 -- "Format YAML: Prettier was not found. Install it globally or in this project."
    /usr/bin/osascript >/dev/null 2>&1 <<'APPLESCRIPT'
display alert "Prettier was not found" message "In Terminal, install Prettier once with:" & return & return & "npm install --global prettier" & return & return & "Then run this CotEditor script again." as critical
APPLESCRIPT
    exit 1
fi

exec "$PRETTIER" --parser yaml --stdin-filepath "$FORMAT_PATH"
