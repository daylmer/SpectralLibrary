/*

The left most peak is monoisotopic
Isotopes being present in the spectra are really useful to determine charge state

Relative difference in intensity between two charge states of something with the same mass to charge is
another factor in being confident you have identified the same peptide between samples.

What is intensity measured in/as?


*/


/*
Mass (measured, theoretical)
Charge (actual, deconvoluted)
Intensity (actual, normalised)
retention time (actual, aligned)
Drift time (actual, in seconds)
PPM (delta molecular mass Vs measurement)
FWHM (Peak width half height)
count of matching spectra
count of precursor matches
count of product matches
count of peptide matches
averages
avg error calculations
FDR
*/


-- Start


USE [protein]
GO



/*
	Temporarily drop all foreign key constraints
*/

--IF OBJECT_ID('mspeaksequence_mspeakid_fk', 'F') IS NOT NULL
--	ALTER TABLE mspeaksequence DROP CONSTRAINT mspeaksequence_mspeakid_fk
--GO

IF OBJECT_ID('FactSpectra_DimDataSet_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimDataSet_fk
IF OBJECT_ID('FactSpectra_DimTime_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimTime_fk
IF OBJECT_ID('FactSpectra_DimTimePoint_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimTimePoint_fk
IF OBJECT_ID('FactSpectra_DimBioReplicate_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimBioReplicate_fk
IF OBJECT_ID('FactSpectra_DimTechReplicate_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimTechReplicate_fk
IF OBJECT_ID('FactSpectra_DimMassChargeAbs_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimMassChargeAbs_fk
IF OBJECT_ID('FactSpectra_DimMassChargeRel_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimMassChargeRel_fk
IF OBJECT_ID('FactSpectra_DimRetentionTimeAbs_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimRetentionTimeAbs_fk
IF OBJECT_ID('FactSpectra_DimRetentionTimeRel_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimRetentionTimeRel_fk
IF OBJECT_ID('FactSpectra_DimDriftTimeAbs_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimDriftTimeAbs_fk
IF OBJECT_ID('FactSpectra_DimDriftTimeRel_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimDriftTimeRel_fk
IF OBJECT_ID('FactSpectra_DimIntensityAbs_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimIntensityAbs_fk
IF OBJECT_ID('FactSpectra_DimIntensityRel_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimIntensityRel_fk
IF OBJECT_ID('FactSpectra_DimSequence_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimSequence_fk
IF OBJECT_ID('FactSpectra_DimSequenceType_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimSequenceType_fk
IF OBJECT_ID('FactSpectra_DimProtein_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimProtein_fk
IF OBJECT_ID('FactSpectra_DimExperiment_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimExperiment_fk
IF OBJECT_ID('FactSpectra_DimScore_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimScore_fk
IF OBJECT_ID('FactSpectra_DimCharge_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimCharge_fk

GO

/*
	Temporarily drop unique constraints
*/
IF OBJECT_ID('Dimsequence_sequence_uq', 'UQ') IS NOT NULL
	ALTER TABLE [dbo].[sequence] DROP CONSTRAINT sequence_sequence_uq

IF OBJECT_ID('Dimprotein_accession_uq', 'UQ') IS NOT NULL
	ALTER TABLE [dbo].[protein] DROP CONSTRAINT protein_accession_uq



/*
	Views first
*/
IF OBJECT_ID (N'vSpectra', N'V') IS NOT NULL BEGIN
	DROP VIEW vSpectra
END

IF OBJECT_ID (N'vPeptideFragment', N'V') IS NOT NULL BEGIN
	DROP VIEW vPeptideFragment
END

/*
	Dimension tables first
*/

IF OBJECT_ID (N'DimDataSet', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimDataSet]
END

CREATE TABLE [dbo].[DimDataSet] (
	[id]			bigint identity	PRIMARY KEY NOT NULL,
	[extid]			bigint		    NULL,
	[label]			nvarchar(64)   NOT NULL,
	[loaddate]		datetime		NULL,
	[sampledate]	datetime		NULL,
	[filename]		nvarchar(512)	NULL,
)

--ALTER TABLE DimDataSet ALTER COLUMN extid bigint NULL
--ALTER TABLE DimDataSet ALTER COLUMN loaddate datetime NULL
--ALTER TABLE DimDataSet ALTER COLUMN sampledate datetime NULL
--ALTER TABLE DimDataSet ALTER COLUMN filename nvarchar(512) NULL

IF OBJECT_ID (N'DimTime', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimTime]
END

CREATE TABLE [dbo].[DimTime] (
	[id]			bigint identity	PRIMARY KEY NOT NULL,
	[label]			nvarchar(64) NOT NULL,
	[SampleDate]	DateTime NULL
)

IF OBJECT_ID (N'DimTimePoint', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimTimePoint]
END

CREATE TABLE [dbo].[DimTimePoint] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(64) NOT NULL,
)

IF OBJECT_ID (N'DimBioReplicate', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimBioReplicate]
END

CREATE TABLE [dbo].[DimBioReplicate] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(64) NOT NULL,
)

IF OBJECT_ID (N'DimTechReplicate', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimTechReplicate]
END

CREATE TABLE [dbo].[DimTechReplicate] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(64) NOT NULL,
)

IF OBJECT_ID (N'DimMassChargeAbs', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimMassChargeAbs]
END

CREATE TABLE [dbo].[DimMassChargeAbs] (
	[id]			bigint identity	PRIMARY KEY NOT NULL,
	[label]			nvarchar(64) NOT NULL,
	[minrange]		numeric(12,6) NULL,
	[maxrange]		numeric(12,6) NULL
)
/*
IF OBJECT_ID (N'DimMassChargeRel', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimMassChargeRel]
END

CREATE TABLE [dbo].[DimMassChargeRel] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(64) NOT NULL,
	[minrange]	numeric(12,6) NULL,
	[maxrange]	numeric(12,6) NULL,
	[center]		numeric(12,6) NULL,
	[sumofsquares]	numeric(18,6) NULL
)
*/
IF OBJECT_ID (N'DimRetentionTimeAbs', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimRetentionTimeAbs]
END

CREATE TABLE [dbo].[DimRetentionTimeAbs] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(64) NOT NULL,
	[minrange]	numeric(12,6) NULL,
	[maxrange]	numeric(12,6) NULL
)
/*
IF OBJECT_ID (N'DimRetentionTimeRel', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimRetentionTimeRel]
END

CREATE TABLE [dbo].[DimRetentionTimeRel] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(64) NOT NULL,
	[minrange]	numeric(12,6) NULL,
	[maxrange]	numeric(12,6) NULL,
	[center]		numeric(12,6) NULL,
	[sumofsquares]	numeric(12,6) NULL
)
*/
IF OBJECT_ID (N'DimDriftTimeAbs', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimDriftTimeAbs]
END

CREATE TABLE [dbo].[DimDriftTimeAbs] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(64) NOT NULL,
	[minrange]	numeric(12,6) NULL,
	[maxrange]	numeric(12,6) NULL
)
/*
IF OBJECT_ID (N'DimDriftTimeRel', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimDriftTimeRel]
END

CREATE TABLE [dbo].[DimDriftTimeRel] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(64) NOT NULL,
	[minrange]	numeric(12,6) NULL,
	[maxrange]	numeric(12,6) NULL,
	[center]		numeric(12,6) NULL,
	[sumofsquares]	numeric(12,6) NULL
)
*/
IF OBJECT_ID (N'DimIntensityAbs', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimIntensityAbs]
END

CREATE TABLE [dbo].[DimIntensityAbs] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(64) NOT NULL,
	[minrange]	numeric(18,6) NULL,
	[maxrange]	numeric(18,6) NULL
)
/*
IF OBJECT_ID (N'DimIntensityRel', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimIntensityRel]
END

CREATE TABLE [dbo].[DimIntensityRel] (
	[id]			bigint identity	PRIMARY KEY NOT NULL,
	[label]			nvarchar(64) NOT NULL,
	[minrange]		numeric(18,6) NULL,
	[maxrange]		numeric(18,6) NULL,
	[center]		numeric(18,6) NULL,
	[sumofsquares]	numeric(18,6) NULL
)
*/
IF OBJECT_ID (N'DimSequence', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimSequence]
END

CREATE TABLE [dbo].[DimSequence] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[sequence]	nvarchar(128)	NOT NULL
	-- Maybe put the theoretical mass here..
)

IF OBJECT_ID (N'DimSequenceType', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimSequenceType]
END

CREATE TABLE [dbo].[DimSequenceType] (
	[id]	bigint identity	PRIMARY KEY NOT NULL,
	[label] varchar(64)	NOT NULL
)

IF OBJECT_ID (N'DimProtein', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimProtein]
END

CREATE TABLE [dbo].[DimProtein] (
	[id] bigint identity	PRIMARY KEY NOT NULL,
	[label] nvarchar(64)	NOT NULL
)

IF OBJECT_ID (N'DimExperiment', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimExperiment]
END
CREATE TABLE [dbo].[DimExperiment] (
	[id] bigint identity	PRIMARY KEY NOT NULL,
	[label] nvarchar(64)	NOT NULL
)
IF OBJECT_ID (N'DimScore', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimScore]
END
CREATE TABLE [dbo].[DimScore] (
	[id] bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(64) NOT NULL,
	[minrange]	numeric(12,6) NULL,
	[maxrange]	numeric(12,6) NULL
)


IF OBJECT_ID (N'DimCharge', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimCharge]
END

CREATE TABLE [dbo].[DimCharge] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(64) NOT NULL
)

IF OBJECT_ID (N'FactSpectra', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[FactSpectra]
END

CREATE TABLE [dbo].[FactSpectra] (
	[id] bigint identity	PRIMARY KEY NOT NULL,

	-- Foreign Keys
	[DataSetID]			bigint			NOT NULL,
	[TimeID]			bigint			NOT NULL,
	[TimePointID]		bigint			NOT NULL,
	[BioReplicateID]	bigint			NOT NULL,
	[TechReplicateID]	bigint			NOT NULL,
	[MassChargeAbsID]	bigint			NOT NULL,
	[MassChargeRelID]	bigint			NOT NULL,
	[RetentionTimeAbsID]bigint			NOT NULL,
	[RetentionTimeRelID]bigint			NOT NULL,
	[DriftTimeAbsID]	bigint			NOT NULL,
	[DriftTimeRelID]	bigint			NOT NULL,
	[IntensityAbsID]	bigint			NOT NULL,
	[IntensityRelID]	bigint			NOT NULL,
	[SequenceID]		bigint			NOT NULL,
	[SequenceTypeID]	bigint			NOT NULL,
	[ProteinID]			bigint			NOT NULL,
	[ExperimentID]		bigint			NOT NULL,
	[ScoreID]			bigint			NOT NULL,
	[ChargeID]			bigint			NOT NULL,

	-- Numerics
	[ProteinScore]		numeric(12, 6)	NULL,
	[PeptideScore]		numeric(12, 6)	NULL,
	[MassCharge]		numeric(12, 6)	NULL,
	[DeconvolutedMass]	numeric(12, 6)	NULL,
	[TheoreticalMass]	numeric(12, 6)	NULL,
	[Charge]			int				NULL,
	[Intensity]			numeric(18, 6)	NULL,
	[RetentionTime]		numeric(12, 6)	NULL,
	[DriftTime]			numeric(12, 6)	NULL,
	[PPM]				numeric(12, 6)	NULL,
	[FWHM]				numeric(12, 6)	NULL,
	[SequenceLength]	int				NULL,

	-- What are these again?
	[SpectraMatchCount]	bigint			NULL,
	[PeptideMatchCount]	bigint			NULL,
	[FragmentMatchCount]bigint			NULL
)




/*
	Add all foreign key constraints
*/

/*
ALTER TABLE [dbo].[FactSpectra] ADD
	CONSTRAINT FactSpectra_DimDataSet_fk			FOREIGN KEY (DataSetID)			references DimDataSet(id),
	CONSTRAINT FactSpectra_DimTime_fk				FOREIGN KEY (TimeID)			references DimTime(id),
	CONSTRAINT FactSpectra_DimTimePoint_fk			FOREIGN KEY (TimePointID)		references DimTimePoint(id),
	CONSTRAINT FactSpectra_DimBioReplicate_fk		FOREIGN KEY (BioReplicateID)	references DimBioReplicate(id),
	CONSTRAINT FactSpectra_DimTechReplicate_fk		FOREIGN KEY (TechReplicateID)	references DimTechReplicate(id),
	CONSTRAINT FactSpectra_DimMassChargeAbs_fk		FOREIGN KEY (MassChargeAbsID)	references DimMassChargeAbs(id),
	CONSTRAINT FactSpectra_DimMassChargeRel_fk		FOREIGN KEY (MassChargeRelID)	references DimMassChargeRel (id),
	CONSTRAINT FactSpectra_DimRetentionTimeAbs_fk	FOREIGN KEY (RetentionTimeAbsID)references DimRetentionTimeAbs (id),
	CONSTRAINT FactSpectra_DimRetentionTimeRel_fk	FOREIGN KEY (RetentionTimeRelID)references DimRetentionTimeRel (id),
	CONSTRAINT FactSpectra_DimDriftTimeAbs_fk		FOREIGN KEY (DriftTimeAbsID)	references DimDriftTimeAbs (id),
	CONSTRAINT FactSpectra_DimDriftTimeRel_fk		FOREIGN KEY (DriftTimeRelID)	references DimDriftTimeRel (id),
	CONSTRAINT FactSpectra_DimIntensityAbs_fk		FOREIGN KEY (IntensityAbsID)	references DimIntensityAbs (id),
	CONSTRAINT FactSpectra_DimIntensityRel_fk		FOREIGN KEY (IntensityRelID)	references DimIntensityRel (id),
	CONSTRAINT FactSpectra_DimSequence_fk			FOREIGN KEY (SequenceID)		references DimSequence (id),
	CONSTRAINT FactSpectra_DimSequenceType_fk		FOREIGN KEY (SequenceTypeID)	references DimSequenceType (id),
	CONSTRAINT FactSpectra_DimProtein_fk			FOREIGN KEY (ProteinID)			references DimProtein (id),
	CONSTRAINT FactSpectra_DimExperiment_fk			FOREIGN KEY (ExperimentID)		references DimExperiment (id),
	CONSTRAINT FactSpectra_DimScore_fk				FOREIGN KEY (ScoreID)			references DimScore (id),
	CONSTRAINT FactSpectra_DimCharge_fk				FOREIGN KEY (ChargeID)			references DimCharge (id)
	*/

/*
	Add Unique constraints
*/
-- select * from DimDataSet
-- update DimDataSet set label = [filename] where label = ''

/*
	SELECT SUM(max_length)AS TotalIndexKeySize
	FROM sys.columns
	WHERE name IN (N'label')
	AND object_id = OBJECT_ID(N'DimDataSet');
*/
/*
alter table DimDataSet alter column label nvarchar(64) not null

IF OBJECT_ID('DimDataSet_label_uq', 'UQ') IS NOT NULL
	ALTER TABLE [dbo].[DimDataSet] DROP CONSTRAINT DimDataSet_label_uq

ALTER TABLE [dbo].[DimDataSet]			ADD CONSTRAINT DimDataSet_label_uq UNIQUE (label)

ALTER TABLE [dbo].[DimTime]				ADD CONSTRAINT DimTime_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimTimePoint]		ADD CONSTRAINT DimTimePoint_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimBioReplicate]		ADD CONSTRAINT DimBioReplicate_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimTechReplicate]	ADD CONSTRAINT DimTechReplicate_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimMassChargeAbs]	ADD CONSTRAINT DimMassChargeAbs_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimMassChargeRel]	ADD CONSTRAINT DimMassChargeRel_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimRetentionTimeAbs] ADD CONSTRAINT DimRetentionTimeAbs_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimRetentionTimeRel] ADD CONSTRAINT DimRetentionTimeRel_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimDriftTimeAbs]		ADD CONSTRAINT DimDriftTimeAbs_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimDriftTimeRel]		ADD CONSTRAINT DimDriftTimeRel_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimIntensityAbs]		ADD CONSTRAINT DimIntensityAbs_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimIntensityRel]		ADD CONSTRAINT DimIntensityRel_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimSequence]			ADD CONSTRAINT DimSequence_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimSequenceType]		ADD CONSTRAINT DimSequenceType_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimProtein]			ADD CONSTRAINT DimProtein_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimExperiment]		ADD CONSTRAINT DimExperiment_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimScore]			ADD CONSTRAINT DimScore_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimCharge]			ADD CONSTRAINT DimCharg_label_uq UNIQUE (label)
*/



-- Insert 'unknowns' into id = 1
INSERT INTO DimDataSet (extid, label, loaddate, sampledate, filename) VALUES (null, 'Unknown', null,  null, null)
INSERT INTO DimTime (label, sampledate) VALUES ('Unknown', null)
INSERT INTO DimTimePoint (label) VALUES ('Unknown')
INSERT INTO DimBioReplicate (label) VALUES ('Unknown')
INSERT INTO DimTechReplicate (label) VALUES ('Unknown')
INSERT INTO DimMassChargeAbs (label, minrange, maxrange) VALUES ('Unknown', null, null)
-- INSERT INTO DimMassChargeRel (label, minrange, maxrange, center, sumofsquares) VALUES ('Unknown', null, null, null, null)
INSERT INTO DimRetentionTimeAbs (label, minrange, maxrange) VALUES ('Unknown', null, null)
-- INSERT INTO DimRetentionTimeRel (label, minrange, maxrange, center, sumofsquares) VALUES ('Unknown', null, null, null, null)
INSERT INTO DimDriftTimeAbs (label, minrange, maxrange) VALUES ('Unknown', null, null)
-- INSERT INTO DimDriftTimeRel (label, minrange, maxrange, center, sumofsquares) VALUES ('Unknown', null, null, null, null)
INSERT INTO DimIntensityAbs (label, minrange, maxrange) VALUES ('Unknown', null, null)
-- INSERT INTO DimIntensityRel (label, minrange, maxrange, center, sumofsquares) VALUES ('Unknown', null, null, null, null)
INSERT INTO DimSequence (sequence) VALUES('Unknown')
INSERT INTO DimSequenceType (label) VALUES ('Unknown')
INSERT INTO DimProtein (label) VALUES ('Unknown')
INSERT INTO DimExperiment (label) VALUES ('Unknown')
INSERT INTO DimScore (label, minrange, maxrange) VALUES ('Unknown', null, null)
INSERT INTO DimCharge (label) VALUES ('Unknown')



IF OBJECT_ID (N'vSpectra', N'V') IS NOT NULL BEGIN
	DROP VIEW vSpectra
END
GO
CREATE VIEW vSpectra As

SELECT
	fs.id, 
	dmcr.label MassChargeCluster,
	drtr.label RetentionTimeCluster,
	ddtr.label DriftTimeCluster,
	dir.label IntensityCluster,
	dmca.label MassChargeFWBin,
	drta.label RetentionTimeFWBin,
	ddta.label DriftTimeFWBin,
	dia.label IntensityFWBin,

	fs.ProteinScore, fs.PeptideScore, fs.MassCharge, fs.DeconvolutedMass, fs.TheoreticalMass, fs.Charge, fs.Intensity, fs.RetentionTime, fs.DriftTime, fs.PPM, fs.FWHM, fs.SequenceLength, fs.SpectraMatchCount, fs.PeptideMatchCount, fs.FragmentMatchCount, 
	ds.sequence

	from FactSpectra fs
	INNER JOIN DimDataSet dds on fs.DataSetID = dds.id
	INNER JOIN DimSequence ds on fs.SequenceID = ds.id
	INNER JOIN DimMassChargeRel dmcr on fs.MassChargeRelID = dmcr.id
	INNER JOIN DimRetentionTimeRel drtr on fs.RetentionTimeRelID = drtr.id
	INNER JOIN DimDriftTimeRel ddtr on fs.DriftTimeRelID = ddtr.id
	INNER JOIN DimIntensityRel dir on fs.IntensityRelID = dir.id
	INNER JOIN DimMassChargeAbs dmca on fs.MassChargeAbsID = dmca.id
	INNER JOIN DimRetentionTimeAbs drta on fs.RetentionTimeAbsID = drta.id
	INNER JOIN DimDriftTimeAbs ddta on fs.DriftTimeAbsID = ddta.id
	INNER JOIN DimIntensityAbs dia on fs.IntensityAbsID = dia.id

	WHERE ds.sequence IS NOT NULL AND ds.sequence <> ''
	--and ds.sequence = 'AA' and dds.id = 3
GO


--select * from FactSpectra
select * from vSpectra

select count(*) from FactSpectra
select count(*) from vSpectra

IF OBJECT_ID (N'vPeptideFragment', N'V') IS NOT NULL BEGIN
	DROP VIEW vPeptideFragment
END
GO



CREATE VIEW vPeptideFragment As
	SELECT
	fs.id PeptideID, 
	dmcr.label PeptideMassChargeCluster,
	drtr.label PeptideRetentionTimeCluster,
	ddtr.label PeptideDriftTimeCluster,
	dir.label PeptideIntensityCluster,
	fs.ProteinScore, fs.PeptideScore, fs.MassCharge, fs.DeconvolutedMass, fs.TheoreticalMass, fs.Charge, fs.Intensity, fs.RetentionTime, fs.DriftTime, fs.PPM, fs.FWHM, fs.SequenceLength, fs.SpectraMatchCount, fs.PeptideMatchCount, fs.FragmentMatchCount, 
	ds.sequence

	from FactSpectra fs
	INNER JOIN DimSequence ds on fs.SequenceID = ds.id
	INNER JOIN DimMassChargeRel dmcr on fs.MassChargeRelID = dmcr.id
	INNER JOIN DimRetentionTimeRel drtr on fs.RetentionTimeRelID = drtr.id
	INNER JOIN DimDriftTimeRel ddtr on fs.DriftTimeRelID = ddtr.id
	INNER JOIN DimIntensityRel dir on fs.IntensityRelID = dir.id

	WHERE ds.sequence IS NOT NULL AND ds.sequence <> ''
GO




SELECT * FROM DimDataSet
SELECT * FROM DimTime	
SELECT * FROM DimTimePoint
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

SELECT * FROM DimSequenceType
SELECT * FROM DimProtein
SELECT * FROM DimExperiment
SELECT * FROM DimScore
SELECT * FROM DimCharge

