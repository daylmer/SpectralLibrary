

use protein

/*

select aa.label, aa.monoisotopicmass, s.sequence, cast(msp.retentiontime as int), count(*) -- top 50 s.sequence, count(s.sequence) incidence, min(msp.masscharge) 'min', avg(msp.masscharge) 'avg', max(msp.masscharge) 'max'
from mspeak msp
LEFT JOIN dataset d on msp.datasetid = d.id
LEFT JOIN mspeaktype mspt on msp.mspeaktypeid = mspt.id
LEFT JOIN mspeaksequence msps on msp.id = msps.mspeakid
LEFT JOIN sequencematchtype smt on msps.sequencematchtype = smt.id
LEFT JOIN sequence s on msps.sequenceid = s.id
LEFT JOIN protein p on p.id = msps.proteinid
LEFT JOIN aamass aa on s.sequence = aa.lettercode
WHERE len(s.sequence) = 1 -- = 'AA'
GROUP BY  aa.label, aa.monoisotopicmass, s.sequence, cast(msp.retentiontime as int)
ORDER BY s.sequence, cast(msp.retentiontime as int) DESC

GROUP BY s.sequence
HAVING count(s.sequence) > 5 
ORDER BY count(s.sequence) DESC

--SELECT max(id) from mspeak

select count(*) from fragmentfile where processeddate is null
*/

/*
SELECT top 500 p1.masscharge, p2.masscharge, p1.*, p2.*
FROM mspeak p1 with (nolock) 
LEFT JOIN mspeakx x with (nolock) on p1.mspeaktypeid = 1 and p1.id = x.mspeak1id
LEFT JOIN mspeak p2 with (nolock) on x.mspeak2id = p2.id 
WHERE p2.id = (SELECT max(id) from mspeak)
ORDER BY p1.id DESC
*/

-- Orphaned peaks

--24024 24043
select f.id, peak1.*
-- peak1.*, f.*, peak2.*
 --, f.id, f.processeddate
/*
f.id, 
case when x1.id is null and x2.id is null then 'Orphaned record' ELSE 'OK' end 'condition',
x1.id, p2.id, x2.id,
f.*, p2.*, p.*  
*/
from 
mspeak peak1 with (nolock)
LEFT JOIN mspeakx x1  with (nolock) on peak1.id = x1.mspeak1id and peak1.mspeaktypeid = 1
LEFT JOIN mspeakx x2  with (nolock) on peak1.id = x2.mspeak2id and peak1.mspeaktypeid = 2
--LEFT JOIN mspeak peak2  with (nolock) on x1.mspeak2id = peak2.id
LEFT JOIN fragmentfile f  with (nolock) on peak1.datasetid = f.datasetid 
and (
	peak1.masscharge = f.productmz and peak1.intensity = f.productintensity and peak1.retentiontime = f.productrettime and peak1.drifttime = f.productmobility 
	--OR
	--peak1.masscharge = f.precursormz and peak1.intensity = f.precursorintensity and peak1.retentiontime = f.precursorrettime and peak1.drifttime = f.precursormobility
)
where x1.id is null and x2.id is null 

--order by peak1.id
/*
and
(
	p.id > 306209 -1 and p.id < 306209 + 1 or
	p.id > 3175590 -1 and p.id < 3175590 + 1 or
	p.id > 1206844 -1 and p.id < 1206844 + 1 or
	p.id > 3215333 -1 and p.id < 3215333 + 1 or
	p.id > 3225463 -1 and p.id < 3225463 + 1 or
	p.id > 2997289 -1 and p.id < 2997289 + 1 or
	p.id > 1110682 -1 and p.id < 1110682 + 1 
)
*/

--f.id > 124001 - 10 and f.id < 124001 + 10
--order by f.id --p.id, processeddate

