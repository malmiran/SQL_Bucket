
select @@servername[instance], GETDATE()[date]
--Check Service Account used for SQL (account that should be associated with SPN)
DECLARE @engineaccount VARCHAR(100)

EXECUTE master.dbo.xp_instance_regread 
N'HKEY_LOCAL_MACHINE',
N'SYSTEM\CurrentControlSet\Services\MSSQLSERVER',
N'ObjectName',
@engineaccount OUTPUT,
N'no_output'

SELECT @engineaccount as SQLServer_ServiceAccount

--Check if KERBEROS is working
select @@servername, auth_scheme, local_tcp_port from sys.dm_exec_connections
where session_id = @@spid

--Check if there is Mirroring endpoint that could be using SPN with different port from SQL server port
--SELECT @@SERVERNAME, name, posqlrt, protocol_desc, state_desc from sys.tcp_endpoints

--Use SSPIClient.exe to check if MSSQLSvc of instance has duplicate SPN system account objects in AD

