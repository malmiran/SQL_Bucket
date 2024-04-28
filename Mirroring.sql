
--Get mirroring state of all mirrored DBs (including saftey level)
select getdate()[currentdate]
      ,@@servername[current_sqlinstance]
      ,mirroring_partner_instance      
      ,db_name(database_id)[db]
      ,mirroring_state_desc
      ,mirroring_role_desc
      ,mirroring_partner_name [endpoint]
      ,CASE mirroring_safety_level_desc 
          WHEN 'FULL' THEN 'FULL/Sync Mirroring/High-safety Mode'
          ELSE 'OFF/Asynchronous Mirroring/High-performance Mode'
       END [safety_mode]
from sys.database_mirroring
where mirroring_state is not null
and db_name(database_id) = 'mts_finance_pl'

--Get endpoints
select @@servername[current_server]
      ,mirroring_partner_name
      ,db_name(database_id)[db]
from sys.database_mirroring
where mirroring_state is not null

--Suspend Mirroring
ALTER DATABASE [] SET PARTNER SUSPEND;

--Disable Mirrroing
ALTER DATABASE [thinkFolio_prd] SET PARTNER OFF;

--FAILOVER (SYNC MIRRORING)
ALTER DATABASE [mpw_cards_prd] SET PARTNER FAILOVER;

--FAILOVER (ASYNC MIRRORING)
--FOR BCP TEST (no data loss)
USE master;
ALTER DATABASE [] SET PARTNER SAFETY FULL; 
WAITFOR DELAY '00:00:05'; 
ALTER DATABASE [] SET PARTNER FAILOVER; 

--FOR REAL DR SCENARIO (with data loss/when prod is FUBAR)
--TO BE EXECUTED IN DR (obviously)
USE master;
ALTER DATABASE [] SET PARTNER FORCE_SERVICE_ALLOW_DATA_LOSS;

--SWITCH MIRRORING MODE (OR SAFETY LEVEL)
--CHANGE TO SYNC (High Safety Mode)
USE master;
ALTER DATABASE [] SET PARTNER SAFETY ON;

--CHANGE TO ASYNC (High Performance Mode)
USE master;
ALTER DATABASE [mpw_cards_prd] SET PARTNER SAFETY OFF;

/* ENDPOINTS and PERMISSIONS */
SELECT perm.class_desc, perm.permission_name, endpoint_name = e.name, e.state_desc, e.type_desc, t.port, perm.state_desc, grantor = prin1.name, grantee = prin2.name
FROM master.sys.server_permissions perm
 INNER JOIN master.sys.server_principals prin1 ON perm.grantor_principal_id = prin1.principal_id
 INNER JOIN master.sys.server_principals prin2 ON perm.grantee_principal_id = prin2.principal_id
 LEFT JOIN master.sys.endpoints e ON perm.major_id = e.endpoint_id
 LEFT JOIN master.sys.tcp_endpoints t on t.endpoint_id = e.endpoint_id
WHERE perm.class_desc = 'ENDPOINT' AND e.type_desc = 'DATABASE_MIRRORING' order by endpoint_name ASC

/* DROP CREATE ENDPOINT */
1.	Drop current endpoint
        DROP ENDPOINT [Mirroring_Endpoint]
2.	Create new endpoint using KERBEROS authentication
CREATE ENDPOINT [Mirroring_Endpoint] 
	AUTHORIZATION [sa]
	STATE=STARTED
	AS TCP (LISTENER_PORT = 50085, LISTENER_IP = ALL)
	FOR DATA_MIRRORING (ROLE = PARTNER, AUTHENTICATION = WINDOWS NTLM
, ENCRYPTION = SUPPORTED ALGORITHM RC4)
GO

3.	Grant permission 
GRANT CONNECT ON ENDPOINT::[Mirroring_Endpoint] TO [NTADMIN\SRVC_SQL_IBGCF_PRD]