/*
SELECT top 500000 p1.masscharge, p2.masscharge, p1.*, p2.*
FROM mspeak p1 with (nolock) 
LEFT JOIN mspeakx x with (nolock) on p1.mspeaktypeid = 1 and p1.id = x.mspeak1id
LEFT JOIN mspeak p2 with (nolock) on x.mspeak2id = p2.id 
WHERE p1.mspeaktypeid = 1 and x.mspeak1id is null
ORDER BY p1.id DESC

-- 2995941

SELECT top 500 p1.masscharge, p2.masscharge, p1.*, p2.*
FROM mspeak p1 with (nolock) 
INNER JOIN mspeakx x with (nolock) on p1.mspeaktypeid = 1 and p1.id = x.mspeak1id
LEFT JOIN mspeak p2 with (nolock) on x.mspeak2id = p2.id 
ORDER BY p1.id DESC

-- 2995939

select precursormz, productmz, processeddate, * FROM 
(select top 2 * from fragmentfile with (nolock) WHERE processeddate is not null order by id DESC) a UNION
select precursormz, productmz, processeddate, * FROM (select top 2 * from fragmentfile with (nolock) WHERE processeddate is null order by id ASC) b
order by id

-- 2485632
-- 2485633
-- 2485634
-- 2485635

*/
/*
	UPDATE fragmentfile
	SET processeddate = null
	WHERE datasetid = 4
*/

/*

	select count(*) from fragmentfile


	select d.id, d.filename, d.loaddate, count(f.id) 'fragment incidence'
	from dataset d with (nolock)
	LEFT JOIN fragmentfile f with (nolock) on f.datasetid = d.id
	GROUP by d.id, d.filename, d.loaddate
	order by d.id

	delete from fragmentfile where datasetid IN (43,44)
delete from dataset where id IN (43,44)
*/


--select top 5 * from fragmentfile where processeddate is null 

/*

select * from dataset





	SELECT * FROM [dbo].[aamass]

	SELECT * FROM [dbo].[mspeak]

	SELECT * FROM [dbo].[mspeakmatchtype]

	SELECT * FROM [dbo].[mspeaksequence]

	SELECT * FROM [dbo].[mspeaktype]

	SELECT * FROM [dbo].[mspeakx]

	SELECT * FROM [dbo].[protein]

	SELECT * FROM [dbo].[sequence]

	SELECT * FROM [dbo].[sequencematchtype]

*/

/*
		SELECT max(id) from mspeak

		SELECT top 20 p1.*, p2.*
		FROM mspeak p1 with (nolock) 
		INNER JOIN mspeakx x with (nolock) on p1.mspeaktypeid = 1 and p1.id = x.mspeak1id
		LEFT JOIN mspeak p2 with (nolock) on x.mspeak2id = p2.id 
		ORDER BY p1.id DESC

		select * FROM 
		(select top 2 * from fragmentfile with (nolock) WHERE processeddate is not null order by id DESC) a UNION
		select * FROM (select top 2 * from fragmentfile with (nolock) WHERE processeddate is null order by id ASC) b
		order by id




	SELECT p1.*, p2.*
	FROM mspeak p1 with (nolock) 
	LEFT JOIN mspeakx x with (nolock) on p1.id = x.mspeak1id
	LEFT JOIN mspeak p2 with (nolock) on x.mspeak2id = p2.id 
	WHERE p2.id > 306208

	select * from fragmentfile with (nolock) where id> 124000 and processeddate is not null

	select top 100 * from mspeak order by id desc

*/


-- update fragmentfile set processeddate = getdate() where id = 124001


/*
	SELECT distinct masscharge
	FROM mspeak with (nolock)


	-- Actual query
	SELECT masscharge, count(masscharge) Frequency
	FROM mspeak with (nolock)
	GROUP BY masscharge

	--Remember to order the list
	ORDER BY masscharge ASC

	-- Get the weighting normalisation
	select max(Frequency) MaxFrequency FROM (
		SELECT masscharge, count(masscharge) Frequency
		FROM mspeak with (nolock)
		GROUP BY masscharge
		--ORDER BY masscharge ASC
	) MassChargeFrequency
	WHERE MassChargeFrequency.masscharge <> 0

	-- Get the count
	SELECT count(*) FROM (
		SELECT masscharge, count(masscharge) Frequency
		FROM mspeak with (nolock)
		GROUP BY masscharge
	) querycount
*/

