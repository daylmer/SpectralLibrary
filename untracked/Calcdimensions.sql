/*
select * from DimSequenceType
INSERT INTO DimSequenceType (label)
	SELECT title 
	FROM SequenceMatchType
*/


--select top 1 (select count(*) from DimSequenceType where label = smt.title) 'thing'

/*
select distinct smt.title
from mspeak msp
LEFT JOIN dataset d on msp.datasetid = d.id
LEFT JOIN mspeaktype mspt on msp.mspeaktypeid = mspt.id
LEFT JOIN mspeaksequence msps on msp.id = msps.mspeakid
LEFT JOIN sequencematchtype smt on msps.sequencematchtype = smt.id
LEFT JOIN sequence s on msps.sequenceid = s.id
LEFT JOIN protein p on p.id = msps.proteinid
*/



-- Ensure dimensions are contiguous and non-overlapping
/*
select top 5 --percent
d.id DataSetID, ISNULL((SELECT count(*) from DimDataSet where extid = d.id), -1) 'count', ISNULL((SELECT id from DimDataSet where extid = d.id), -1) DimDataSetID, ISNULL((SELECT label from DimDataSet where extid = d.id), -1) DimDataSetBand,
d.sampledate SampleDate, ISNULL((SELECT count(*) FROM DimTime where sampledate = d.sampledate), -1) 'count',  ISNULL((SELECT id FROM DimTime where sampledate = d.sampledate), -1) DimTimeID, ISNULL((SELECT label FROM DimTime where sampledate = d.sampledate), -1) DimTimeBand,
d.id, ISNULL((SELECT count(*) FROM DimTimePoint where label = (
	SELECT sc.description
	FROM conditioncategory scc 
	INNER JOIN condition sc on sc.conditioncategoryid = scc.id
	INNER JOIN datasetcondition sdsc on sdsc.conditionid = sc.id
	WHERE sdsc.datasetid = d.id and scc.title = 'Timepoint')
), -1) TimePointID,
d.id, ISNULL((SELECT count(*) FROM DimBioReplicate where label = (
	SELECT sc.description
	FROM conditioncategory scc 
	INNER JOIN condition sc on sc.conditioncategoryid = scc.id
	INNER JOIN datasetcondition sdsc on sdsc.conditionid = sc.id
	WHERE sdsc.datasetid = d.id and scc.title = 'Biological Replicate')
), -1) BioReplicateID,
d.id, ISNULL((SELECT count(*) FROM DimTechReplicate where label = (
	SELECT sc.description
	FROM conditioncategory scc 
	INNER JOIN condition sc on sc.conditioncategoryid = scc.id
	INNER JOIN datasetcondition sdsc on sdsc.conditionid = sc.id
	WHERE sdsc.datasetid = d.id and scc.title = 'Technical Replicate')
), -1) TechReplicateID,
msp.masscharge, ISNULL((select count(*) from DimMassChargeAbs where msp.masscharge >= minrange and  msp.masscharge < maxrange), -1) 'count', ISNULL((select id from DimMassChargeAbs where msp.masscharge >= minrange and  msp.masscharge < maxrange), -1) MassChargeAbsID, ISNULL((select label from DimMassChargeAbs where msp.masscharge >= minrange and  msp.masscharge < maxrange), -1) MassChargeAbsBand,
msp.masscharge, ISNULL((select count(*) from DimMassChargeRel where msp.masscharge >= minrange and  msp.masscharge < maxrange), -1) 'count', ISNULL((select id from DimMassChargeRel where msp.masscharge >= minrange and  msp.masscharge < maxrange), -1) MassChargeRelID, ISNULL((select label from DimMassChargeRel where msp.masscharge >= minrange and  msp.masscharge < maxrange), -1) MassChargeRelBand,
msp.retentiontime * 60 retentiontimeminutes, ISNULL((select count(*) from DimRetentionTimeAbs where msp.retentiontime * 60 >= minrange and  msp.retentiontime * 60 < maxrange), -1) 'count', ISNULL((select id from DimRetentionTimeAbs where msp.retentiontime * 60 >= minrange and  msp.retentiontime * 60 < maxrange), -1) RetentionTimeAbsID, ISNULL((select count(*) from DimRetentionTimeAbs where msp.retentiontime * 60 >= minrange and  msp.retentiontime * 60 < maxrange), -1) RetentionTimeAbsBand,
msp.retentiontime * 60 retentiontimeminutes, ISNULL((select count(*) from DimRetentionTimeRel where msp.retentiontime * 60 >= minrange and  msp.retentiontime * 60 < maxrange), -1) 'count', ISNULL((select id from DimRetentionTimeRel where msp.retentiontime * 60 >= minrange and  msp.retentiontime * 60 < maxrange), -1) RetentionTimeRelID, ISNULL((select count(*) from DimRetentionTimeRel where msp.retentiontime * 60 >= minrange and  msp.retentiontime * 60 < maxrange), -1) DimRetentionTimeRelBand,
msp.drifttime, ISNULL((select count(*) from DimDriftTimeAbs where msp.drifttime * 60 >= minrange and  msp.drifttime * 60 < maxrange), -1) 'count', ISNULL((select id from DimDriftTimeAbs where msp.drifttime * 60 >= minrange and  msp.drifttime * 60 < maxrange), -1) DriftTimeAbsID, ISNULL((select label from DimDriftTimeAbs where msp.drifttime * 60 >= minrange and  msp.drifttime * 60 < maxrange), -1) DriftTimeAbsBand,
msp.drifttime, ISNULL((select count(*) from DimDriftTimeRel where msp.drifttime * 60 >= minrange and  msp.drifttime * 60 < maxrange), -1) 'count', ISNULL((select id from DimDriftTimeRel where msp.drifttime * 60 >= minrange and  msp.drifttime * 60 < maxrange), -1) DriftTimeRelID, ISNULL((select label from DimDriftTimeRel where msp.drifttime * 60 >= minrange and  msp.drifttime * 60 < maxrange), -1) DriftTimeRelBand, 
msp.intensity, ISNULL((select count(*) from DimIntensityAbs where msp.intensity >= minrange and  msp.intensity < maxrange), -1) 'count', ISNULL((select id from DimIntensityAbs where msp.intensity >= minrange and  msp.intensity < maxrange), -1) IntensityAbsID, ISNULL((select label from DimIntensityAbs where msp.intensity >= minrange and  msp.intensity < maxrange), -1) IntensityAbsBand, 
msp.intensity, ISNULL((select count(*) from DimIntensityRel where msp.intensity >= minrange and  msp.intensity < maxrange), -1) 'count', ISNULL((select id from DimIntensityRel where msp.intensity >= minrange and  msp.intensity < maxrange), -1) IntensityRelID, ISNULL((select label from DimIntensityRel where msp.intensity >= minrange and  msp.intensity < maxrange), -1)  IntensityRelBand,
s.sequence, ISNULL((select count(*) from DimSequence where sequence = s.sequence), -1) SequenceID,
smt.title, ISNULL((select count(*) from DimSequenceType where label = smt.title), -1) SequenceTypeID,
p.accession, ISNULL((select count(*) from DimProtein where label = p.accession), -1) ProteinID,

d.id, ISNULL((SELECT count(*) FROM DimExperiment where label = (
	SELECT sc.description
	FROM conditioncategory scc 
	INNER JOIN condition sc on sc.conditioncategoryid = scc.id
	INNER JOIN datasetcondition sdsc on sdsc.conditionid = sc.id
	WHERE sdsc.datasetid = d.id and scc.title = 'Experiment')
), -1) ExperimentID,
msps.score, ISNULL((select count(*) from DimScore where msps.score >= minrange and  msps.score < maxrange), -1) ScoreID,
msp.Charge, ISNULL((select count(*) from DimCharge where label = cast(msp.Charge as nvarchar)), -1) ChargeID

from mspeak msp
LEFT JOIN dataset d on msp.datasetid = d.id
LEFT JOIN mspeaktype mspt on msp.mspeaktypeid = mspt.id
LEFT JOIN mspeaksequence msps on msp.id = msps.mspeakid
LEFT JOIN sequencematchtype smt on msps.sequencematchtype = smt.id
LEFT JOIN sequence s on msps.sequenceid = s.id
LEFT JOIN protein p on p.id = msps.proteinid

WHERE
(SELECT count(*) from DimDataSet where extid = d.id) <> 1 OR
(SELECT count(*) FROM DimTime where sampledate = d.sampledate) <> 1 OR
(SELECT count(*) FROM DimTimePoint where label = (
	SELECT sc.description
	FROM conditioncategory scc 
	INNER JOIN condition sc on sc.conditioncategoryid = scc.id
	INNER JOIN datasetcondition sdsc on sdsc.conditionid = sc.id
	WHERE sdsc.datasetid = d.id and scc.title = 'Timepoint')
) <> 1 OR
(SELECT count(*) FROM DimBioReplicate where label = (
	SELECT sc.description
	FROM conditioncategory scc 
	INNER JOIN condition sc on sc.conditioncategoryid = scc.id
	INNER JOIN datasetcondition sdsc on sdsc.conditionid = sc.id
	WHERE sdsc.datasetid = d.id and scc.title = 'Biological Replicate')
) <> 1 OR 
(SELECT count(*) FROM DimTechReplicate where label = (
	SELECT sc.description
	FROM conditioncategory scc 
	INNER JOIN condition sc on sc.conditioncategoryid = scc.id
	INNER JOIN datasetcondition sdsc on sdsc.conditionid = sc.id
	WHERE sdsc.datasetid = d.id and scc.title = 'Technical Replicate')
) <> 1 OR 

(select count(*) from DimMassChargeAbs where msp.masscharge >= minrange and  msp.masscharge < maxrange) <> 1 OR 
(select count(*) from DimMassChargeRel where msp.masscharge >= minrange and  msp.masscharge < maxrange) <> 1 OR
(select count(*) from DimRetentionTimeAbs where msp.retentiontime * 60 >= minrange and  msp.retentiontime * 60 < maxrange) <> 1 OR
(select count(*) from DimRetentionTimeRel where msp.retentiontime * 60 >= minrange and  msp.retentiontime * 60 < maxrange) <> 1 OR

(select count(*) from DimDriftTimeAbs where msp.drifttime >= minrange and  msp.drifttime < maxrange) <> 1 OR
(select count(*) from DimDriftTimeRel where msp.drifttime >= minrange and  msp.drifttime < maxrange) <> 1 OR
(select count(*) from DimIntensityAbs where msp.intensity >= minrange and  msp.intensity < maxrange) <> 1 OR
(select count(*) from DimIntensityRel where msp.intensity >= minrange and  msp.intensity < maxrange) <> 1 OR 

(select count(*) from DimSequence where sequence = s.sequence) <> 1 OR
(select count(*) from DimSequenceType where label = smt.title) <> 1 OR
(select count(*) from DimProtein where label = p.accession) <> 1 OR
(SELECT count(*) FROM DimExperiment where label = (
	SELECT sc.description
	FROM conditioncategory scc 
	INNER JOIN condition sc on sc.conditioncategoryid = scc.id
	INNER JOIN datasetcondition sdsc on sdsc.conditionid = sc.id
	WHERE sdsc.datasetid = d.id and scc.title = 'Experiment')
) <> 1 OR
(select count(*) from DimScore where msps.score >= minrange and  msps.score < maxrange) <> 1 OR
(select count(*) from DimCharge where label = cast(msp.Charge as nvarchar)) <> 1

*/

