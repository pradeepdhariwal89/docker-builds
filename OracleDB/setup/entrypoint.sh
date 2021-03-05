#!/bin/bash

start_seq() {
  $ORACLE_SCRIPTS/start_all.sh
}

# SIGTERM-handler
stop_seq() {
  [[ $ORACLE_SID ]] && { $ORACLE_SCRIPTS/stop_all.sh $PDB_NAME ; } || { echo "No SID available. Exiting" ; }
  exit 0
}

# setup handlers
trap 'stop_seq' SIGTERM

trap 'stop_seq' SIGINT

# Start apps and wait

if [[ $ORACLE_SID ]]; then
	DB_EXIST=`cat /etc/oratab | grep ${ORACLE_SID}`

	if [[ ${DB_EXIST} == "" ]]; then
		$ORACLE_SCRIPTS/create_cdb.sh ${ORACLE_SID}
		[[ $PDB_NAME ]] && { $ORACLE_SCRIPTS/create_pdb.sh $PDB_NAME ; } || { echo "PDB_NAME not set. Skipping PDB creation" ; }
	else
		start_seq
	fi
fi

while true
do
sleep 10
done
