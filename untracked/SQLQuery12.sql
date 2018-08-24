-- Ensure DimScore is contiguous and contains all values

select * from DimScore
select max(score) from mspeaksequence

select id, label, minrange, maxrange, (select minrange from DimScore where id = dir.id + 1)
FROM DimScore dir
where dir.id > 0 and dir.id < (select max(id) from DimScore)

UPDATE DimScore
SET maxrange = ISNULL((select minrange from DimScore where id = ds.id + 1), (select max(score) from mspeaksequence) + 1)
FROM DimScore ds
where ds.id > 2 --and drtr.id < (select max(id) from DimScore)
select * from DimScore

UPDATE DimScore set maxrange = 10, LABEL = '9 to 10' where id = 11
INSERT INTO DimScore (label, minrange, maxrange) VALUES ('10 to 11', 10, 11)
UPDATE DimScore set maxrange = 0 where id = 2

UPDATE DimScore 
set label = cast(cast(minrange as bigint) as nvarchar(12)) + N' to ' + cast(cast(maxrange as bigint) - 1 as nvarchar(12))
FROM DimScore dir
where dir.id > 2

select top 10 id, label, minrange, maxrange, (select minrange from DimScore where id = dir.id + 1)
from DimScore dir
where id is null or label is null or minrange is null or maxrange is null 





--Ensure DimIntensityAbs is contiguous

select * from DimIntensityAbs
select max(intensity) from mspeak

select id, label, minrange, maxrange, (select minrange from DimIntensityAbs where id = dir.id + 1)
FROM DimIntensityAbs dir
where dir.id > 2 and dir.id < (select max(id) from DimIntensityAbs)

select * from DimIntensityAbs
UPDATE DimIntensityAbs
SET maxrange = ISNULL((select minrange from DimIntensityAbs where id = dir.id + 1), (select max(intensity) from mspeak) + 1)
FROM DimIntensityAbs dir
where dir.id > 2 --and drtr.id < (select max(id) from DimIntensityAbs)
select * from DimIntensityAbs

UPDATE DimIntensityAbs set maxrange = 1200, LABEL = '0 TO 1200' where id = 2
UPDATE DimIntensityAbs set maxrange = 0 where id = 2

UPDATE DimIntensityAbs 
set label = cast(cast(minrange as bigint) as nvarchar(12)) + N' to ' + cast(cast(maxrange as bigint) - 1 as nvarchar(12))
FROM DimIntensityAbs dir
where dir.id > 2

select top 10 id, label, minrange, maxrange, (select minrange from DimIntensityAbs where id = dir.id + 1)
from DimIntensityAbs dir
where id is null or label is null or minrange is null or maxrange is null 




--Ensure DimRetentionTimeRel is contiguous

select * from DimRetentionTimeRel
select max(retentiontime) * 60 from mspeak

select id, label, minrange, maxrange, (select minrange from DimRetentionTimeRel where id = drtr.id + 1)
FROM DimRetentionTimeRel drtr
where drtr.id > 2 and drtr.id < (select max(id) from DimRetentionTimeRel)

select * from DimRetentionTimeRel
UPDATE DimRetentionTimeRel
SET maxrange = ISNULL((select minrange from DimRetentionTimeRel where id = drtr.id + 1), (select max(retentiontime) * 60 from mspeak) + 1)
FROM DimRetentionTimeRel drtr
where drtr.id > 2 --and drtr.id < (select max(id) from DimRetentionTimeRel)
select * from DimRetentionTimeRel

UPDATE DimRetentionTimeRel set maxrange = 1200, LABEL = '0 TO 1200' where id = 2
UPDATE DimRetentionTimeRel set maxrange = 0 where id = 2

UPDATE DimRetentionTimeRel 
set label = cast(cast(minrange as int) as nvarchar(12)) + N' to ' + cast(cast(maxrange as int) - 1 as nvarchar(12))
FROM DimRetentionTimeRel drtr
where drtr.id > 2

select top 10 id, label, minrange, maxrange, (select minrange from DimRetentionTimeRel where id = drtr.id + 1)
from DimRetentionTimeRel drtr
where id is null or label is null or minrange is null or maxrange is null 





