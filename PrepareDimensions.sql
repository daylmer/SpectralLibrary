
INSERT INTO DimDataSet (label, loaddate, sampledate, filename) 
	SELECT title, loaddate, sampledate, filename
	FROM dataset

INSERT INTO DimTime (label, SampleDate) 
	SELECT distinct FORMAT (sampledate, 'D', 'en-gb'), sampledate
	FROM dataset

INSERT INTO DimTimePoint (label)
	SELECT DISTINCT c.description
	FROM conditioncategory cc 
	INNER JOIN condition c on c.conditioncategoryid = cc.id
	INNER JOIN datasetcondition dsc on dsc.conditionid = c.id
	INNER JOIN dataset ds on ds.id = dsc.datasetid
	WHERE cc.title = 'Timepoint'

INSERT INTO DimBioReplicate (label)
	SELECT DISTINCT c.description
	FROM conditioncategory cc 
	INNER JOIN condition c on c.conditioncategoryid = cc.id
	INNER JOIN datasetcondition dsc on dsc.conditionid = c.id
	INNER JOIN dataset ds on ds.id = dsc.datasetid
	WHERE cc.title = 'Biological replicate'

INSERT INTO DimTechReplicate (label)
	SELECT DISTINCT c.description
	FROM conditioncategory cc 
	INNER JOIN condition c on c.conditioncategoryid = cc.id
	INNER JOIN datasetcondition dsc on dsc.conditionid = c.id
	INNER JOIN dataset ds on ds.id = dsc.datasetid
	WHERE cc.title = 'Technical replicate'

INSERT INTO DimSequence (sequence)
	SELECT sequence 
	FROM sequence

INSERT INTO DimProtein (label)
	SELECT accession 
	FROM protein

INSERT INTO DimCharge (label)
	SELECT DISTINCT charge
	FROM mspeak

INSERT INTO DimExperiment (label)
	SELECT DISTINCT c.description
	FROM conditioncategory cc 
	INNER JOIN condition c on c.conditioncategoryid = cc.id
	INNER JOIN datasetcondition dsc on dsc.conditionid = c.id
	INNER JOIN dataset ds on ds.id = dsc.datasetid
	WHERE cc.title = 'Experiment'


--select min(masscharge) from mspeak
--select max(masscharge) from mspeak
--increment 100
insert into DimMassChargeAbs (label, minrange, maxrange)
	SELECT '0 - 100', 0, 100 UNION
	SELECT '100 - 200', 100, 200 UNION
	SELECT '200 - 300', 200, 300 UNION
	SELECT '300 - 400', 300, 400 UNION
	SELECT '400 - 500', 400, 500 UNION
	SELECT '500 - 600', 500, 600 UNION
	SELECT '600 - 700', 600, 700 UNION
	SELECT '700 - 800', 700, 800 UNION
	SELECT '800 - 900', 800, 900 UNION
	SELECT '900 - 1000', 900, 1000 UNION
	SELECT '1000 - 1100', 1000, 1100 UNION
	SELECT '1100 - 1200', 1100, 1200 UNION
	SELECT '1200 - 1300', 1200, 1300 UNION
	SELECT '1300 - 1400', 1300, 1400 UNION
	SELECT '1400 - 1500', 1400, 1500 UNION
	SELECT '1500 - 1600', 1500, 1600 UNION
	SELECT '1600 - 1700', 1600, 1700 UNION
	SELECT '1700 - 1800', 1700, 1800 UNION
	SELECT '1800 - 1900', 1800, 1900 UNION
	SELECT '1900 - 2000', 1900, 2000


-- select min(retentiontime) from mspeak where retentiontime != 0
-- select max(retentiontime) from mspeak

--increment 1
insert into DimRetentionTimeAbs (label, minrange, maxrange)
	SELECT '0 - 20', 0, 20 UNION
	SELECT '20 - 21', 20, 21 UNION
	SELECT '21 - 22', 21, 22 UNION
	SELECT '22 - 23', 22, 23 UNION
	SELECT '23 - 24', 23, 24 UNION
	SELECT '24 - 25', 24, 25 UNION
	SELECT '101 - 102', 101, 102

select * from DimRetentionTimeAbs

--increment 1
-- select min(drifttime) from mspeak where drifttime != 0
-- select max(drifttime) from mspeak
insert into DimDriftTimeAbs (label, minrange, maxrange)
	SELECT '0 - 37', 0, 37 UNION
	SELECT '37 - 38', 20, 21 UNION
	SELECT '38 - 39', 21, 22 UNION
	SELECT '39 - 40', 22, 23 UNION
	SELECT '40 - 41', 23, 24 UNION
	SELECT '41 - 42', 24, 25 UNION
	SELECT '195 - 196', 101, 102

select * from DimDriftTimeAbs


--increment 1
--select min(intensity) from mspeak where intensity != 0
--select max(intensity) from mspeak
--select top 15000 intensity from mspeak where mspeaktypeid = 1 order by intensity desc
--select top 15000 intensity from mspeak where mspeaktypeid = 2 order by intensity desc

insert into DimIntensityAbs (label, minrange, maxrange)
	SELECT '0 - 50', 0, 50 UNION
	SELECT '50 - 1000', 50, 1000 UNION
	SELECT '1000 - 2000', 1000, 2000 UNION
	SELECT '2000 - 3000', 2000, 3000 UNION
	SELECT '3000 - 4000', 3000, 4000 UNION
	SELECT '4000 - 5000', 4000, 5000 UNION
	SELECT '851000 - 852000', 851000, 852000

--increment 1
--select min(score) from mspeaksequence where score != 0
--select max(score) from mspeaksequence
--select top 15000 score from mspeaksequence order by score desc
--select top 15000 score from mspeaksequence order by score desc
insert into DimScore (label, minrange, maxrange)
	SELECT '0 - 3', 0, 3 UNION
	SELECT '3 - 4', 3, 4 UNION
	SELECT '4 - 5', 4, 5 UNION
	SELECT '5 - 6', 5, 6 UNION
	SELECT '6 - 7', 6, 7 UNION
	SELECT '7 - 8', 7, 8 UNION
	SELECT '8 - 9', 8, 9 UNION
	SELECT '9 - 10', 9, 10






SELECT * FROM DimDataSet
SELECT * FROM DimTime
SELECT * FROM DimTimePoint

-- these
SELECT * FROM DimBioReplicate
SELECT * FROM DimTechReplicate

SELECT * FROM DimMassChargeAbs
SELECT * FROM DimMassChargeRel
SELECT * FROM DimRetentionTimeAbs
SELECT * FROM DimRetentionTimeRel
SELECT * FROM DimDriftTimeAbs
SELECT * FROM DimDriftTimeRel
SELECT * FROM DimIntensityAbs
SELECT * FROM DimIntensityRel
SELECT * FROM DimSequence

--these
SELECT * FROM DimSequenceType
SELECT * FROM DimProtein
SELECT * FROM DimExperiment


SELECT * FROM DimScore
SELECT * FROM DimCharge