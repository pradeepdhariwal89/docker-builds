#!/bin/bash

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export ORA_INVENTORY=/u01/app/oraInventory
export ORACLE_SCRIPTS=/u01/app/oracle/scripts
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:/lib:/usr/lib
export CLASSPATH=${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib
export PATH=${ORACLE_HOME}/bin:/usr/sbin:/usr/local/bin:$PATH

## Set oracle user environment variables here.