-- select top 5 * from vSpectra

-- seeing how good 


-- As double
-- 1955973	70.027100	1999.069100	1	4244	5

-- As int

select count(imasscharge) 'Unique masscharge', min(imasscharge), max(imasscharge), min(Frequency), max(Frequency), avg(Frequency) FROM
(
	SELECT cast(masscharge as int) as masscharge, count(masscharge) Frequency
	FROM mspeak
	WHERE masscharge <> 0
	GROUP BY cast(masscharge as int)
) mc
	
	
	--HAVING count(masscharge)

select count(*), max(masscharge), max(retentiontime), max(drifttime), max(intensity)--, avg(intensity)--, count(intensity)
FROM mspeak

	SELECT cast(retentiontime as int) as retentiontime, count(retentiontime) Frequency
	FROM mspeak
	GROUP BY cast(retentiontime as int)

	SELECT cast(round(retentiontime*60.0,2) as numeric(12,2)) as retentiontime, count(retentiontime) Frequency
	FROM mspeak msp
	INNER JOIN mspeaksequence msps on msps.mspeakid = msp.id
	WHERE msps.id IN (
		select ss.id
		from sequence ss
		INNER JOIN mspeaksequence smsps on ss.id = smsps.sequenceid
		GROUP BY ss.id
		HAVING count(ss.sequence) > 60 -- 61 and above ensures top 5% of occuring peptides/fragments
	)
	GROUP BY cast(round(retentiontime*60.0,2) as numeric(12,2))
	ORDER BY cast(round(retentiontime*60.0,2) as numeric(12,2)) DESC
	ORDER BY  count(retentiontime) DESC


select	cast(round(34*60.0,2) as numeric(12,2))

-- Of all peptides/fragments in dataset
-- Minimum rentention time is 20.008500 minutes (1200.51s,  msp.id = 9755846, 9756520, 9756718) with sequence 'EKTED'
-- Throughout all datasets, EKTED is discovered 9 times which puts it into the top 23% of frequently occuring fragments
-- Rention times range from 20.008500 to 20.566600 minutes  (1200.51 to 1233.996 seconds)

-- Maximum retention time is 104.847000 (6290.82s, msp.id = 8849881, 8849309) with sequence LLDENDDLWVELR
-- Throughout all datasets, LLDENDDLWVELR is discovered 6 times which puts it into the top 29% of frequently occuring fragments
-- rentiontime ranging from 95.582400 to 104.847000  (5734.944 to 6290.82 seconds)

-- Of frequently occuring peptides/fragments
-- Minimum rentention time is 20.082000 minutes (1204.92,  msp.ids 42) with sequence 'GSQQYR'
-- Throughout all datasets, GSQQYR is discovered 390 times which puts it into the top 99.6% of frequently occuring fragments
-- Rention times range from 20.043400 to 92.727900 minutes  (1202.604 to 5563.674 seconds)

-- Maximum retention time is 101.547200 (6092.83s, msp.ids 4) with sequence LRAAE
-- Throughout all datasets, LRAAE is discovered 6 times which puts it into the top 29% of frequently occuring fragments
-- rentiontime ranging from 95.582400 to 92.727900  (5734.944 to 6290.82 seconds)

SELECT min(retentiontime), max(retentiontime), avg(retentiontime), count(retentiontime)
--SELECT * 
FROM mspeak msp
INNER JOIN mspeaksequence msps on msps.mspeakid = msp.id
INNER JOIN sequence s on msps.sequenceid = s.id
LEFT JOIN mspeakx x1 on x1.mspeak1id = msp.id
LEFT JOIN mspeakx x2 on x2.mspeak2id = msp.id
-- where cast(round(msp.retentiontime*60.0,2) as numeric(12,2)) = 6092.83 -- 1204.92 --6290.82 -- 1200.51 --1506.38 -- 4149.31
where s.sequence = 'LRAAE'
order by mspeaktypeid, datasetid

