# shellcheck shell=bash

## Initialize logfile
function log__init() {
    if [ ! -f "${LOGFILE}" ]; then
	# Create log dir if it does not exist
	if [ ! -d "$( dirname "${LOGFILE}" )" ]; then
		if ! mkdir -p "$( dirname "${LOGFILE}" )"; then
			>&2 echo "$(date '+%Y-%m-%d %H:%M:%S') (VAULT) [WARN]  Logging disabled. Cannot create log directory $( dirname "${LOGFILE}" )"
		fi
	fi
	# Create log file
	if ! touch "${LOGFILE}"; then
		>&2 echo "$(date '+%Y-%m-%d %H:%M:%S') (VAULT) [WARN]  Logging disabled. Cannot create log file ${LOGFILE}"
	fi
    fi
    if [ ! -w "${LOGFILE}" ]; then
        >&2 echo "$(date '+%Y-%m-%d %H:%M:%S') (VAULT) [WARN]  Logging disabled. Log file is not writable: ${LOGFILE}"
    fi
}
## Logfile wrapper
## It logs to stdout/stderr and to logfile in order to make sure
## to catch errors everywhere.
## Ensure that the logfile location is picked up by Cloudwatch
function log() {
	local lvl="${1}"
	local msg="${2}"
	local date
	local apptag="VAULT UNLOCKER"

	date="$(date '+%Y-%m-%d %H:%M:%S')"

	# Error
	if [ "${lvl}" = "err" ]; then
		>&2 echo "${date} (${apptag}) [ERROR] ${msg}"
		if [ -w "${LOGFILE}" ]; then
			echo "${date} (${apptag}) [ERROR] ${msg}" >> "${LOGFILE}"
		fi
	# Warning
	elif [ "${lvl}" = "warn" ]; then
		>&2 echo "${date} (${apptag}) [WARN]  ${msg}"
		if [ -w "${LOGFILE}" ]; then
			echo "${date} (${apptag}) [WARN]  ${msg}" >> "${LOGFILE}"
		fi
	# OK
	elif [ "${lvl}" = "ok" ]; then
		echo "${date} (${apptag}) [OK]    ${msg}"
		if [ -w "${LOGFILE}" ]; then
			echo "${date} (${apptag}) [OK]    ${msg}" >> "${LOGFILE}"
		fi
	# Info
	elif [ "${lvl}" = "info" ]; then
		echo "${date} (${apptag}) [INFO]  ${msg}"
		if [ -w "${LOGFILE}" ]; then
			echo "${date} (${apptag}) [INFO]  ${msg}" >> "${LOGFILE}"
		fi
	# Debug
	elif [ "${lvl}" = "debug" ]; then
		echo "${date} (${apptag}) [DEBUG] ${msg}"
		if [ -w "${LOGFILE}" ]; then
			echo "${date} (${apptag}) [DEBUG] ${msg}" >> "${LOGFILE}"
		fi
	# Unknown
	else
		echo "${date} (${apptag}) [OTHER] ${msg}"
		if [ -w "${LOGFILE}" ]; then
			echo "${date} (${apptag}) [OTHER] ${msg}" >> "${LOGFILE}"
		fi
	fi
}
