docker pull oracleinanutshell/oracle-xe-11g

docker ps -a

docker rm -f oracle-xe


docker run -d --name oracle-xe \
  -p 49161:1521 -p 8081:8080 \
  -v oracle-data:/u01/app/oracle \
  -e ORACLE_ALLOW_REMOTE=true \
  oracleinanutshell/oracle-xe-11g



docker ps

docker exec -it oracle-xe bash

mkdir -p /u01/app/oracle/dumpdir
chmod -R 777 /u01/app/oracle/dumpdir/

sqlplus system/oracle@//localhost:1521/XE


-- DROP TABLESPACE CBSINDEX INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE CBSINDEX
DATAFILE 
  '/u01/app/oracle/oradata/XE/CBSINDEX.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE DATA INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE DATA
DATAFILE 
  '/u01/app/oracle/oradata/XE/DATA.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE DATA_TRS INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE DATA_TRS
DATAFILE 
  '/u01/app/oracle/oradata/XE/DATA_TRS.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE GOLDEN_GATE INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE GOLDEN_GATE
DATAFILE 
  '/u01/app/oracle/oradata/XE/GOLDEN_GATE.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE MAST INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE MAST
DATAFILE 
  '/u01/app/oracle/oradata/XE/MAST.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE SYSAUX INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE SYSAUX
DATAFILE 
  'D:\APP\LENOVO\ORADATA\ORCL\SYSAUX01.DBF' SIZE 128M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE SYSTEM INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE SYSTEM
DATAFILE 
  'D:\APP\LENOVO\ORADATA\ORCL\SYSTEM01.DBF' SIZE 128M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
FLASHBACK ON;

-- DROP TABLESPACE TBAML INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBAML
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBAML.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBFES INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBFES
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBFES.DBF' SIZE 128M AUTOEXTEND ON NEXT 8K MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBMFI INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBMFI
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBMFI.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSACCESS INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSACCESS
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSACCESS.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSACNTOTN INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSACNTOTN
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSACNTOTN.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSACNTS INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSACNTS
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSACNTS.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSAML INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSAML
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSAML.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSBIS INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSBIS
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSBIS.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSCLIENTS INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSCLIENTS
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSCLIENTS.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSCMSMST INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSCMSMST
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSCMSMST.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSCOMMON INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSCOMMON
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSCOMMON.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSIBIL INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSIBIL
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSIBIL.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSICLG INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSICLG
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSICLG.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSILC INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSILC
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSILC.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSIMAGE INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSIMAGE
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSIMAGE.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSIRS INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSIRS
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSIRS.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSIRSRPT INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSIRSRPT
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSIRSRPT.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSLIMIT INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSLIMIT
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSLIMIT.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSOBC INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSOBC
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSOBC.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSOBIL INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSOBIL
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSOBIL.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSOCLG INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSOCLG
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSOCLG.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSOLC INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSOLC
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSOLC.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSORS INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSORS
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSORS.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSREPORT INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSREPORT
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSREPORT.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSRMAN INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSRMAN
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSRMAN.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSRPTIDX INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSRPTIDX
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSRPTIDX.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSSALARY INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSSALARY
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSSALARY.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSSECURITY INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSSECURITY
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSSECURITY.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSSHADOWATM INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSSHADOWATM
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSSHADOWATM.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSSIGNATURE INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSSIGNATURE
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSSIGNATURE.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSSIN INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSSIN
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSSIN.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSTDS INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSTDS
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSTDS.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSTFM INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSTFM
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSTFM.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBSTRAN INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBSTRAN
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBSTRAN.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBS_AUDIT INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBS_AUDIT
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBS_AUDIT.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TBTMP INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TBTMP
DATAFILE 
  '/u01/app/oracle/oradata/XE/TBTMP.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TDERMAN INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TDERMAN
DATAFILE 
  '/u01/app/oracle/oradata/XE/TDERMAN.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TEMP INCLUDING CONTENTS AND DATAFILES;

CREATE TEMPORARY TABLESPACE TEMP
TEMPFILE 
  'D:\APP\LENOVO\ORADATA\ORCL\TEMP01.DBF' SIZE 128M AUTOEXTEND ON NEXT 640K MAXSIZE UNLIMITED
TABLESPACE GROUP ''
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M
FLASHBACK ON;

-- DROP TABLESPACE TS_INDEXES INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TS_INDEXES
DATAFILE 
  '/u01/app/oracle/oradata/XE/TS_INDEXES.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TS_MASTERS INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TS_MASTERS
DATAFILE 
  '/u01/app/oracle/oradata/XE/TS_MASTERS.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TS_REPORTS INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TS_REPORTS