--select top 100 * from mspeakx

-- 
select s.sequence, count(s.sequence)
from sequence s
INNER JOIN mspeaksequence msps on s.id = msps.sequenceid
GROUP BY s.sequence
HAVING count(s.sequence) > 60
ORDER BY count(s.sequence) DESC



SELECT cast(round(retentiontime*60.0,2) as numeric(12,2)) as retentiontime, count(retentiontime) Frequency
FROM mspeak msp
INNER JOIN mspeaksequence msps on msps.mspeakid = msp.id
WHERE msps.id IN (
	select ss.id
	from sequence ss
	INNER JOIN mspeaksequence smsps on ss.id = smsps.sequenceid
	where ss.sequence = 'LRAAE'
	GROUP BY ss.id
	HAVING count(ss.id) > 60 -- 61 and above ensures top 5% of occuring peptides/fragments
)
GROUP BY cast(round(retentiontime*60.0,2) as numeric(12,2))
ORDER BY cast(round(retentiontime*60.0,2) as numeric(12,2)) DESC


select count(*) 
from sequence ss
INNER JOIN mspeaksequence smsps on ss.id = smsps.sequenceid
where ss.sequence = 'LRAAE'

select datasetid, min(retentiontime), max(retentiontime), avg(retentiontime), count(retentiontime)
FROM mspeak
where retentiontime <> 0
group by datasetid


	SELECT cast(masscharge as int) as masscharge, count(masscharge) Frequency
	FROM mspeak
	GROUP BY cast(masscharge as int)

select count(*) from (
SELECT cast(masscharge * 100 as int) / 100 as masscharge, count(masscharge) Frequency
FROM mspeak
GROUP BY cast(masscharge * 100 as int)
) a

SELECT *
FROM mspeak
where cast(masscharge * 100 as int) / 100 = 923

select count(*) from (
SELECT cast(masscharge as int) as masscharge, count(masscharge) Frequency
FROM mspeak
GROUP BY cast(masscharge as int)
) a

select count(*) from (
SELECT cast(retentiontime*60 as int) as retentiontime, count(retentiontime) Frequency
FROM mspeak
GROUP BY  cast(retentiontime*60 as int)
) a
select count(*) from (
SELECT cast(drifttime*60 as int) as drifttime, count(drifttime) Frequency
FROM mspeak
GROUP BY  cast(drifttime*60 as int)
) a
select count(*) from (
SELECT cast(intensity/10 as bigint)*10 as intensity, count(intensity) Frequency
FROM mspeak
GROUP BY cast(intensity/10 as bigint)
--order by cast(intensity/10 as bigint)
) a



SELECT cast(round(retentiontime*60.0,2) as numeric(12,2)) as retentiontime, count(masscharge) Frequency
FROM mspeak
GROUP BY cast(round(retentiontime*60.0,2) as numeric(12,2))






SELECT cast(intensity/10 as bigint)*10 as intensity, count(intensity) Frequency
--SELECT cast(intensity as bigint) as intensity, count(intensity) Frequency

--SELECT top 5000 EXP(cast(log(intensity) as int)) intensity, count(intensity) Frequency
FROM mspeak
--where intensity <> 0
--GROUP BY EXP(cast(log(intensity) as int))
--order by EXP(cast(log(intensity) as int))
--GROUP BY  cast(intensity as bigint)
--order by cast(intensity as bigint)
GROUP BY cast(intensity/10 as bigint)
order by cast(intensity/10 as bigint)





	SELECT s.sequence, min(retentiontime) * 60, avg(retentiontime) * 60, max(retentiontime) * 60, count(*) --cast(retentiontime*60 as int) as retentiontime, count(retentiontime) Frequency
	FROM mspeak msp with (nolock)
	LEFT JOIN mspeaksequence msps with (nolock) on msp.id = msps.mspeakid
	LEFT JOIN sequence s with (nolock) on msps.sequenceid = s.id
	GROUP BY s.sequence --cast(retentiontime*60 as int)
	ORDER BY len(s.sequence), s.sequence --retentiontime

