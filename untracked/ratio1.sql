/*

select distinct datasetid, peptidesequence, fragmentsequence--, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
,count(*)
FROM (
	select distinct datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
	FROM fragmentfile
) ff
GROUP BY datasetid, peptidesequence, fragmentsequence --, precursorintensity, productintensity
HAVING count(*) > 2

-- bad data
-- datasetid	peptidesequence			fragmentsequence	incidence
-- 1			NTVVDDSQTAYQDAFDISK		NTVV				3
-- 1			NTVVDDSQTAYQDAFDISK		NTVVDD				3


--64625

select frequency, count(*) FROM (
select distinct datasetid, peptidesequence, fragmentsequence--, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
,count(*) frequency
FROM (
	select distinct datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
	FROM fragmentfile
	--WHERE datasetid = 1 AND peptidesequence = 'NTVVDDSQTAYQDAFDISK' AND fragmentsequence = 'NTVV' ORDER BY datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity
) ff
--WHERE datasetid = 1 AND peptidesequence = 'AAADLDVR' AND fragmentsequence = 'AA' --ORDER BY datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity
GROUP BY datasetid, peptidesequence, fragmentsequence --, precursorintensity, productintensity
--HAVING count(*) > 8
--ORDER BY count(*) DESC
--ORDER BY datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity
) th
group by frequency order by frequency desc


distinct	frequency
9			1
8			3
7			18
6			104
5			484
4			3629
3			60386
2			568108
1			3150857




select datasetid, peptidesequence, fragmentsequence, precursorintensity, count(*)
FROM fragmentfile
--WHERE peptidesequence = 'AMSIMNSFVNDIFER' AND fragmentsequence = 'NSFVNDIFER'
GROUP BY datasetid, peptidesequence, fragmentsequence ,precursorintensity
HAVING count(*) > 2
ORDER BY count(*) desc, datasetid, peptidesequence, fragmentsequence


datasetid	peptidesequence				fragmentsequence	precursorintensity	(No column name)
17			ASGNPMPEIIWIR				ASGNPM				2638	162
10			QISSDGKLVFPPFRAEDYR			QISSDGKLVFPPFRAEDYR	104249	159
17			YQVYATGFNNIGAGEASDILNTR		YQVYATGFNNIGAG		908		159
32			EDKGMYQCFVRNDQESAEASAELK	EASAELK				4412	118
32			GMYQCFVRNDQESAEASAELK		DQESAEASAELK		5850	118
32			GMYQCFVRNDQESAEASAELK		SAELK				5850	118


select datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
FROM fragmentfile
WHERE datasetid = 17 and peptidesequence = 'ASGNPMPEIIWIR' AND fragmentsequence = 'ASGNPM' and precursorintensity = 2638

-- What kind of tolerance to give?
-- .01 ?

-- by dataset (for now) peptideseq, fragmentseq, precursorintensity, productintensity, ratio 1, max, min, avg, weighted average... assign each to group based on tolaerance (0.01 for now), group set to average of all ratios within 2 x tolerance of all values in group.. bleh

-- create temp table... assign each ratio to a ratio group


select datasetid, count(*) FROM (
select distinct datasetid, peptidesequence, fragmentsequence--, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
,count(*) frequency
FROM (
	select distinct datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
	FROM fragmentfile
	--WHERE datasetid = 1 AND peptidesequence = 'NTVVDDSQTAYQDAFDISK' AND fragmentsequence = 'NTVV' ORDER BY datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity
) ff
--WHERE datasetid = 1 AND peptidesequence = 'AAADLDVR' AND fragmentsequence = 'AA' --ORDER BY datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity
GROUP BY datasetid, peptidesequence, fragmentsequence --, precursorintensity, productintensity
HAVING count(*) > 2
--ORDER BY count(*) DESC
--ORDER BY datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity
) th
group by datasetid order by count(*) desc

datasetid	frequency
32			3439
37			3369
28			3159
17			2701
25			2678
40			2647
13			2580
2			2519
10			2168
33			1931
36			1813
31			1775
18			1596
23			1565
16			1526
22			1477
39			1415
34			1300
3			1275
19			1256
27			1223
29			1204
8			1204
24			1188
38			1177
41			1168
1			1137
9			1117
7			1094
26			1093
14			1074
21			1050
4			1035
35			991
12			953
30			938
20			923
15			849
11			805
42			792
6			717
5			704



select distinct datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
--,count(*) frequency
FROM (
	select distinct datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
	FROM fragmentfile
	WHERE peptidesequence = 'AMSIMNSFVNDIFER' AND fragmentsequence = 'NSFVNDIFER'
) ff
ORDER BY datasetid, precursorintensity, productintensity

select distinct datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
--,count(*) frequency
FROM (
	select distinct datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
	FROM fragmentfile
	WHERE peptidesequence = 'AMSIMNSFVNDIFER' AND fragmentsequence = 'NSFVNDIFER'
) ff
GROUP BY datasetid
ORDER BY precursorintensity, productintensity


select datasetid, count(*) FROM (
select distinct datasetid, peptidesequence, fragmentsequence--, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
--,count(*) frequency
FROM (
	select distinct datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
	FROM fragmentfile
	--WHERE datasetid = 1 AND peptidesequence = 'AMSIMNSFVNDIFER' AND fragmentsequence = 'NSFVNDIFER' ORDER BY datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity
) ff
--WHERE datasetid = 1 AND peptidesequence = 'AMSIMNSFVNDIFER' AND fragmentsequence = 'NSFVNDIFER' --ORDER BY datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity
GROUP BY datasetid, peptidesequence, fragmentsequence --, precursorintensity, productintensity
HAVING count(*) > 2
--ORDER BY count(*) DESC
--ORDER BY datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity
) th
group by datasetid order by count(*) desc
 


select datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
FROM fragmentfile
WHERE datasetid = 17 and peptidesequence = 'ASGNPMPEIIWIR' AND fragmentsequence = 'ASGNPM' and precursorintensity = 2638
*/
-- What kind of tolerance to give?
-- .01 ?

