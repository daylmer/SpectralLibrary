	SELECT sc.id
	FROM conditioncategory scc 
	INNER JOIN condition sc on sc.conditioncategoryid = scc.id
	INNER JOIN datasetcondition sdsc on sdsc.conditionid = sc.id
	WHERE scc.title = 'Experiment' and sc.title = 'AB'


	SELECT dsc.id
	FROM condition c
	INNER JOIN conditioncategory cc on c.conditioncategoryid = cc.id and cc.title = 'Experiment'
	INNER JOIN datasetcondition dsc on dsc.conditionid = c.id
	WHERE c.title = 'AB'
	
	
	
	
	select * from fragmentfile
	select * from dataset

	select top 2 * from fragmentfile where processeddate is null



SELECT id, precursormz, precursorintensity, precursorrettime, precursormobility, productmz, productintensity, productrettime, productmobility, *
FROM fragmentfile where id in (2889099, 2889100, 2889101)
--2889000 

--288999


select top 3 * from mspeak order by id desc

--3274675

--3275373 - 3274675  698

select * from fragment file where id 

select id, precursormz, precursorintensity, precursorrettime, precursormobility, productmz, productintensity, productrettime, productmobility, * from fragmentfile where processeddate > '2016-09-01 10:37:35.000' --id >= 2887999 and id < 2889100 and 


2889001

select id, precursormz, precursorintensity, precursorrettime, precursormobility, productmz, productintensity, productrettime, productmobility, * from fragmentfile where id = 2889000
select id, precursormz, precursorintensity, precursorrettime, precursormobility, productmz, productintensity, productrettime, productmobility, * from fragmentfile where id = 3274675

select id, precursormz, precursorintensity, precursorrettime, precursormobility, productmz, productintensity, productrettime, productmobility, * from fragmentfile 
where precursormz = 471.771500 and productmz = 510.256500

select * from fragmentfile where id = 2889001
select * from mspeak where id = 3274675

select * from mspeak where id >= 3275262 order by id

select max(id) from mspeak where id < 3274676
select max(id) from mspeakx where id < 2872776

select * from mspeakx where mspeak1id = 3275262

select * from mspeaksequence where mspeakid = 2889000
select max(id) from mspeaksequence where id < 2889001


select max(id) from fragmentfile with (nolock) where processeddate is not null --2889000
select max(id) from mspeak with (nolock) --3274675
select max(id) from mspeakx with (nolock) --2872278
select max(id) from mspeaksequence with (nolock) --3274675
select max(id) from sequence with (nolock) --346499
select max(id) from protein with (nolock) --4579

select * from mspeak with (nolock) where id in (3274674, 3274675, 3274676)

select max(id) from fragmentfile where processeddate is not null
select max(id) from mspeak
select max(id) from mspeakx 
select max(id) from mspeaksequence
select max(id) from sequence
select max(id) from protein

select top 100 * from fragmentfile where id > 2900000

UPDATE fragmentfile set processeddate = null where id >= 2889001 and processeddate is not null
DELETE from mspeak where id > 3274675
DBCC CHECKIDENT ('mspeak', RESEED, 3274675)
DELETE from mspeakx where id > 2872278
DBCC CHECKIDENT ('mspeakx', RESEED, 2872278)
DELETE from mspeaksequence where id > 3274675
DBCC CHECKIDENT ('mspeaksequence', RESEED, 3274675)


select * from mspeak where id in (3274675,3274676,3274677,3274678)
select max(id) from mspeakx

select * from sequence where id > 

select 
3275193

2889001

SELECT * 
FROM mspeak msp1
INNER JOIN mspeakx mspx on msp1.id = mspx.mspeak1id
INNER JOIN mspeak msp2 on msp2.id = mspx.mspeak2id
WHERE msp1.masscharge = '471.771500' and msp2.masscharge = '510.256500'

select max(id) from mspeak where id < 3275262

select * from mspeak where id >= 3274675 and id <= 3275373 ORDER BY id DESC --(113)