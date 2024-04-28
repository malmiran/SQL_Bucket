
--Check status of Publication, Publisher, Subscriber
use distribution
go

declare @publisher varchar(50)
set @publisher = @@servername

exec sp_replmonitorhelppublisher @publisher
exec sp_replmonitorhelppublication @publisher
exec sp_replmonitorhelpsubscription @publisher,@publication_type = 0
go

--Check number of pending commands
use distribution
go
sp_Helpdb static_data

declare @publisher varchar(50)
set @publisher = @@servername

select @@servername [sql_intance], getdate()[current_date]

exec sp_replmonitorsubscriptionpendingcmds
 @publisher = @publisher
,@subscriber = 'NTHKGDBP108\MIBGPRD02'
,@publication = 'connect'
,@publisher_db = 'static_data'
,@subscriber_db = 'connect'
,@subscription_type = 0


/*
STATUS Reference:
1 = Started
2 = Succeeded
3 = In progress
4 = Idle
5 = Retrying
6 = Failed
*/

NTHKGDBP108\MIBGPRD02
--Check error
select top 10000 getdate()[current_time], time, error_text, xact_seqno from distribution..msrepl_errors order by 2 desc

--current_time	time
2011-03-19 01:13:41.533	2011-03-19 01:11:01.823

select *
from distribution..msrepl_errors order by 2 desc

Invalid column name 'isSendProcessed'.

--Check command/transaction that failed
exec distribution..sp_browsereplcmds '0x0000058800005DAA007600000001'

The DELETE statement conflicted with the REFERENCE constraint "FK_PublicationSecurity_Security". The conflict occurred in database "research_library", table "dbo.rl_PublicationSecurity", column 'security_id'.

0x000004630002B0BD001400000000 --market_Data
0x000004630002B0EA000F00000000 --research_library

sp_helpsubscriptionerrors 'NTSYDDBP160\MMSGPRD01'
        ,  'static_data' 
        , 'market_data' 
        ,  'NTSYDDBP160\MMSGPRD01' 
        ,  'market_data'

sp_setsubscriptionxactseqno 'NTSYDDBP160\MMSGPRD01','static_data','market_data','0x000004630002B0BD001400000000'

/*

{CALL [sp_MSupd_dbosd_Disclosure] (,,,,'',,,'','',,,,2011-11-27 22:54:53.767,'NTADMIN\RSimon',740,0x9031)}

WORKSPACE:
The subscription(s) have been marked inactive and must be reinitialized. NoSync subscriptions will need to be dropped and recreated.
The row was not found at the Subscriber when applying the replicated command.
{CALL [sp_MSdel_dboalertPreference] ({D7D9E451-BFFD-4D01-BD10-24A0ECF3209A})}
{CALL [sp_MSdel_dboalertPreference] ({D7D9E451-BFFD-4D01-BD10-24A0ECF3209A})}
{CALL [sp_MSins_dboauditHistory] ({F3264BDF-75B3-452B-8FA0-2B4FBF6D559C},{75E29B32-4220-45C1-A437-00BE9932562A},2011-03-18 14:47:02.000,N'EventMeeting',N'1a01e557-13d8-4914-be8c-bf6a7be01a7f',{1A01E557-13D8-4914-BE8C-BF6A7BE01A7F},N'',NULL,N'Bernie Frojmovich',N'clientAttendees')}

NTSYDDBU153\MMSGUAT03

NTSYDDBP160\MMSGPRD01
NTADMIN\SRVC_caad

use connect
go
sp_help alertPreference


*/


select * from sys.tables
where name like '%history%'


select top 1000 * from MSdistribution_history
order by time desc

use connect
go
select count(*) from alertPreference
--15062

select * from alertPreference
where alertPreferenceId = 'D7D9E451-BFFD-4D01-BD10-24A0ECF3209A'


select @@trancount

sp_help alertPreference

use distribution
go

select * from dbo.MSarticles where article_id in ( select article_id from MSrepl_commands where xact_seqno = 0x00000A9200016000000900000000)

And this will give you the command (and the primary key (ie the row) the command was executing against)

exec sp_browsereplcmds @xact_seqno_start = '0x00000A9200016000000900000000', @xact_seqno_end = '0x0003BB0E000001DF000600000000'

{CALL [sp_MSdel_dboalertPreference] ({D7D9E451-BFFD-4D01-BD10-24A0ECF3209A})}

select * from dbo.MSarticles

where article_id IN (SELECT Article_id from MSrepl_commands

where xact_seqno = 0x00000A9200016000000900000000)



exec sp_browsereplcmds @xact_seqno_start = '0x00000A9200016000000900000000' 
,@xact_seqno_end = '0x00000A9200016000000900000000'
,@publisher_database_id = 1
,@article_id = 10
,@command_id= '1'

