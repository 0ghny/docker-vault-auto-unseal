#!/bin/sh
# -----------------------------------------------------------------------------
# SETUP
# -----------------------------------------------------------------------------
set -e
# shellcheck disable=SC3045
ulimit -c 0
# Load libraries
# shellcheck disable=SC1091
. /usr/local/lib/sh/log.sh
# shellcheck disable=SC1091
. /usr/local/lib/sh/vault_docker.sh
# shellcheck disable=SC1091
. /usr/local/lib/sh/vault_utils.sh
# Modify path to include /bin (where vault-operator is)
PATH=${PATH}:/usr/local/bin
# -----------------------------------------------------------------------------
# GLOBALS
# -----------------------------------------------------------------------------
# shellcheck disable=SC2086
export LOGFILE=${DOCKER_VAULT_LOGFILE:-"/vault/logs/vault_operator.log"}
# -----------------------------------------------------------------------------
# ENTRYPOINT
# -----------------------------------------------------------------------------
# HACK: in some systems i've tried, docker-entrypoint from official image
# fails when trying to read /vault/config even if vault:vault.
chmod -R 755 /vault/config
chmod 755 /vault/logs
chmod 755 /vault/file

# Run vault unlocker/initializer in parallel
log "debug" "Executing unlocker script in parallel"
# shellcheck disable=SC1091
. /usr/local/bin/vault-operator &
# Run vault process
log "debug" "Executing official docker-entrypoint.sh with hardcoded values"
# shellcheck disable=SC1091,SC2240
. /usr/local/bin/docker-entrypoint.sh vault server -config=/vault/config/vault.json