/*
ckmeans
heirachy, ckmeans the centers of the clusters?
*/
/*

SELECT DISTINCT sequence from dimsequence

select min(masscharge), max(masscharge), count(masscharge) from (select distinct masscharge from mspeak) mc
select min(retentiontime), max(retentiontime), count(retentiontime) from (select distinct retentiontime from mspeak) rt
select min(drifttime), max(drifttime), count(drifttime) from (select distinct drifttime from mspeak) dt
select min(intensity), max(intensity), count(intensity) from (select distinct intensity from mspeak) i


select top 15000 masscharge, charge from mspeak where mspeaktypeid = 1 order by masscharge desc
select top 15000 masscharge, charge from mspeak where mspeaktypeid = 2 order by masscharge desc

select top 5000 precursormz, peptidesequence, * from fragmentfile order by precursormz desc
select top 5000 precursormz, peptidesequence, productmz, fragmentsequence from fragmentfile order by productmz desc


select top 15000 retentiontime from mspeak where mspeaktypeid = 1 order by masscharge desc
select top 15000 retentiontime from mspeak where mspeaktypeid = 2 order by masscharge desc


CREATE TABLE [dbo].[DimMassChargeRel] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(512) NOT NULL,
	[minrange]	numeric(12,6) NOT NULL,
	[maxrange]	numeric(12,6) NOT NULL
)

CREATE TABLE [dbo].[DimRetentionTimeRel] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(512) NOT NULL,
	[minrange]	numeric(12,6) NOT NULL,
	[maxrange]	numeric(12,6) NOT NULL
)

CREATE TABLE [dbo].[DimDriftTimeRel] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(512) NOT NULL,
	[minrange]	numeric(12,6) NOT NULL,
	[maxrange]	numeric(12,6) NOT NULL
)

CREATE TABLE [dbo].[DimIntensityRel] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(512) NOT NULL,
	[minrange]	numeric(12,6) NOT NULL,
	[maxrange]	numeric(12,6) NOT NULL
)

*/
--USE [protein]
--GO

