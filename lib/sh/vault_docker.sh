# shellcheck shell=bash

# Check if all required stuff is available in the system
function vault__docker_precheck() {
  for rbin in vault curl hostname grep awk xargs; do
    if ! command -v "${rbin}" >/dev/null 2>&1; then
      log "err" "'${rbin}' binary not found but required"
      exit 1
    fi
  done
}
