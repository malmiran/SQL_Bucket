USE [FIDataMart_uat1]
GO
ALTER AUTHORIZATION ON SCHEMA::[mfic] TO [mfic_role]
GO

use FIDataMart_uat1;
go
select @@servername[server], db_name()[db]
go
select pr.name, pm.permission_name
from sys.database_permissions pm
inner join sys.database_principals pr
 on pm.grantee_principal_id = pr.principal_id
where pr.name = 'mfic_role'