--select top 5 * from fragmentfile


--select count(*) from mspeak

--select top 5 * from mspeak
--select top 5 * from mspeaktype


SET XACT_ABORT ON;
SET NOCOUNT ON;
SET IMPLICIT_TRANSACTIONS OFF;
go  
WHILE (@@TranCount > 0) COMMIT TRANSACTION;  
go 


DECLARE @Conditions TABLE (
	[identity] bigint identity	PRIMARY KEY NOT NULL,
	[datasetid] bigint NOT NULL,
	[category] nvarchar(512) NOT NULL,
	[label] nvarchar(512) NOT NULL
)

INSERT INTO @Conditions
	SELECT sdsc.datasetid, scc.title, sc.description
	FROM conditioncategory scc 
	INNER JOIN condition sc on sc.conditioncategoryid = scc.id
	INNER JOIN datasetcondition sdsc on sdsc.conditionid = sc.id

--SELECT * FROM @Conditions

DECLARE @SpectraHelper TABLE (
	id bigint identity	PRIMARY KEY NOT NULL,

	datasetid			bigint NOT NULL,
	sampledate			datetime,
	MassCharge			numeric(12, 6)	NULL,
	RetentionTime		numeric(12, 6)	NULL,
	DriftTime			numeric(12, 6)	NULL,
	Intensity			numeric(18, 6)	NULL,
	Sequence			varchar(128)	NULL,
	SequenceType		varchar(128)	NULL,
	ProteinAccession	varchar(10)		NULL,

	[ProteinScore]		numeric(12, 6)	NULL,
	[PeptideScore]		numeric(12, 6)	NULL,
	
	[DeconvolutedMass]	numeric(12, 6)	NULL,
	[TheoreticalMass]	numeric(12, 6)	NULL,
	[Charge]			int				NULL,
	
	
	
	[PPM]				numeric(12, 6)	NULL,
	[FWHM]				numeric(12, 6)	NULL


ISNULL((SELECT top 1 id FROM DimTimePoint where label = (SELECT label FROM @Conditions WHERE datasetid = d.id and category = 'Timepoint')), 1) TimePointID,
ISNULL((SELECT top 1 id FROM DimBioReplicate where label = (SELECT label FROM @Conditions WHERE datasetid = d.id and category = 'Biological Replicate')), 1) BioReplicateID,
ISNULL((SELECT top 1 id FROM DimTechReplicate where label = (SELECT label FROM @Conditions WHERE datasetid = d.id and category = 'Technical Replicate')), 1) TechReplicateID,
ISNULL((select top 1 id from DimMassChargeAbs where msp.masscharge >= minrange and  msp.masscharge < maxrange), 1) MassChargeAbsID,
ISNULL((select top 1 id from DimMassChargeRel where msp.masscharge >= minrange and  msp.masscharge < maxrange), 1) MassChargeRelID,
ISNULL((select top 1 id from DimRetentionTimeAbs where msp.retentiontime >= minrange and  msp.retentiontime < maxrange), 1) RetentionTimeAbsID,
ISNULL((select top 1 id from DimRetentionTimeRel where msp.retentiontime >= minrange and  msp.retentiontime < maxrange), 1) RetentionTimeRelID,
ISNULL((select top 1 id from DimDriftTimeAbs where msp.drifttime >= minrange and  msp.drifttime < maxrange), 1) DriftTimeAbsID,
ISNULL((select top 1 id from DimDriftTimeRel where msp.drifttime >= minrange and  msp.drifttime < maxrange), 1) DriftTimeRelID,
ISNULL((select top 1 id from DimIntensityAbs where msp.intensity >= minrange and  msp.intensity < maxrange), 1) IntensityAbsID,
ISNULL((select top 1 id from DimIntensityRel where msp.intensity >= minrange and  msp.intensity < maxrange), 1) IntensityRelID,
ISNULL((select top 1 id from DimSequence where sequence = s.sequence), 1) SequenceID,
ISNULL((select top 1 id from DimSequenceType where label = smt.title), 1) SequenceTypeID,
ISNULL((select top 1 id from DimProtein where label = p.accession), 1) ProteinID,
ISNULL((SELECT top 1 id FROM DimExperiment where label = (SELECT label FROM @Conditions WHERE datasetid = d.id and category = 'Experiment')), 1) ExperimentID,
ISNULL((select top 1 id from DimScore where msps.score >= minrange and  msps.score < maxrange), 1) ScoreID,
ISNULL((select top 1 id from DimCharge where label = cast(msp.Charge as nvarchar)), 1) ChargeID,
msps.proteinscore ProteinScore,
msps.score PeptideScore,
msp.masscharge MassCharge,
msp.mass DeconvolutedMass,
null TheorecitcalMass, -- too hard?
msp.charge Charge,
msp.intensity Intensity,
msp.retentiontime RetentionTime,
msp.drifttime DriftTime,
msp.ppm PPM,
msp.fwhm FWHM,
len(s.sequence) SequenceLength,

null SpectraMatchCount, --dafuq is this shit?
null PeptideMatchCount,
null  FragmentMatchCount

)