DATAFILE 
  '/u01/app/oracle/oradata/XE/TS_REPORTS.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TS_TRANS INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TS_TRANS
DATAFILE 
  '/u01/app/oracle/oradata/XE/TS_TRANS.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TS_TREASURY INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TS_TREASURY
DATAFILE 
  '/u01/app/oracle/oradata/XE/TS_TREASURY.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE TS_TX INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE TS_TX
DATAFILE 
  '/u01/app/oracle/oradata/XE/TS_TX.DBF' SIZE 128M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

-- DROP TABLESPACE UNDOTBS1 INCLUDING CONTENTS AND DATAFILES;

CREATE UNDO TABLESPACE UNDOTBS1
DATAFILE 
  'D:\APP\LENOVO\ORADATA\ORCL\UNDOTBS01.DBF' SIZE 1145M AUTOEXTEND ON NEXT 5M MAXSIZE UNLIMITED
ONLINE
RETENTION NOGUARANTEE
BLOCKSIZE 8K
FLASHBACK ON;

-- DROP TABLESPACE USERS INCLUDING CONTENTS AND DATAFILES;

CREATE TABLESPACE USERS
DATAFILE 
  'D:\APP\LENOVO\ORADATA\ORCL\USERS01.DBF' SIZE 30M AUTOEXTEND ON NEXT 1280K MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO






CREATE USER SBL_CBS IDENTIFIED BY SBL_CBS DEFAULT TABLESPACE TBFES TEMPORARY TABLESPACE TEMP PROFILE DEFAULT ACCOUNT UNLOCK;

GRANT CONNECT TO SBL_CBS;
GRANT RESOURCE TO SBL_CBS;
ALTER USER SBL_CBS DEFAULT ROLE ALL;
GRANT CREATE ANY SYNONYM TO SBL_CBS;
GRANT CREATE ANY VIEW TO SBL_CBS;
GRANT CREATE SEQUENCE TO SBL_CBS;
GRANT CREATE SESSION TO SBL_CBS;
GRANT CREATE TABLE TO SBL_CBS;
GRANT CREATE VIEW TO SBL_CBS;
GRANT CREATE type TO SBL_CBS;
GRANT DEBUG ANY PROCEDURE TO SBL_CBS;
GRANT DEBUG CONNECT SESSION TO SBL_CBS;
GRANT UNLIMITED TABLESPACE TO SBL_CBS;
GRANT IMP_FULL_database TO SBL_CBS;
GRANT DBA TO SBL_CBS;

create or replace directory DUMPDIR AS '/u01/app/oracle/dumpdir';

GRANT READ, WRITE ON DIRECTORY SYS.DUMPDIR TO SBL_CBS;



GRANT EXECUTE ON SYS.DBMS_LOCK TO SBL_CBS;
GRANT EXECUTE ON SYS.DBMS_SQLHASH TO SBL_CBS;


ALTER USER SBL_CBS QUOTA UNLIMITED ON DATA;
ALTER USER SBL_CBS QUOTA UNLIMITED ON SYSTEM;
ALTER USER SBL_CBS QUOTA UNLIMITED ON TBAML;
ALTER USER SBL_CBS QUOTA UNLIMITED ON TBFES;
ALTER USER SBL_CBS QUOTA UNLIMITED ON TBSTRAN;
ALTER USER SBL_CBS QUOTA UNLIMITED ON USERS;

ALTER USER SBL_CBS QUOTA UNLIMITED ON CBSINDEX;
ALTER USER SBL_CBS QUOTA UNLIMITED ON TBACNTS;
ALTER USER SBL_CBS QUOTA UNLIMITED ON TBSIMAGE;
ALTER USER SBL_CBS QUOTA UNLIMITED ON TBSSIGNATURE;
ALTER USER SBL_CBS QUOTA UNLIMITED ON TRBFES;
ALTER USER SBL_CBS QUOTA UNLIMITED ON TS_TRANS;



--whole dump(entering to the sys)
tables=emp
host (impdp SBL_CBS/SBL_CBS exclude=table_data directory=DUMPDIR dumpfile=CBS_ISL_WEIGHTAGE.DMP logfile=IMP_CBS_ISL_WEIGHTAGE.log remap_schema=CBS_ISL:SBL_CBS transform=oid:n IGNORE='Y');



insert INTO SBL_CBS.ABB_PREVIOUS_VENDOR(BRANCH_CODE, PREVIOUS_VENDOR) VALUES(18, 'SBS') ;



docker cp /home/fahim/backup_import_oracle.sh oracle-xe:/u01/app/oracle/dumpdir/
docker exec -it oracle-xe bash
cd /u01/app/oracle/dumpdir/

chmod +x backup_import_oracle.sh


./backup_import_oracle.sh

