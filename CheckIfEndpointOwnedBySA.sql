select @@SERVERNAME[sql_instance], t1.name[endpoint_name], t2.name[endpoint_owner]
from sys.database_mirroring_endpoints t1
inner join sys.server_principals t2 on t1.principal_id = t2.principal_id
where t1.principal_id <> 1


