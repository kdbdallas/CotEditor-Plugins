#!/usr/bin/env python3
#%%%{CotEditorXInput=AllText}%%%
#%%%{CotEditorXOutput=ReplaceAllText}%%%
"""Format the entire CotEditor document as readable JSON."""

import json
import sys


def reject_nonstandard_constant(value):
    raise ValueError(f"{value} is not valid JSON")


def main():
    source = sys.stdin.read()

    try:
        value = json.loads(source, parse_constant=reject_nonstandard_constant)
    except (json.JSONDecodeError, ValueError) as error:
        print(f"Format JSON: {error}", file=sys.stderr)
        return 1

    sys.stdout.write(json.dumps(value, ensure_ascii=False, indent=2, allow_nan=False))
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
