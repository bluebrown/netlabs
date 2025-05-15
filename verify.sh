#!/usr/bin/env bash
set -Eeuo pipefail

for d in */; do
  printf "\e[36m[%s]\e[0m\n" "${d%/}"
  cd "$d" || exit 1
  sleep 2
  for script in setup.sh verify.sh cleanup.sh; do
    if [[ -f "$script" ]]; then
      sleep 2
      if bash "$script" 1>/dev/null; then
        printf "\e[32m[+] %s\e[0m\n" "$script"
      else
        printf "\e[31m[!] %s\e[0m\n" "$script"
      fi
    fi
  done
  cd - 1>/dev/null || exit 1
done
