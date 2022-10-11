#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202210041855-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.com
# @@License          :  WTFPL
# @@ReadME           :  entrypoint-supabase.sh --help
# @@Copyright        :  Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @@Created          :  Tuesday, Oct 04, 2022 18:55 EDT
# @@File             :  entrypoint-supabase.sh
# @@Description      :
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  other/docker-entrypoint
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
[ -n "$DEBUG" ] && set -x
set -o pipefail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="$(basename "$0" 2>/dev/null)"
VERSION="202210041855-git"
HOME="${USER_HOME:-$HOME}"
USER="${SUDO_USER:-$USER}"
RUN_USER="${SUDO_USER:-$USER}"
SCRIPT_SRC_DIR="${BASH_SOURCE%/*}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set functions
__version() { echo -e ${GREEN:-}"$VERSION"${NC:-}; }
__find() { ls -A "$*" 2>/dev/null; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# colorization
[ -n "$SHOW_RAW" ] || printf_color() { echo -e '\t\t'${2:-}"${1:-}${NC}"; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__exec_bash() {
  local cmd="${*:-/bin/bash}"
  local exitCode=0
  echo "Executing command: $cmd"
  $cmd || exitCode=10
  return ${exitCode:-$?}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define default variables
TZ="${TZ:-America/New_York}"
HOSTNAME="${HOSTNAME:-casjaysdev-bin}"
BIN_DIR="${BIN_DIR:-/usr/local/bin}"
DATA_DIR="${DATA_DIR:-$(__find /data/ 2>/dev/null | grep '^' || false)}"
CONFIG_DIR="${CONFIG_DIR:-$(__find /config/ 2>/dev/null | grep '^' || false)}"
CONFIG_COPY="${CONFIG_COPY:-false}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional variables

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Export variables
export TZ HOSTNAME
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import variables from file
[ -f "/root/env.sh" ] && . "/root/env.sh"
[ -f "/config/.env.sh" ] && . "/config/.env.sh"
[ -f "/root/env.sh" ] && [ ! -f "/config/.env.sh" ] && cp -Rf "/root/env.sh" "/config/.env.sh"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set timezone
[ -n "${TZ}" ] && echo "${TZ}" >/etc/timezone
[ -f "/usr/share/zoneinfo/${TZ}" ] && ln -sf "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set hostname
if [ -n "${HOSTNAME}" ]; then
  echo "${HOSTNAME}" >/etc/hostname
  echo "127.0.0.1 ${HOSTNAME} localhost ${HOSTNAME}.local" >/etc/hosts
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Delete any gitkeep files
[ -n "${CONFIG_DIR}" ] && { [ -d "${CONFIG_DIR}" ] && rm -Rf "${CONFIG_DIR}/.gitkeep" || mkdir -p "/config/"; }
[ -n "${DATA_DIR}" ] && { [ -d "${DATA_DIR}" ] && rm -Rf "${DATA_DIR}/.gitkeep" || mkdir -p "/data/"; }
[ -n "${BIN_DIR}" ] && { [ -d "${BIN_DIR}" ] && rm -Rf "${BIN_DIR}/.gitkeep" || mkdir -p "/bin/"; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copy config files to /etc
if [ -n "${CONFIG_DIR}" ] && [ "${CONFIG_COPY}" = "true" ]; then
  for config in ${CONFIG_DIR}; do
    if [ -d "/config/$config" ]; then
      [ -d "/etc/$config" ] || mkdir -p "/etc/$config"
      cp -Rf "/config/$config/." "/etc/$config/"
    elif [ -f "/config/$config" ]; then
      cp -Rf "/config/$config" "/etc/$config"
    fi
  done
fi
[ -f "/etc/.env.sh" ] && rm -Rf "/etc/.env.sh"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional commands

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
case "$1" in
--help) # Help message
  echo 'Docker container for '$APPNAME''
  echo "Usage: $APPNAME [healthcheck, bash, command]"
  echo "Failed command will have exit code 10"
  echo
  exitCode=$?
  ;;

healthcheck) # Docker healthcheck
  echo "$(uname -s) $(uname -m) is running"
  echo _other_commands here
  exitCode=$?
  ;;

*/bin/sh | */bin/bash | bash | shell | sh) # Launch shell
  shift 1
  __exec_bash "${@:-/bin/bash}"
  exitCode=$?
  ;;

*) # Execute primary command
  if [ $# -eq 0 ]; then
    /usr/local/bin/pocketbase serve
  else
    __exec_bash "/bin/bash"
  fi
  exitCode=$?
  ;;
esac
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# end of entrypoint
exit ${exitCode:-$?}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
