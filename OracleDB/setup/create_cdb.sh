#!/bin/bash

ORACLE_SID=$1
PORT=$2
RECO_DIR=/RECO
DATA_DIR=/DATA
HOST=`hostname`

cat ${ORACLE_SCRIPTS}/listener.ora > $ORACLE_HOME/network/admin/listener.ora
sed -i "s/%%PORT%%/${PORT}/g" $ORACLE_HOME/network/admin/listener.ora
sed -i "s/%%ORACLE_HOSTNAME%%/${HOST}/g" $ORACLE_HOME/network/admin/listener.ora

cat ${ORACLE_SCRIPTS}/tnsnames.ora > /tmp/tnsnames.tmp
sed -i "s/%%PORT%%/${PORT}/g" /tmp/tnsnames.tmp
sed -i "s/%%ORACLE_HOSTNAME%%/${HOST}/g" /tmp/tnsnames.tmp
sed -i "s/%%ORACLE_SID%%/${ORACLE_SID}/g" /tmp/tnsnames.tmp
cat /tmp/tnsnames.tmp >> $ORACLE_HOME/network/admin/tnsnames.ora

echo "export ORACLE_SID=/u01/app/oracle" >> ${ORACLE_SCRIPTS}/setEnv.sh
echo "export PORT=${PORT}" >> ${ORACLE_SCRIPTS}/setEnv.sh

$ORACLE_HOME/bin/dbca -silent -createDatabase								\
     -templateName General_Purpose.dbc										\
     -gdbname ${ORACLE_SID} -sid  ${ORACLE_SID} -responseFile NO_VALUE		\
     -characterSet AL32UTF8													\
     -sysPassword SysPassword1												\
     -systemPassword SysPassword1											\
     -createAsContainerDatabase true										\
     -databaseType MULTIPURPOSE												\
     -memoryMgmtType auto_sga												\
	 -variables db_create_file_dest='${DATA_DIR}',db_create_online_log_dest_1='/u02/oradata',db_create_online_log_dest_2='/u03/oradata' \
     -totalMemory 4000														\
     -storageType FS														\
     -datafileDestination "${DATA_DIR}"										\
	 -useOMF true															\
     -recoveryAreaDestination "${RECO_DIR}"									\
	 -redoLogFileSize 50													\
	 -enableArchive true													\
     -emConfiguration NONE													\
	 -ignorePreReqs

cp /etc/oratab /tmp/oratab.bkp
sed 's/:N/:Y/' /etc/oratab > /tmp/oratab
cat /tmp/oratab > /etc/oratab

lsnrctl start