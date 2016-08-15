#!/usr/bin/ksh
. oraprf IEB01P
$ORACLE_HOME/bin/sqlplus -s anand1/anand1 <<!!!
SET FEEDBACK OFF;
BEGIN NULL; END;
/
!!!
exit
