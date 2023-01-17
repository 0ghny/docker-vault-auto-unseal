# shellcheck shell=bash
# -----------------------------------------------------------------------------
#                                                                      [ VARS ]
# -----------------------------------------------------------------------------
VAULT_URI="http://127.0.0.1:8200"
INIT_CHECK_URI="${VAULT_URI}/v1/sys/init"
SEAL_CHECK_URI="${VAULT_URI}/v1/sys/seal-status"
VAULT_CMD="vault"
UNLOCKER_FOLDER=/vault/unlocker
KEYS_FILE=${UNLOCKER_FOLDER}/keys
export VAULT_ADDR=${VAULT_URI}
# -----------------------------------------------------------------------------
#                                                                     [ FUNCS ]
# -----------------------------------------------------------------------------
## Wait until Vault & API is responsive
function vault__wait_for_api() {
    while ! pidof ${VAULT_CMD} >/dev/null 2>&1; do
	    log "debug" "Waiting for Vault to start"
	    sleep 1
    done
    while ! curl -sS -k "${INIT_CHECK_URI}" >/dev/null 2>&1; do
        log "debug" "[API] Waiting for Vault API to be ready: init endpoint"
        sleep 1
    done
    while ! curl -sS -k "${SEAL_CHECK_URI}" >/dev/null 2>&1; do
        log "debug" "[API] Waiting for Vault API to be ready: seal endpoint"
        sleep 1
    done
    log "debug" "[API] All ready"
}
## Check if Vault has already been initialized before
function vault__is_initialized() {
	if curl -sS -k "${INIT_CHECK_URI}" | grep -q 'true'; then
		return 0
	else
		return 1
	fi
}

## First time Vault initilization
### Returns 0 if everything was successful
### Returns 1 if Vault initialization failed
function vault__try_init() {
	local data key1 key2 key3 key4 key5 rtnk

	# Initialize the Vault
	if ! data="$( ${VAULT_CMD} operator init )"; then
		log "err" "Could not initialize the Vault via 'vault operator init'"
		return 1
	fi

	# Create if not exists
	mkdir -p ${UNLOCKER_FOLDER}

	# Extract shamir unseal keys and the root token
	key1="$( echo "${data}" | grep 'Key 1' | awk -F ':' '{print $2}' | xargs )"
	key2="$( echo "${data}" | grep 'Key 2' | awk -F ':' '{print $2}' | xargs )"
	key3="$( echo "${data}" | grep 'Key 3' | awk -F ':' '{print $2}' | xargs )"
	key4="$( echo "${data}" | grep 'Key 4' | awk -F ':' '{print $2}' | xargs )"
	key5="$( echo "${data}" | grep 'Key 5' | awk -F ':' '{print $2}' | xargs )"
	rtnk="$( echo "${data}" | grep 'Initial Root Token' | awk -F ':' '{print $2}' | xargs )"

	# Store keys and root token into Secrets/Keys file
  {
    echo "${key1}"
    echo "${key2}"
    echo "${key3}"
    echo "${key4}"
    echo "${key5}"
    echo "${rtnk}"
  }> ${KEYS_FILE}

  log "info" "All keys generated, your token is: ${rtnk}"
	return 0
}

## Initialize the vault
function vault__init() {
  if ! vault__is_initialized; then
    log "info" "Vault is not yet initialized"
    log "info" "(INIT)   Initializing the Vault"
    if ! vault__try_init ; then
      log "err" "(INIT)   Vault initialization failed. Aborting script"
      exit 1
    fi
    log "ok" "Vault successfully initialized"
  else
    log "ok" "Vault is already initialized"
  fi
}

## Check if Vault is sealed
function vault__is_unsealed() {
	set +e
	${VAULT_CMD} status >/dev/null 2>&1;
	ret="${?}"
	set -e

	if [ "${ret}" -eq "0" ]; then
		return 0
	else
		return "${ret}"
	fi
}

## Try to unseal the vault
function vault__try_unseal() {
	# We only need three keys to unseal the Vault
	local key1
	local key2
	local key3

	# Get keys from file
	log "info" "(UNSEAL) Reading keys from file ${KEYS_FILE}"
  key1=$(sed -n '1p' < ${KEYS_FILE})
  key2=$(sed -n '2p' < ${KEYS_FILE})
  key3=$(sed -n '3p' < ${KEYS_FILE})

  # Unseal vault
  log "info" "(UNSEAL) Unsealing Vault 1/3"
	if ! ${VAULT_CMD} operator unseal "${key1}" >/dev/null; then
		log "err" "Could not Use key1 to unseal the Vault"
		log "err" "Aborting script execution"
		exit 1
	fi
	log "info" "(UNSEAL) Unsealing Vault 2/3"
	if ! ${VAULT_CMD} operator unseal "${key2}" >/dev/null; then
		log "err" "Could not Use key2 to unseal the Vault"
		log "err" "Aborting script execution"
		exit 1
	fi
	log "info" "(UNSEAL) Unsealing Vault 3/3"
	if ! ${VAULT_CMD} operator unseal "${key3}" >/dev/null; then
		log "err" "Could not Use key3 to unseal the Vault"
		log "err" "Aborting script execution"
		exit 1
	fi
}

## Unseal the vault
function vault__unseal() {
	if vault__is_unsealed; then
		log "ok" "Vault is already unsealed"
		exit 0
	else
		log "info" "Vault is not yet unsealed"
		if ! vault__try_unseal ; then
			log "err" "(UNSEAL) Vault unsealing failed. Aborting script"
			exit 1
		fi
		log "ok" "Vault successfully unsealed"
	fi
}
