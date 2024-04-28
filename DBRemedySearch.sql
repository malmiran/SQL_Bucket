
use DBRemedy
go

select INC, Impact, Summary, DateReported, DateModified, AssignedTo, Notes
from DBRemedy..incinfo
where assignedgroup = 'DBA Operations-Global'
and datereported >= '2012-01-01'
and summary like '%RC491058%'
and ProdCat3 = 'SQL Server'

select INC, Impact, Summary, DateReported, DateModified, AssignedTo, Notes, Status, AssignedGroup,
       ProdCat1, ProdCat2, ProdCat3, ProdName, OpCat1, OpCat2, OpCat3
from DBRemedy..incinfo
where datereported >= '2013-01-01'
and summary like '%LOGICAL DISK%'
order by DateModified desc

select top 100 * from DBRemedy..incinfo
where assignedgroup = 'DBA Operations-Global'

select INC, Summary, AssignedGroup, AssignedTo, ProdCat1, ProdCat2, ProdCat3, ProdName, OpCat1, OpCat2, OpCat3
from DBRemedy..incinfo
where datereported >= '2012-01-01'
and assignedgroup = 'DBA Operations-Global'
and ProdCat3 = 'Oracle'
and OpCat1 = 'Access Management'
and OpCat2 = 'Create/Add'

and summary like '%staff dep%'                                               