INSERT INTO @SpectraHelper
	SELECT 
FROM mspeak msp
LEFT JOIN dataset d on msp.datasetid = d.id
LEFT JOIN mspeaktype mspt on msp.mspeaktypeid = mspt.id
LEFT JOIN mspeaksequence msps on msp.id = msps.mspeakid
LEFT JOIN sequencematchtype smt on msps.sequencematchtype = smt.id
LEFT JOIN sequence s on msps.sequenceid = s.id
LEFT JOIN protein p on p.id = msps.proteinid


--INSERT INTO FactSpectra

select top 1 --percent

ISNULL((SELECT top 1 id from DimDataSet where extid = d.id), 1) DataSetID,
ISNULL((SELECT top 1 id FROM DimTime where sampledate = d.sampledate), 1) TimeID,
ISNULL((SELECT top 1 id FROM DimTimePoint where label = (SELECT label FROM @Conditions WHERE datasetid = d.id and category = 'Timepoint')), 1) TimePointID,
ISNULL((SELECT top 1 id FROM DimBioReplicate where label = (SELECT label FROM @Conditions WHERE datasetid = d.id and category = 'Biological Replicate')), 1) BioReplicateID,
ISNULL((SELECT top 1 id FROM DimTechReplicate where label = (SELECT label FROM @Conditions WHERE datasetid = d.id and category = 'Technical Replicate')), 1) TechReplicateID,
ISNULL((select top 1 id from DimMassChargeAbs where msp.masscharge >= minrange and  msp.masscharge < maxrange), 1) MassChargeAbsID,
ISNULL((select top 1 id from DimMassChargeRel where msp.masscharge >= minrange and  msp.masscharge < maxrange), 1) MassChargeRelID,
ISNULL((select top 1 id from DimRetentionTimeAbs where msp.retentiontime >= minrange and  msp.retentiontime < maxrange), 1) RetentionTimeAbsID,
ISNULL((select top 1 id from DimRetentionTimeRel where msp.retentiontime >= minrange and  msp.retentiontime < maxrange), 1) RetentionTimeRelID,
ISNULL((select top 1 id from DimDriftTimeAbs where msp.drifttime >= minrange and  msp.drifttime < maxrange), 1) DriftTimeAbsID,
ISNULL((select top 1 id from DimDriftTimeRel where msp.drifttime >= minrange and  msp.drifttime < maxrange), 1) DriftTimeRelID,
ISNULL((select top 1 id from DimIntensityAbs where msp.intensity >= minrange and  msp.intensity < maxrange), 1) IntensityAbsID,
ISNULL((select top 1 id from DimIntensityRel where msp.intensity >= minrange and  msp.intensity < maxrange), 1) IntensityRelID,
ISNULL((select top 1 id from DimSequence where sequence = s.sequence), 1) SequenceID,
ISNULL((select top 1 id from DimSequenceType where label = smt.title), 1) SequenceTypeID,
ISNULL((select top 1 id from DimProtein where label = p.accession), 1) ProteinID,
ISNULL((SELECT top 1 id FROM DimExperiment where label = (SELECT label FROM @Conditions WHERE datasetid = d.id and category = 'Experiment')), 1) ExperimentID,
ISNULL((select top 1 id from DimScore where msps.score >= minrange and  msps.score < maxrange), 1) ScoreID,
ISNULL((select top 1 id from DimCharge where label = cast(msp.Charge as nvarchar)), 1) ChargeID,
msps.proteinscore ProteinScore,
msps.score PeptideScore,
msp.masscharge MassCharge,
msp.mass DeconvolutedMass,
null TheorecitcalMass, -- too hard?
msp.charge Charge,
msp.intensity Intensity,
msp.retentiontime RetentionTime,
msp.drifttime DriftTime,
msp.ppm PPM,
msp.fwhm FWHM,
len(s.sequence) SequenceLength,

