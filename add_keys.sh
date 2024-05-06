#!/usr/bin/env bash
#
# A good old bash | curl script for direnv.
#
set -euo pipefail

{ # Prevent execution if this script was only partially downloaded

  log() {
    echo "[add_keys] $*" >&2
  }

  die() {
    log "$@"
    exit 1
  }

  at_exit() {
    ret=$?
    if [[ $ret -gt 0 ]]; then
      log "the script failed with error $ret.\n" \
        "\n" \
        "To report installation errors, submit an issue to\n" \
        "    https://github.com/direnv/direnv/issues/new/choose"
    fi
    exit "$ret"
  }
  trap at_exit EXIT

  add() {
    content=`cat $1`
    grep -q "$content" ~/.ssh/authorized_keys || echo "$content" >> ~/.ssh/authorized_keys
  }

  download_and_add() {
    log "Add $1"
    curl -fs ${HOME_URL}/$1 > $TEMP && test -s $TEMP && add $TEMP
  }

  TEMP=/tmp/pismenny_ssh_public_key
  HOME_URL=https://pismenny.ru/

  download_and_add id_ed25519.pub 
  download_and_add id_rsa.pub
  log Done
}
