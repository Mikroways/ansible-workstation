#!/bin/zsh
# Wrapper run by the mw-tools-upgrade systemd user timer.
#
# Sources ~/.zshrc.mikroways.updates, which defines mw-tools-upgrade and, at the
# end, already triggers a background update. We then call the function again
# explicitly: the daily lock file makes this a cheap no-op if the background run
# (from the source, or from an earlier login today) already checked for updates.
# This guarantees the update runs even if the file's auto-run block changes.

[[ -f "$HOME/.zshrc.mikroways.updates" ]] || {
  echo "mw-tools-upgrade: ~/.zshrc.mikroways.updates not found" >&2
  exit 1
}

source "$HOME/.zshrc.mikroways.updates" >/dev/null 2>&1

if (( ! $+functions[mw-tools-upgrade] )); then
  echo "mw-tools-upgrade: function not available after sourcing" >&2
  exit 1
fi

mw-tools-upgrade -y
