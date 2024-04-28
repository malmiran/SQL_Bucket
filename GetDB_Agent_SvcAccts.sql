DECLARE @engineaccount VARCHAR(100), @agentaccount VARCHAR(100)

EXECUTE master.dbo.xp_instance_regread 
N'HKEY_LOCAL_MACHINE',
N'SYSTEM\CurrentControlSet\Services\MSSQLSERVER',
N'ObjectName',
@engineaccount OUTPUT,
N'no_output'

EXECUTE master.dbo.xp_instance_regread 
N'HKEY_LOCAL_MACHINE',
N'SYSTEM\CurrentControlSet\Services\SQLSERVERAGENT',
N'ObjectName',
@agentaccount OUTPUT,
N'no_output'

SELECT @engineaccount as SQLServer_ServiceAccount,
       @agentaccount AS SQLAgent_ServiceAccount

