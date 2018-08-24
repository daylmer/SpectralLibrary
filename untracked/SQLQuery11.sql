IF OBJECT_ID('FactSpectra_DimRetentionTimeRel_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimRetentionTimeRel_fk


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

ALTER TABLE [dbo].[FactSpectra] ADD
	CONSTRAINT FactSpectra_DimRetentionTimeRel_fk	FOREIGN KEY (RetentionTimeRelID)references DimRetentionTimeRel (id)

ALTER TABLE [dbo].[DimRetentionTimeRel] ADD CONSTRAINT DimRetentionTimeRel_label_uq UNIQUE (label)

INSERT INTO DimRetentionTimeRel (label, minrange, maxrange, center, sumofsquares) VALUES ('Unknown', null, null, null, null)



IF OBJECT_ID('FactSpectra_DimRetentionTimeAbs_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimRetentionTimeAbs_fk
IF OBJECT_ID('FactSpectra_DimDriftTimeAbs_fk', 'F') IS NOT NULL
	ALTER TABLE FactSpectra DROP CONSTRAINT FactSpectra_DimDriftTimeAbs_fk

IF OBJECT_ID (N'DimRetentionTimeAbs', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimRetentionTimeAbs]
END

CREATE TABLE [dbo].[DimRetentionTimeAbs] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(64) NOT NULL,
	[minrange]	numeric(12,6) NULL,
	[maxrange]	numeric(12,6) NULL
)

IF OBJECT_ID (N'DimDriftTimeAbs', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[DimDriftTimeAbs]
END

CREATE TABLE [dbo].[DimDriftTimeAbs] (
	[id]		bigint identity	PRIMARY KEY NOT NULL,
	[label]		nvarchar(64) NOT NULL,
	[minrange]	numeric(12,6) NULL,
	[maxrange]	numeric(12,6) NULL
)

ALTER TABLE [dbo].[FactSpectra] ADD
	CONSTRAINT FactSpectra_DimRetentionTimeAbs_fk	FOREIGN KEY (RetentionTimeAbsID)references DimRetentionTimeAbs (id),
	CONSTRAINT FactSpectra_DimDriftTimeAbs_fk		FOREIGN KEY (DriftTimeAbsID)	references DimDriftTimeAbs (id)

ALTER TABLE [dbo].[DimRetentionTimeAbs] ADD CONSTRAINT DimRetentionTimeAbs_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimDriftTimeAbs]	ADD CONSTRAINT DimDriftTimeAbs_label_uq UNIQUE (label)

INSERT INTO DimRetentionTimeAbs (label, minrange, maxrange) VALUES ('Unknown', null, null)
INSERT INTO DimDriftTimeAbs (label, minrange, maxrange) VALUES ('Unknown', null, null)

select * from DimRetentionTimeAbs

select * from DimDriftTimeAbs