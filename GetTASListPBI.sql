SELECT      *
FROM  OPENQUERY (R7DBARPT,'
SELECT 
SUBSTR(TAS.TASK_ID,1,15) "TAS"
,SUBSTR(TAS.TASKNAME,1,100) "TASName"
,DECODE(TAS.STATUS ,1000,''Staged'' ,2000,''Assigned'' ,3000,''Pending'' ,4000,''In Progress'' ,5000,''Waiting'' ,6000,''Closed'' ,7000,''Bypassed'' ,TAS.STATUS) "TASStatus"
,SUBSTR(TAS.ASSIGNEE,1,20) "TASAssignedTo"
,SUBSTR(TAS.ASSIGNEE_GROUP,1,100) "TASAssignedGroups"
FROM ARADMIN.TMS_TASK TAS
INNER JOIN ARADMIN.PBM_PROBLEM_INVESTIGATION PBI ON TAS.ROOTREQUESTID=PBI.PROBLEM_INVESTIGATION_ID 
WHERE PBI.PROBLEM_INVESTIGATION_ID=''PBI000000040450''
AND DECODE(TAS.STATUS ,1000,''Staged'' ,2000,''Assigned'' ,3000,''Pending'' ,4000,''In Progress'' ,5000,''Waiting'' ,6000,''Closed'' ,7000,''Bypassed'' ,TAS.STATUS)!=''Closed''
ORDER BY TAS.STATUS
')



