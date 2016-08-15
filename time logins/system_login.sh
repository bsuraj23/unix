#!/usr/bin/ksh
$ORACLE_HOME/bin/sqlplus -s system/system <<!!!
SET FEEDBACK OFF;
BEGIN NULL; END;
/
!!!
