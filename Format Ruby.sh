#!/bin/zsh
#%%%{CotEditorXInput=AllText}%%%
#%%%{CotEditorXOutput=ReplaceAllText}%%%

set -o pipefail

# CotEditor may launch scripts without the user's Ruby manager or Homebrew paths.
export PATH="$HOME/.rbenv/shims:$HOME/.asdf/shims:$HOME/.local/share/mise/shims:$HOME/.rvm/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

DOCUMENT_PATH="${1:-$PWD/untitled.rb}"
if [[ "$DOCUMENT_PATH" != /* ]]; then
    DOCUMENT_PATH="$PWD/$DOCUMENT_PATH"
fi
DOCUMENT_DIR="$(dirname "$DOCUMENT_PATH")"

RUFO="$(command -v rufo 2>/dev/null || true)"

# Look in RubyGems' active gem homes when the executable directory is not on PATH.
if [[ -z "$RUFO" ]] && command -v gem >/dev/null 2>&1; then
    for GEM_HOME_PATH in "$(gem env home 2>/dev/null)" "$(gem env user_gemhome 2>/dev/null)"; do
        if [[ -n "$GEM_HOME_PATH" && -x "$GEM_HOME_PATH/bin/rufo" ]]; then
            RUFO="$GEM_HOME_PATH/bin/rufo"
            break
        fi
    done
fi

if [[ -z "$RUFO" ]]; then
    print -u2 -- "Format Ruby: Rufo was not found. Install it with Ruby 3 or later."
    /usr/bin/osascript >/dev/null 2>&1 <<'APPLESCRIPT'
display alert "Rufo was not found" message "Install Ruby 3 or later, then install Rufo with:" & return & return & "gem install rufo" & return & return & "Run this CotEditor script again after installation." as critical
APPLESCRIPT
    exit 1
fi

# Rufo reads formatted source from STDIN and looks for .rufo settings from the
# current directory, so run it from the saved document's folder.
cd "$DOCUMENT_DIR" || exit 1
exec "$RUFO"