-- how to find peptide/fragment groups with more than two groups?

SET NOCOUNT ON;

DECLARE @errormessage varchar(1024);


DECLARE @ratio1count bigint;
DECLARE @ratio1id bigint;
DECLARE @datasetid bigint;
DECLARE @peptidesequence varchar(128);
DECLARE @precursorintensity numeric(36,6);
DECLARE @fragmentsequence varchar(128);

DECLARE @ratio1 TABLE (
	ID bigint identity PRIMARY KEY,
	datasetid BIGINT not null,
	peptidesequence varchar(128) NOT NULL, -- UNIQUE NONCLUSTERED (peptidesequence, fragmentsequence),
	precursorintensity numeric(36,6) NOT NULL DEFAULT 0,
	fragmentsequence varchar(128) NOT NULL,

	--fragmentionmingroupcenter numeric(36,6) NOT NULL DEFAULT 0,
	fragmentionmingroupmin numeric(36,6) NOT NULL DEFAULT 0,
	fragmentionmingroupavg numeric(36,6) NOT NULL DEFAULT 0,
	fragmentionmingroupwavg numeric(36,6) NOT NULL DEFAULT 0,
	fragmentionmingroupmax numeric(36,6) NOT NULL DEFAULT 0,

	--fragmentionmaxgroup numeric(36,6) NOT NULL DEFAULT 0,
	fragmentionmaxgroupmin numeric(36,6) NOT NULL DEFAULT 0,
	fragmentionmaxgroupavg numeric(36,6) NOT NULL DEFAULT 0,
	fragmentionmaxgroupwavg numeric(36,6) NOT NULL DEFAULT 0,
	fragmentionmaxgroupmax numeric(36,6) NOT NULL DEFAULT 0
)


