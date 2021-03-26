#!/bin/bash

gen_hostkeys() {
  /usr/sbin/sshd-keygen
}

start_seq() {
  su - oracle -c "$ORACLE_SCRIPTS/start_all.sh" &
  /usr/sbin/sshd
}

# SIGTERM-handler
stop_seq() {
  su - oracle -c "$ORACLE_SCRIPTS/stop_all.sh"
  exit 0
}

# setup handlers
trap 'stop_seq' SIGTERM

trap 'stop_seq' SIGINT

# Start apps
if [[ ! -f /etc/ssh/ssh_host_rsa_key ]]; then
  gen_hostkeys
fi

start_seq

# Entrypoint command
while true
do
sleep 3
done
