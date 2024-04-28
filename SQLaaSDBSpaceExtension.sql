

create table #temp_spacesummary
(
   timetaken datetime,
   businessunit varchar(6),
   subgroup varchar(6),
   environment char(1),
   envtname varchar(10),
   dbaowned char(1),
   hostname varchar(20),
   sqlserverport varchar(100),
   servername varchar(50),
   dbname varchar(100),
   logallocated int,
   currentsize decimal(15,2),
   freespace int,
   pctused dec(15,3),
   weeklygrowth decimal(15,2),
   daysleft int,
   diskfree decimal(15,2),
   fgname varchar(50),
   fgsize int,
   fgused int,
   maxgrowth int,
   maxsize int
)

   
insert into #temp_spacesummary
exec DBOperations..usp_rpt_SpaceSummarySaaS 3,90

select timetaken 'Sample Date'
      ,sqlserverport 'SQL Instance'
      ,dbname as 'Database Name'
      ,currentsize as 'Current Datafile Size'
      ,weeklygrowth as 'Weekly Growth (MB)'
      ,pctused as 'Pct Used'
      ,daysleft as 'Days Left'
      ,convert(dec(15,2),(weeklygrowth * round((90.0/7.0),0))) as 'Amount Added (9 wks)'
      ,currentsize + convert(dec(15,2),(weeklygrowth * round((90.0/7.0),0)) )as 'New Datafile Size'
      ,convert(dec(15,3),fgused/(currentsize + convert(dec(15,2),(weeklygrowth * round((90.0/7.0),0)) ))) as 'New Pct Used'
from #temp_spacesummary
--where dbname not in (select name from sys.databases where database_id < 6)
order by sqlserverport

drop table #temp_spacesummary
--exec DBOperations..usp_rpt_SpaceSummarySaaS

/*


select ((0.1*40.69)-(40.69-39.63))/0.89

3.34

select 40.69 + 3.38 = 44.07


*/