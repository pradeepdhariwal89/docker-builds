#!/bin/bash

source config.par

sed -i "s/%%WLS_ADMIN_SERVER_PASSWORD%%/${WLS_ADMIN_SERVER_PASSWORD}/g" $ORACLE_SCRIPTS/config.rsp
sed -i "s/%%NODE_MANAGER_PASSWORD%%/${NODE_MANAGER_PASSWORD}/g" $ORACLE_SCRIPTS/config.rsp
sed -i "s/%%DATABASE_HOSTNAME%%/${DATABASE_HOSTNAME}/g" $ORACLE_SCRIPTS/config.rsp
sed -i "s/%%LISTENER_PORT%%/${LISTENER_PORT}/g" $ORACLE_SCRIPTS/config.rsp
sed -i "s/%%SERVICENAME_OR_SID%%/${SERVICENAME_OR_SID}/g" $ORACLE_SCRIPTS/config.rsp
sed -i "s/%%SYS_PASSWORD%%/${SYS_PASSWORD}/g" $ORACLE_SCRIPTS/config.rsp
sed -i "s/%%SYSMAN_PASSWORD%%/${SYSMAN_PASSWORD}/g" $ORACLE_SCRIPTS/config.rsp
sed -i "s/%%DEPLOYMENT_SIZE%%/${DEPLOYMENT_SIZE}/g" $ORACLE_SCRIPTS/config.rsp
sed -i "s/%%MANAGEMENT_TABLESPACE_LOCATION%%/${MANAGEMENT_TABLESPACE_LOCATION}/g" $ORACLE_SCRIPTS/config.rsp
sed -i "s/%%AGENT_REGISTRATION_PASSWORD%%/${AGENT_REGISTRATION_PASSWORD}/g" $ORACLE_SCRIPTS/config.rsp

${MW_HOME}/sysman/install/ConfigureGC.sh -silent -responseFile $ORACLE_SCRIPTS/config.rsp

echo '${OMS_HOME}/bin/emctl start oms' >> $ORACLE_SCRIPTS/oracleStart.sh
echo '${AGENT_HOME}/bin/emctl start agent' >> $ORACLE_SCRIPTS/oracleStart.sh

echo '${OMS_HOME}/bin/emctl stop oms -all' >> $ORACLE_SCRIPTS/oracleStop.sh
echo '${AGENT_HOME}/bin/emctl agent agent' >> $ORACLE_SCRIPTS/oracleStop.sh