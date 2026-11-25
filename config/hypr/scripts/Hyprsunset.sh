#!/usr/bin/env bash
set -euo pipefail

case "${1:-toggle}" in
  status)
    if pgrep -x hyprsunset >/dev/null; then
      printf '{"text":"🌙","class":"on"}\n'
    else
      printf '{"text":"☀️","class":"off"}\n'
    fi
    ;;
  toggle)
    if pgrep -x hyprsunset >/dev/null; then
      pkill -x hyprsunset
    else
      nohup hyprsunset --temperature 4000 >/dev/null 2>&1 &
    fi
    ;;
  *)
    echo "Usage: $0 {status|toggle}" >&2
    exit 2
    ;;
esac
