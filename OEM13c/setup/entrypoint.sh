#!/bin/bash

gen_hostkeys() {
	/usr/sbin/sshd-keygen
}

start_seq() {
  echo "Start sequence `date`" >> /tmp/startSeq.file
  /usr/sbin/sshd
}

# SIGTERM-handler
stop_seq() {
  echo "Stop sequence `date`" >> /tmp/stopSeq.file
  exit 0
}

# setup handlers
trap 'stop_seq' SIGTERM

trap 'stop_seq' SIGINT

if [[ ! -f /etc/ssh/ssh_host_rsa_key]]; then
	gen_hostkeys
fi

# Start apps and wait
start_seq

# Entrypoint command
while true
do
sleep 3
done
