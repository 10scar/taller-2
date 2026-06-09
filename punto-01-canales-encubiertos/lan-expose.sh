#!/usr/bin/env bash
# Wrapper — usa el script compartido del taller.
exec "$(cd "$(dirname "$0")/../.." && pwd)/lib/lan-expose.sh" "$@"
