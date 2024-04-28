/* NTSYDDBP154.sql */
/* NTSYDDBP154\MISDPRD154,50154 */
/* PRINCIPAL */

--SET RECOVERY TO FULL
ALTER DATABASE FSIDGateway SET RECOVERY FULL;

--TAKE FULL BACKUP
BACKUP DATABASE FSIDGateway
TO DISK = 'G:\SQLBackups\SpecialBackups\CHG388402\FSIDGateway_CHG388402.BAK'

--TAKE TLOG BACKUP
BACKUP LOG FSIDGateway
TO DISK = 'G:\SQLBackups\SpecialBackups\CHG388402\FSIDGateway_CHG388402.TRN'

--COPY BACKUPS TO NTSYDDBR311

--RESTORE FULL BACKUP ON DR (SEE NTSYDDBR311.sql)

--HAVE COLLAB TEST APP CONNECTION TO FSIDGateway ON NTSYDDBR311 (Ccontact Wintel Ops or Ben Black)

--RESTORE FULL AND TRN BACKUPS ON DR (SEE NTSYDDBR311.sql)

--CREATE MIRRORING ENDPOINT 
USE master;
go

CREATE ENDPOINT Mirroring_Endpoint
    AUTHORIZATION [NTADMIN\SRVC_SQL_ISD_PRD]
    STATE = STARTED
    AS TCP ( LISTENER_PORT = 60154 )
    FOR DATABASE_MIRRORING (
       AUTHENTICATION = WINDOWS KERBEROS, 
       ENCRYPTION = SUPPORTED,
       ROLE=PARTNER);
GO

GRANT CONNECT ON ENDPOINT::Mirroring_Endpoint TO [NTADMIN\SRVC_SQL_ISD_PRD];
GO

--ESTABLISH MIRRORING
--SET PRINCIPAL PARTNER ON THE MIRROR DB (SEE NTSYDDBR311.sql)

--SET MIRROR PARTNER
ALTER DATABASE FSIDGateway SET PARTNER = 'TCP://ntsyddbr311.pc.internal.macquarie.com:32766'
TCP://NTSYDDBP154.pc.internal.macquarie.com:60154
TCP://ntsyddbr311.pc.internal.macquarie.com:32766

--VERIFY THAT DB IS MIRRORED (mirroring_role_desc should be PRINCIPAL)
select b.name, m.mirroring_state_desc, m.mirroring_role_desc, m.mirroring_partner_instance
from sys.sysdatabases b
inner join sys.database_mirroring m on b.name = db_name(m.database_id)
where m.mirroring_state is not null
and b.name = 'FSIDGateway'   

--TEST FAILOVER (FROM NTSYDDBP154 TO NTSYDDBR311)
ALTER DATABASE FSIDGateway SET PARTNER FAILOVER;

--VERIFY THAT DB HAS FAILED OVER (mirroring_role_desc should be MIRROR)
select @@servername[current_server],b.name, m.mirroring_state_desc, m.mirroring_role_desc, m.mirroring_partner_instance
from sys.sysdatabases b
inner join sys.database_mirroring m on b.name = db_name(m.database_id)
where m.mirroring_state is not null
and b.name = 'FSIDGateway'   

--HAVE COLLAB TEST APP CONNECTION TO FSIDGateway ON NTSYDDBR311 (Ccontact Wintel Ops or Ben Black)

--PERFORM FAILBACK (SEE NTSYDDBR311.sql)

sp_helpdb fsidgateway

USE DBADMIN
GO
select * from configplans where planname = 'TRN'

use fsidgateway
go
sp_helpuser


ALTER DATABASE FSIDGateway
SET PARTNER SUSPEND;