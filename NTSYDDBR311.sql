/* NTSYDDBR311.sql */
/* NTSYDDBR311\MISDDRP311,51311 */
/* MIRROR */

--RESTORE FULL BACKUP ON DR
FSIDGateway
FSIDGateway_log
D:\SQLFiles\MSSQL.1\MSSQL\DATA
E:\SQLFiles\MSSQL.1\MSSQL\LOG

RESTORE DATABASE FSIDGateway
FROM DISK = 'G:\SQLBackups\SpecialBackups\CHG388402\FSIDGateway_CHG388402.BAK'
WITH MOVE 'FSIDGateway' TO 'D:\SQLFiles\MSSQL.1\MSSQL\DATA\FSIDGateway.mdf',
MOVE 'FSIDGateway_log' TO 'E:\SQLFiles\MSSQL.1\MSSQL\LOG\FSIDGateway_log.LDF',
NORECOVERY

--HAVE COLLAB TEST APP CONNECTION TO FSIDGateway ON NTSYDDBR311 (Ccontact Wintel Ops or Ben Black)

--RESTORE FULL AND TRN BACKUPS ON DR
RESTORE LOG FSIDGateway
FROM DISK = 'G:\SQLBackups\SpecialBackups\CHG388402\FSIDGateway_CHG388402.TRN'
WITH MOVE 'FSIDGateway' TO 'D:\SQLFiles\MSSQL.1\MSSQL\DATA\FSIDGateway.mdf',
MOVE 'FSIDGateway_log' TO 'E:\SQLFiles\MSSQL.1\MSSQL\LOG\FSIDGateway_log.LDF',
NORECOVERY

--CREATE MIRRORING ENDPOINT ON NTSYDDBP154 (SEE NTSYDDBP154.sql)
--NOTE: NO NEED TO CREATE ENDPOINT HERE ON THE DR/MIRRORING, SINCE IT ALREADY HAS AN ENDPOINT

--ESTABLISH MIRRORING
--SET PRINCIPAL PARTNER
ALTER DATABASE FSIDGateway SET PARTNER = 'TCP://NTSYDDBP154.pc.internal.macquarie.com:60154'

--SET MIRROR PARTNER ON THE PRINCIPAL DB (SEE NTSYDDBP154.sql)

--PERFORM FAILBACK 
ALTER DATABASE FSIDGateway SET PARTNER FAILOVER;

--VERIFY THAT DB HAS FAILEDBACK (mirroring_role_desc should be MIRROR)
select @@servername[current_server],b.name, m.mirroring_state_desc, m.mirroring_role_desc, m.mirroring_partner_instance
from sys.sysdatabases b
inner join sys.database_mirroring m on b.name = db_name(m.database_id)
where m.mirroring_state is not null
and b.name = 'FSIDGateway'   

RESTORE  FILELISTONLY
FROM DISK = 'G:\SQLBackups\SpecialBackups\CHG387385\FSIDGateway_CHG387385.TRN'

sp_helpdb FSIDGateway

use FSIDGateway
go
sp_changedbowner 'sa'

sp_change_users_login report

dbadmin..mbl_fixusers FSIDGateway

use master
go
drop database FSIDGateway

restore database FSIDGateway with recovery


ALTER DATABASE FSIDGateway
SET PARTNER OFF;
