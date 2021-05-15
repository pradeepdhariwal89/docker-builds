FROM oraclelinux:7 as base


ENV TMP=/tmp \
	TMPDIR=/tmp \
	ORACLE_BASE=/u01/app/oracle \
	ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1 \
	ORA_INVENTORY=/u01/app/oraInventory \
	ORACLE_SCRIPTS=/u01/app/oracle/scripts


ENV	LD_LIBRARY_PATH=${ORACLE_HOME}/lib:/lib:/usr/lib \
	CLASSPATH=${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib \
	PATH=${ORACLE_HOME}/bin:/usr/sbin:/usr/local/bin:$PATH


RUN yum install -y oracle-database-preinstall-19c && \
	echo 'oracle:Welcome2021' | chpasswd && \
	sed -i 's/oracle   hard   memlock/#oracle   hard   memlock/' /etc/security/limits.d/oracle-database-preinstall-19c.conf && \
	mkdir -p /u01 && \
	mkdir -p /u02/oradata && \
	mkdir -p /u03/oradata && \
	mkdir -p /RECO && \
	mkdir -p /DATA && \
	chown -R oracle:oinstall /u01 /u02 /u03 /DATA /RECO && \
	chmod -R 775 /u01 /u02 /u03 /DATA /RECO




##################################################################
#
#Create new layer for installing Oracle database binaries.
#
##################################################################

FROM base AS builder

USER oracle

COPY --chown=oracle:oinstall softwareFiles/LINUX.X64_193000_db_home.zip /tmp/LINUX.X64_193000_db_home.zip

RUN mkdir -p ${ORACLE_HOME} && \
	cd /u01/app/oracle/product/19.0.0/dbhome_1 && \
	unzip -oq /tmp/LINUX.X64_193000_db_home.zip && \
	rm /tmp/LINUX.X64_193000_db_home.zip && \
	cd /u01/app/oracle/product/19.0.0/dbhome_1 && \
	./runInstaller -ignorePrereq -waitforcompletion -silent			\
    -responseFile ${ORACLE_HOME}/install/response/db_install.rsp	\
    oracle.install.option=INSTALL_DB_SWONLY							\
    UNIX_GROUP_NAME=oinstall										\
    INVENTORY_LOCATION=${ORA_INVENTORY}								\
    SELECTED_LANGUAGES=en,en_GB										\
    ORACLE_HOME=${ORACLE_HOME}										\
    ORACLE_BASE=${ORACLE_BASE}										\
    oracle.install.db.InstallEdition=EE								\
    oracle.install.db.OSDBA_GROUP=dba								\
    oracle.install.db.OSBACKUPDBA_GROUP=dba							\
    oracle.install.db.OSDGDBA_GROUP=dba								\
    oracle.install.db.OSKMDBA_GROUP=dba								\
    oracle.install.db.OSRACDBA_GROUP=dba							\
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false						\
    DECLINE_SECURITY_UPDATES=true ; echo $? > /tmp/install.exit.code
	
RUN	mkdir -p ${ORACLE_SCRIPTS}
COPY --chown=oracle:dba setup/* $ORACLE_SCRIPTS/




##################################################################
#
#Create final layer with Oracle database software and scripts.
#
##################################################################

FROM base

COPY --chown=oracle:oinstall --from=builder /u01/app /u01/app
USER oracle
RUN echo ". ${ORACLE_SCRIPTS}/setEnv.sh" >> /home/oracle/.bash_profile

USER root
RUN /u01/app/oraInventory/orainstRoot.sh && \
	/u01/app/oracle/product/19.0.0/dbhome_1/root.sh

EXPOSE 1521

CMD ${ORACLE_SCRIPTS}/entrypoint.sh