DECLARE @ratio1helpercount bigint;
DECLARE @ratio1helperid bigint;
DECLARE @ratio1helperidoffset bigint;
SET @ratio1helperidoffset = 0;
DECLARE @productintensity numeric(36,6);
DECLARE @previousratio1ratio numeric(36,6);
DECLARE @ratio1ratio numeric(36,6);
DECLARE @ratiotolerance numeric(36,6);
SET @ratiotolerance = 0.02;
DECLARE @groupid int;
DECLARE @groupcenter numeric(36,6);

DECLARE @ratio1helper TABLE (
	id bigint identity PRIMARY KEY,
	datasetid BIGINT not null,
	peptidesequence varchar(128) NOT NULL,
	precursorintensity numeric(36,6) NOT NULL DEFAULT 0,
	fragmentsequence varchar(128) NOT NULL,

	productintensity numeric(36,6) NOT NULL DEFAULT 0,
	ratio1 numeric(36,6) NOT NULL DEFAULT 0,
	groupid int NOT NULL DEFAULT 0,
	groupcenter numeric(36,6) NOT NULL DEFAULT 0
)

INSERT INTO @ratio1 (datasetid, peptidesequence, fragmentsequence, precursorintensity)
	select distinct datasetid, peptidesequence, fragmentsequence, precursorintensity
	FROM fragmentfile
	WHERE datasetid = 32 -- and peptidesequence = 'ASGNPMPEIIWIR' AND fragmentsequence = 'ASGNPM' and precursorintensity = 2638
	ORDER BY datasetid, peptidesequence, fragmentsequence, precursorintensity 