null SpectraMatchCount, --dafuq is this shit?
null PeptideMatchCount,
null  FragmentMatchCount

--,*
/*
SpectraMatchCount
PeptideMatchCount
FragmentMatchCount
*/

from mspeak msp
LEFT JOIN dataset d on msp.datasetid = d.id
LEFT JOIN mspeaktype mspt on msp.mspeaktypeid = mspt.id
LEFT JOIN mspeaksequence msps on msp.id = msps.mspeakid
LEFT JOIN sequencematchtype smt on msps.sequencematchtype = smt.id
LEFT JOIN sequence s on msps.sequenceid = s.id
LEFT JOIN protein p on p.id = msps.proteinid

--WHERE msp.id < 10000 - 2:55  175s
--WHERE msp.id >= 10000 and msp.id < 100000 - 25m
--WHERE msp.id >= 100000 and msp.id < 110000 - 3:45 (without constraints)
--WHERE msp.id >= 110000 and msp.id < 120000 - 3:21

--WHERE msp.id >= 120000 and msp.id < 1000000  -- 880000 4:46:12

--select * from FactSpectra

--10312192



/*
INNER JOIN dataset d on msp.datasetid = d.id
INNER JOIN mspeaktype mspt on msp.mspeaktypeid = mspt.id
INNER JOIN mspeaksequence msps on msp.id = msps.mspeakid
INNER JOIN sequencematchtype smt on msps.sequencematchtype = smt.id
INNER JOIN sequence s on msps.sequenceid = s.id
INNER JOIN protein p on p.id = msps.proteinid
*/

-- select distinct ExperimentID from FactSpectra where 


--select * from *vSpectra
--select top 5 * from vPeptideFragment