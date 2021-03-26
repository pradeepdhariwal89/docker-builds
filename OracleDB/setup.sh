#!/bin/bash

opts=1
CONF="N"
DOMAIN="localdomain"
HOST="db19c"
BUILD_OPTION=""
SID="CDB1"
PORT="1521"

process_term () {
	EXIT_CODE=$1
	ERR_MSG=$2
	[[ $EXIT_CODE -ne 0 ]] && { echo $ERR_MSG ; echo "Process terminated." ; exit 1 ; } || { echo "Success." ; }
}

while (( opts<=$# ))
do
	if [[ ${!opts} == "-y" || ${!opts} == "-Y" ]]; then
		CONF="Y"
	elif [[ ${!opts} == "-i" ]]; then
		BUILD_OPTION="Install_only"
	else
		eval "${!opts}"
	fi
	(( opts++ ))
done

echo "Container SID: "$SID
echo "Listener Port: "$PORT
echo "Database Hostname: "$HOST
echo "DOMAIN: "$DOMAIN
[[ $PDB_NAME ]] && { echo "Pluggable Database: "$PDB_NAME ; } || { echo "No PDB will be created." ; }


printf "Confirm above information is correct. y/[N]: "
[[ $CONF == "Y" ]] && { echo "Y"; } || { read CONF; }
if [[ $CONF != "y" && $CONF != "Y" ]]; then
	process_term 1 "exit: No changes were made."
fi

echo "Building image from dockerfile: "
docker build --no-cache -t ${HOST}_img .
process_term $? "error: Docker image build failed."

# Un-comment below code to mount drives from server
# CONTAINERID=`docker run -d \
# 	-p ${PORT}:${PORT} \
# 	--mount type=bind,source=<Datafile mount>,target=/DATA \
# 	--mount type=bind,source=<Recovery mount>,target=/RECO \
# 	--mount type=bind,source=<Scripts Location>,target=/u01/app/oracle/scripts \
# 	--name ${HOST}_run \
# 	--hostname ${HOST}.${DOMAIN} \
# 	${HOST}_img`

CONTAINERID=`docker run -d \
	-p ${PORT}:${PORT} \
	--name ${HOST}_run \
	--hostname ${HOST}.${DOMAIN} \
	${HOST}_img`
process_term $? "error: Container start failed."

if [[ BUILD_OPTION == "Install_only" ]]; then
	echo "-i: Install Only flag passed. Skipping DB creation step."
	echo "Container created: ${CONTAINERID}"
else
	echo "Creating container database."
	docker exec ${CONTAINERID} /bin/bash -c "su - oracle -c \"\${ORACLE_SCRIPTS}/create_cdb.sh ${SID} ${PORT}\""
	process_term $? "error: Container database creation failed."
	if [[ $PDB_NAME ]]; then
		docker exec ${CONTAINERID} /bin/bash -c "su - oracle -c \"\${ORACLE_SCRIPTS}/create_pdb.sh ${PDB_NAME}\""
		process_term $? "error: Pluggable database creation failed."
	fi
fi








