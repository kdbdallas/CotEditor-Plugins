#!/bin/zsh
#%%%{CotEditorXInput=AllText}%%%
#%%%{CotEditorXOutput=ReplaceAllText}%%%

set -o pipefail

# CotEditor may launch scripts without Homebrew's usual PATH entries.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

DOCUMENT_PATH="${1:-$PWD/untitled.js}"
if [[ "$DOCUMENT_PATH" != /* ]]; then
    DOCUMENT_PATH="$PWD/$DOCUMENT_PATH"
fi

# Prettier needs a filename to select the parser and locate project settings.
FORMAT_PATH="$DOCUMENT_PATH"
if [[ "${DOCUMENT_PATH##*/}" != *.* ]]; then
    FORMAT_PATH="${DOCUMENT_PATH}.js"
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

# Also check npm's global bin directory in case CotEditor did not inherit it.
if [[ -z "$PRETTIER" ]] && command -v npm >/dev/null 2>&1; then
    NPM_GLOBAL_PREFIX="$(npm prefix -g 2>/dev/null || true)"
    if [[ -n "$NPM_GLOBAL_PREFIX" && -x "$NPM_GLOBAL_PREFIX/bin/prettier" ]]; then
        PRETTIER="$NPM_GLOBAL_PREFIX/bin/prettier"
    fi
fi

if [[ -z "$PRETTIER" ]]; then
    print -u2 -- "Format JavaScript: Prettier was not found. Install it in the project first."
    /usr/bin/osascript >/dev/null 2>&1 <<'APPLESCRIPT'
display alert "Prettier was not found" message "Install Prettier from your JavaScript project's folder with:" & return & return & "npm install --save-dev --save-exact prettier" & return & return & "Save the document, then run this CotEditor script again." as critical
APPLESCRIPT
    exit 1
fi

exec "$PRETTIER" --stdin-filepath "$FORMAT_PATH"
