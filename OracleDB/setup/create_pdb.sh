#!/bin/bash

PDB_NAME=$1
HOST=`hostname`

sqlplus / as sysdba <<EOF
CREATE PLUGGABLE DATABASE ${PDB_NAME}
ADMIN USER db_admin IDENTIFIED BY SysPassword1
ROLES=(DBA);
alter pluggable database ${PDB_NAME} open;
alter pluggable database ${PDB_NAME} save state;
exit;
EOF

cat ${ORACLE_SCRIPTS}/tnsnames.ora > /tmp/tnsnames.tmp
sed -i "s/%%PORT%%/${PORT}/g" /tmp/tnsnames.tmp
sed -i "s/%%ORACLE_HOSTNAME%%/${HOST}/g" /tmp/tnsnames.tmp
sed -i "s/%%ORACLE_SID%%/${PDB_NAME}/g" /tmp/tnsnames.tmp
cat /tmp/tnsnames.tmp >> $ORACLE_HOME/network/admin/tnsnames.ora
