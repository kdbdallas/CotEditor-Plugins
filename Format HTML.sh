#!/bin/zsh
#%%%{CotEditorXInput=AllText}%%%
#%%%{CotEditorXOutput=ReplaceAllText}%%%

set -o pipefail

# CotEditor may launch scripts without Homebrew's usual PATH entries.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

DOCUMENT_PATH="${1:-$PWD/untitled.html}"
if [[ "$DOCUMENT_PATH" != /* ]]; then
    DOCUMENT_PATH="$PWD/$DOCUMENT_PATH"
fi

# Prettier needs a filename to locate project settings and infer file context.
FORMAT_PATH="$DOCUMENT_PATH"
if [[ "${DOCUMENT_PATH##*/}" != *.* ]]; then
    FORMAT_PATH="${DOCUMENT_PATH}.html"
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

if [[ -z "$PRETTIER" ]]; then
    print -u2 -- "Format HTML: Prettier was not found. Install it in this project or make the prettier command available on PATH."
    exit 127
fi

exec "$PRETTIER" --parser html --stdin-filepath "$FORMAT_PATH"
