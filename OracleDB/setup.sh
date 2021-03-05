#!/bin/bash

opts=1
CONF="N"
DOMAIN="localdomain"
HOST="dbserver"
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

if [[ BUILD_OPTION == "Install_only" ]]; then
	echo "-i: Install Only flag passed. Skipping DB creation step."
	CONTAINERID=`docker run -d -p ${PORT}:${PORT} --name ${HOST}_run --hostname ${HOST}.${DOMAIN} ${HOST}_img`
else
	printf "Creating container database."
	CONTAINERID=`docker run -d \
	-p ${PORT}:${PORT} \
	--env ORACLE_SID=${SID} \
	--env PDB_NAME=${PDB_NAME} \
	--mount type=bind,source=/mnt/d/DATA,target=/DATA \
	--mount type=bind,source=/mnt/d/RECO,target=/RECO \
	--name ${HOST}_run \
	--hostname ${HOST}.${DOMAIN} \
	${HOST}_img`

#	CONTAINERID=`docker run -d -p ${PORT}:${PORT} --env ORACLE_SID=${SID} --env PDB_NAME=${PDB_NAME} --name ${HOST}_run --hostname ${HOST}.${DOMAIN} ${HOST}_img`
	process_term $? "error: Container start failed."
fi








