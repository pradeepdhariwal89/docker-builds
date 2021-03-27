#!/bin/bash

opts=1
CONF="N"
DOMAIN="localdomain"
HOST="oem13c"
BUILD_OPTION=""

usage_Help () {
	echo "Usage: "
	echo "./setup.sh [options] [<args>...]"
	echo "Options: "
	echo "-i: Software install only. OEM configuration will be skipped."
	echo "-y: Automatically answer yes for all questions."
	echo "-h, --help: Show help."
	exit 0
}

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
	elif [[ ${!opts} == "-h" || ${!opts} == "--help" ]]; then
		usage_Help
	else
		sed -i "/`echo ${!opts} | cut -d \"=\" -f1`/d" setup/config.par
		echo "${!opts}" >> setup/config.par
	fi
	(( opts++ ))
done

echo "OEM Hostname: "$HOST
echo "DOMAIN: "$DOMAIN
cat setup/config.par

printf "Confirm above information is correct. y/[N]: "
[[ $CONF == "Y" ]] && { echo "Y"; } || { read CONF; }
if [[ $CONF != "y" && $CONF != "Y" ]]; then
	process_term 1 "exit: No changes were made."
fi

echo "Building image from dockerfile: "
docker build --no-cache -t ${HOST}_img .
process_term $? "error: Docker image build failed."

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
	docker exec ${CONTAINERID} /bin/bash -c "su - oracle -c \"\${ORACLE_SCRIPTS}/oemConfig.sh\""
	process_term $? "error: Container database creation failed."
fi