SET @ratio1count = @@ROWCOUNT;
SET @ratio1id = 1;
WHILE (@ratio1id <= @ratio1count) BEGIN
	SELECT 
		@datasetid = datasetid,
		@peptidesequence = peptidesequence,
		@precursorintensity = precursorintensity,
		@fragmentsequence = fragmentsequence
	FROM @ratio1 
	WHERE id = @ratio1id

	--PRINT cast(@datasetid as varchar(12)) + ' peptide: ' + @peptidesequence + ' peptideintensity: ' + cast(@precursorintensity as varchar(20)) + ' fragment: ' + @fragmentsequence;
	INSERT INTO @ratio1helper (datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity, ratio1)
		SELECT datasetid, peptidesequence, fragmentsequence, precursorintensity, productintensity, cast(productintensity as numeric(36,6)) / cast(precursorintensity as numeric(36,6)) as ratio1
		FROM fragmentfile
		WHERE datasetid = @datasetid and peptidesequence = @peptidesequence AND fragmentsequence = @peptidesequence and precursorintensity = @precursorintensity
		ORDER BY productintensity 
	
	SET @ratio1helpercount = @@ROWCOUNT;
	SET @ratio1helperid = 1;
	
	--PRINT @peptidesequence;

	SET @groupid = 0;
	SET @previousratio1ratio = 0;
	SET @groupcenter = 0;
	WHILE (@ratio1helperid < @ratio1helpercount) BEGIN

		SELECT @productintensity = productintensity, @ratio1ratio = cast(ratio1 as numeric(36,6))
		FROM @ratio1helper
		WHERE id = @ratio1helperidoffset + @ratio1helperid

		IF (@groupid = 0 OR NOT abs(@previousratio1ratio - @ratio1ratio) < @ratiotolerance) BEGIN
			SET @groupid = @groupid + 1;
			SET @groupcenter = @ratio1ratio;
			UPDATE @ratio1helper SET groupid = @groupid, groupcenter = @groupcenter WHERE id = @ratio1helperidoffset + @ratio1helperid
		END ELSE BEGIN
			SELECT @groupcenter = 
				CASE 
					WHEN @previousratio1ratio < @ratio1ratio THEN (@ratio1ratio - @previousratio1ratio / 2) + @previousratio1ratio
					WHEN @previousratio1ratio > @ratio1ratio THEN (@previousratio1ratio - @ratio1ratio / 2) + @ratio1ratio
					ELSE @groupcenter
				END

			UPDATE @ratio1helper SET groupid = @groupid, groupcenter = @groupcenter WHERE id = @ratio1helperidoffset + @ratio1helperid
		END

		/*
		PRINT CHAR(9) + cast(@ratio1helperid as varchar(12)) + ' of '  + cast(@ratio1helpercount as varchar(12)) + ' ' +  CHAR(9) +
		 ' intensity: ' + cast(@productintensity as varchar(12)) +  CHAR(9) +
		 ' ratio: ' + cast(@ratio1ratio as varchar(12)) + ' (prev: ' + cast(@previousratio1ratio as varchar(12)) + ') ' + CHAR(9) +
		 ' group: ' + cast(@groupid as varchar(12)) +  CHAR(9) +
		 ' groupcenter: ' + cast(@groupcenter as varchar(12));
		 */

		SET @previousratio1ratio = @ratio1ratio;
		SET @ratio1helperid = @ratio1helperid + 1;
	END
	
	--PRINT  @groupid;
	IF (@groupid > 2) BEGIN
		SET @errormessage = 'Found more than 2 groups for dataset ' + cast(@datasetid as varchar(12)) + ' with ' + @peptidesequence + ' ' + @fragmentsequence + ' ' + cast(@precursorintensity as varchar(36));
		RAISERROR (@errormessage, 0, 1) WITH NOWAIT;
	END

	UPDATE r1 SET
		r1.fragmentionmaxgroupmin = r1h1.fragmentionmingroupmin,
		r1.fragmentionmaxgroupavg = r1h1.fragmentionmingroupavg,
		r1.fragmentionmaxgroupwavg = r1h1.fragmentionmingroupwavg,
		r1.fragmentionmaxgroupmax = r1h1.fragmentionmingroupmax
	FROM @ratio1 r1
	INNER JOIN (
		SELECT
			datasetid, peptidesequence, fragmentsequence, precursorintensity, 
			min(ratio1) fragmentionmingroupmin,
			avg(ratio1) fragmentionmingroupavg,
			avg(ratio1) fragmentionmingroupwavg,
			max(ratio1) fragmentionmingroupmax
		FROM @ratio1helper
		WHERE groupid = 1
		GROUP BY datasetid, peptidesequence, fragmentsequence, precursorintensity
	) r1h1 ON r1.datasetid = r1h1.datasetid AND r1.peptidesequence = r1h1.peptidesequence AND r1.fragmentsequence = r1h1.fragmentsequence AND r1.precursorintensity = r1h1.precursorintensity
	LEFT JOIN  (
		SELECT
			datasetid, peptidesequence, fragmentsequence, precursorintensity,
			min(ratio1) fragmentionmingroupmin,
			avg(ratio1) fragmentionmingroupavg,
			avg(ratio1) fragmentionmingroupwavg,
			max(ratio1) fragmentionmingroupmax
		FROM @ratio1helper
		WHERE groupid = 2
		GROUP BY datasetid, peptidesequence, fragmentsequence, precursorintensity
	) r1h2 ON r1.datasetid = r1h2.datasetid AND r1.peptidesequence = r1h2.peptidesequence AND r1.fragmentsequence = r1h2.fragmentsequence AND r1.precursorintensity = r1h2.precursorintensity

	SET @ratio1helperidoffset = @ratio1helperidoffset + @ratio1helpercount;
	DELETE FROM @ratio1helper;
	SET @ratio1id = @ratio1id + 1;
END


SELECT * FROM @ratio1
SELECT * FROM @ratio1helper

-- by dataset (for now) peptideseq, fragmentseq, precursorintensity, productintensity, ratio 1, max, min, avg, weighted average... assign each to group based on tolaerance (0.01 for now), group set to average of all ratios within 2 x tolerance of all values in group.. bleh

-- create temp table... assign each ratio to a ratio group

