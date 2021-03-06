#!/bin/bash

start_seq() {
  echo "Start sequence `date`" >> /tmp/startSeq.file
}

# SIGTERM-handler
stop_seq() {
  echo "Stop sequence `date`" >> /tmp/stopSeq.file
  exit 0
}

# setup handlers
trap 'stop_seq' SIGTERM

trap 'stop_seq' SIGINT

# Start apps and wait

start_seq

while true
do
sleep 10
done
