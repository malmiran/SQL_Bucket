
restore database mpw_cards_test_mir
from disk = 'h:\SQLBackups\SpecialBackups\mpw_cards_test_mir.BAK'
with move 'mpw_cards_test_mir' to 'h:\DBData\mpw_cards_test_mir.mdf',
move 'mpw_cards_test_mir_log' to 'h:\DBLog\mpw_cards_test_mir.ldf',
norecovery

restore log mpw_cards_test_mir
from disk = 'h:\SQLBackups\SpecialBackups\mpw_cards_test_mir_1.TRN'
with norecovery

alter database mpw_cards_test_mir
set partner = 'TCP://NTSYDDBP324V4.pc.internal.macquarie.com:60295'

use master;
alter database mpw_cards_test_mir set partner failover

restore database mpw_cards_test_mir with recovery 

use master;
alter database mpw_cards_test_mir set partner failover

USE master;
DECLARE @execsql VARCHAR(1000),
        @databasename VARCHAR(100)

SET @databasename = 'mpw_cards_test_mir'
SET @execsql = ''
SELECT @execsql = @execsql + 'kill ' + CONVERT(char(10), spid) + ' '
FROM master.dbo.sysprocesses
WHERE db_name(DBID) = @databasename
AND DBID <> 0
AND spid <> @@spid

EXEC (@execsql)

use master;
drop database mpw_cards_test_mir


