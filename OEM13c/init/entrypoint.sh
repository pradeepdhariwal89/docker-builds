#!/bin/bash

## Container Startup handler
start_seq() {

  if [[ ! -f /etc/ssh/ssh_host_rsa_key]]; then
    /usr/sbin/sshd-keygen
  fi

  echo "172.17.0.2  db19c.localdomain.com db19c" >> /etc/hosts
  /usr/sbin/sshd
  su - oracle -c "${ORACLE_SCRIPTS}/oracleStart.sh"

}

# Container shutdown handler
stop_seq() {

  su - oracle -c "${ORACLE_SCRIPTS}/oracleStop.sh"
  exit 0

}

# SIGTERM-handler
trap 'stop_seq' SIGTERM
trap 'stop_seq' SIGINT

# Start apps and wait
start_seq
while true
do
sleep 3
done