-- Ensure DimDriftTimeRel is contiguous
select top 10 * from DimDriftTimeRel

select id, label, minrange, maxrange, (select minrange from DimDriftTimeRel where id = ddtr.id + 1)
FROM DimDriftTimeRel ddtr
where ddtr.id > 2 and ddtr.id < (select max(id) from DimDriftTimeRel)

UPDATE DimDriftTimeRel
SET maxrange = (select minrange from DimDriftTimeRel where id = ddtr.id + 1)
FROM DimDriftTimeRel ddtr
where ddtr.id > 2 and ddtr.id < (select max(id) from DimDriftTimeRel)

SELECT id, label, cast(cast(minrange as int) as nvarchar(12)) + N' to ' + cast(cast(maxrange as int) - 1 as nvarchar(12)), minrange, maxrange
FROM DimDriftTimeRel ddtr

UPDATE DimDriftTimeRel set maxrange = 2205.000000, label = '0 to 2205' where id = 2

UPDATE DimDriftTimeRel 
set label = cast(cast(minrange as int) as nvarchar(12)) + N' to ' + cast(cast(maxrange as int) - 1 as nvarchar(12))
FROM DimDriftTimeRel ddtr
where ddtr.id > 2






select top 10 id, label, minrange, maxrange, (select minrange from DimIntensityRel where id = dir.id + 1)
from DimIntensityRel dir

where id is null or label is null or minrange is null or maxrange is null 

update DimIntensityRel set maxrange = 3536750.00 where id = 3001
3536745
select max(intensity) from mspeak

select * from DimIntensityRel where id > 2999



select * from DimTechReplicate
*/
SELECT 
d.id, ISNULL((SELECT count(*) FROM DimExperiment where label = (
	SELECT sc.description
	FROM conditioncategory scc 
	INNER JOIN condition sc on sc.conditioncategoryid = scc.id
	INNER JOIN datasetcondition sdsc on sdsc.conditionid = sc.id
	WHERE sdsc.datasetid = d.id and scc.title = 'Experiment')
), 1) ExperimentID

FROM dataset d

WHERE 
(SELECT count(*) FROM DimExperiment where label = (
	SELECT sc.description
	FROM conditioncategory scc 
	INNER JOIN condition sc on sc.conditioncategoryid = scc.id
	INNER JOIN datasetcondition sdsc on sdsc.conditionid = sc.id
	WHERE sdsc.datasetid = d.id and scc.title = 'Experiment')
) <> 1


INSERT INTO DimExperiment (label)
	SELECT DISTINCT c.description
	FROM conditioncategory cc 
	INNER JOIN condition c on c.conditioncategoryid = cc.id
	INNER JOIN datasetcondition dsc on dsc.conditionid = c.id
	INNER JOIN dataset ds on ds.id = dsc.datasetid
	WHERE cc.title = 'Experiment'
select * from DimExperiment


select * from dataset
select * from condition

SELECT *
FROM conditioncategory scc 
LEFT JOIN condition sc on sc.conditioncategoryid = scc.id
LEFT JOIN datasetcondition sdsc on sdsc.conditionid = sc.id
order by sdsc.id

select * from conditioncategory
select * from datasetcondition



	SELECT c.id, *
	FROM condition c
	INNER JOIN conditioncategory cc on c.conditioncategoryid = cc.id and cc.title ='Experiment'
	WHERE c.title = 'AB'

INSERT INTO datasetcondition
	SELECT id, 19
	FROM dataset
	WHERE id = 1

WHERE d.id = 4





select * from DimExperiment

select * from conditioncategory


from mspeak msp
LEFT JOIN dataset d on msp.datasetid = d.id
LEFT JOIN mspeaktype mspt on msp.mspeaktypeid = mspt.id
LEFT JOIN mspeaksequence msps on msp.id = msps.mspeakid
LEFT JOIN sequencematchtype smt on msps.sequencematchtype = smt.id
LEFT JOIN sequence s on msps.sequenceid = s.id
LEFT JOIN protein p on p.id = msps.proteinid
