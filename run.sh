#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d .venv ]]; then
    if ! command -v python3 >/dev/null 2>&1; then
        printf '%s\n' 'python3 is required to create .venv.' >&2
        exit 1
    fi
    python3 -m venv .venv
fi

if [[ ! -x .venv/bin/python ]]; then
    printf '%s\n' '.venv/bin/python is missing or not executable.' >&2
    exit 1
fi

.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python src/hello.py