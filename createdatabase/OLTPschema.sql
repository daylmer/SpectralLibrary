/*

The left most peak is monoisotopic
Isotopes being present in the spectra are really useful to determine charge state

Relative difference in intensity between two charge states of something with the same mass to charge is
another factor in being confident you have identified the same peptide between samples.

What is intensity measured in/as?


*/


USE [protein]
GO

/*
	Temporarily drop all foreign key constraints and triggers
*/

IF OBJECT_ID('mspeak_dataset_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[mspeak] DROP	CONSTRAINT mspeak_dataset_fk
IF OBJECT_ID('mspeak_mspeaktype_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[mspeak] DROP	CONSTRAINT mspeak_mspeaktype_fk
IF OBJECT_ID('mspeakx_mspeak1id_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[mspeakx] DROP CONSTRAINT mspeakx_mspeak1id_fk
IF OBJECT_ID('mspeakx_mspeak2id_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[mspeakx] DROP CONSTRAINT mspeakx_mspeak2id_fk
IF OBJECT_ID('mspeakx_peakmatchtype_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[mspeakx] DROP CONSTRAINT mspeakx_peakmatchtype_fk
IF OBJECT_ID('mspeaksequence_mspeakid_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[mspeaksequence] DROP CONSTRAINT mspeaksequence_mspeakid_fk
IF OBJECT_ID('mspeaksequence_proteinid_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[mspeaksequence] DROP CONSTRAINT mspeaksequence_proteinid_fk
IF OBJECT_ID('mspeaksequence_sequenceid_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[mspeaksequence] DROP CONSTRAINT mspeaksequence_sequenceid_fk
IF OBJECT_ID('mspeaksequence_sequencematchtype_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[mspeaksequence] DROP CONSTRAINT mspeaksequence_sequencematchtype_fk

GO

/*
	Temporarily drop unique constraints
*/
IF OBJECT_ID('sequence_sequence_uq', 'UQ') IS NOT NULL
	ALTER TABLE [dbo].[sequence] DROP CONSTRAINT sequence_sequence_uq

IF OBJECT_ID('protein_accession_uq', 'UQ') IS NOT NULL
	ALTER TABLE [dbo].[protein] DROP CONSTRAINT protein_accession_uq


/*
	Temporarily drop all primary key constraints and triggers
*/
IF OBJECT_ID('mspeak_id_pk', 'PK') IS NOT NULL
	ALTER TABLE [dbo].[mspeak] DROP CONSTRAINT mspeak_id_pk
IF OBJECT_ID('mspeak_id_pk', 'PK') IS NOT NULL
	DROP INDEX [dbo].[mspeak].mspeak_id_pk
IF OBJECT_ID('mspeaktype_id_pk', 'PK') IS NOT NULL
	ALTER TABLE [dbo].[mspeaktype] DROP CONSTRAINT mspeaktype_id_pk
IF OBJECT_ID('mspeakmatchtype_id_pk', 'PK') IS NOT NULL
	ALTER TABLE [dbo].[mspeakmatchtype] DROP CONSTRAINT mspeakmatchtype_id_pk
IF OBJECT_ID('mspeakx_id_pk', 'PK') IS NOT NULL
	ALTER TABLE [dbo].[mspeakx] DROP CONSTRAINT mspeakx_id_pk
IF OBJECT_ID('sequence_id_pk', 'PK') IS NOT NULL
	ALTER TABLE [dbo].[sequence] DROP CONSTRAINT sequence_id_pk
IF OBJECT_ID('sequencematchtype_id_pk', 'PK') IS NOT NULL
	ALTER TABLE [dbo].[sequencematchtype] DROP CONSTRAINT sequencematchtype_id_pk
IF OBJECT_ID('protein_id_pk', 'PK') IS NOT NULL
	ALTER TABLE [dbo].[protein] DROP CONSTRAINT protein_id_pk
IF OBJECT_ID('mspeaksequence_id_pk', 'PK') IS NOT NULL
	ALTER TABLE [dbo].[mspeaksequence] DROP	CONSTRAINT mspeaksequence_id_pk
IF OBJECT_ID('aamass_id_pk', 'PK') IS NOT NULL
	ALTER TABLE [dbo].[aamass] DROP	CONSTRAINT aamass_id_pk




/*
	mspeak
	Each row represents a deconvulted MS spectrum peak that has been processed via a mass analyser
	This could be any of the following:
		MS1/MS2/MS3/etc..
		Protein/peptide/fragment

	The numeric data stored is of the same type. (Mass/Charge/intensity/rt/dt)
	A foreign key link to [mspeaktype] defines whether the spectrum was MS1/MS2/MS3 etc..
*/


IF OBJECT_ID (N'mspeak', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[mspeak]
END

CREATE TABLE [dbo].[mspeak] (
	[id] bigint identity NOT NULL,

	-- Foreign Keys
	[datasetid]		bigint			NOT NULL,
	[mspeaktypeid]	tinyint			NOT NULL,

	-- Data
	[masscharge]	numeric(12, 6)	NOT NULL,
	[mass]			numeric(12, 6)	NOT NULL,
	[charge]		tinyint			NOT NULL,
	[intensity]		int				NOT NULL,
	[retentiontime]	numeric(12, 6)	NULL,
	[drifttime]		numeric(12, 6)	NULL,
	[ppm]			numeric(12, 6)	NULL,
	[fwhm]			numeric(12, 6)	NULL,
)
GO

/*
	Whether a spectrum is ms1 or ms2... the numeric data stored is of the same type.
	Not much point fully normalising MS1/MS2 peptide/fragments into separate tables.
	Use a "mspeak type" to determine MS1/MS2/MS3? precursor/product peptide/fragment /intact protein
*/

IF OBJECT_ID (N'mspeaktype', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[mspeaktype]
END

CREATE TABLE [dbo].[mspeaktype] (
	[id] tinyint identity NOT NULL,

	-- Data
	[title]			nvarchar(32) NOT NULL,
	[description]	nvarchar(512) NOT NULL
)
GO

INSERT INTO [mspeaktype]
	SELECT 'Peptides', 'These are peptide data' UNION
	SELECT 'Fragments', 'These are fragment data'
GO

/*
	mspeakmatchtype
	Defines the method for matching two peaks 
	Based on: PLGS matching, other vendor matching, native retention/drift/MZ/intensity/relative intensity matching
*/

IF OBJECT_ID (N'mspeakmatchtype', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[mspeakmatchtype]
END

CREATE TABLE [dbo].[mspeakmatchtype] (
	[id] tinyint identity NOT NULL,

	-- Data
	[title]			nvarchar(32) NOT NULL,
	[description]	nvarchar(512) NOT NULL
)
GO

INSERT INTO [mspeakmatchtype]
	SELECT 'PLGS1', 'These are peptides that have been matched to fragments based on retention time' UNION
	SELECT 'PLGS2', 'These are peptides that have been matched to fragments based on database search' UNION
	SELECT 'Algorithm1', 'These are peptides that have been matched to other peptides based on retention time/mass/drift time' UNION
	SELECT 'Algorithm2', 'These are fragments that have been matched to other fragments based on retention time and mass'
GO

/*
	mspeakx
	A link table between 'mspeak' and 'mspeak'
	This may represent the following relationships:
		Peptide  --> Peptide
		Peptide  --> Fragment
		Fragment --> Fragment
*/

IF OBJECT_ID (N'mspeakx', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[mspeakx]
END

CREATE TABLE [dbo].[mspeakx] (
	[id] bigint identity NOT NULL,

	-- Foreign keys
	[mspeak1id]		bigint			NOT NULL,
	[mspeak2id]		bigint			NOT NULL,

	-- Data
	[mspeakmatchtype]	tinyint			NOT NULL,
	[score]			numeric(12, 6)	NOT NULL,
)
GO


/*
	Table to define all recorded amino acid
	sequences. Currently the sequence max
	length is 32. (This may change)
	doh! Wrong! Changed to 128 on 12:31 31/08/2016
	This is because anti-trypsin rarely leaves
	chains longer than 20 AA following digestion

	Even though the database collation is case insensitive, a trigger is included for convienienve to enforce all sequences are stored in upper case
*/

IF OBJECT_ID (N'sequence', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[sequence]
END

CREATE TABLE [dbo].[sequence] (
	[id] bigint identity NOT NULL,

	-- Data
	[sequence] nvarchar(128) NOT NULL,
);
GO

--CREATE TRIGGER sequence_forceuppercase ON [sequence] FOR INSERT, UPDATE AS
--	UPDATE s SET s.[sequence]=Upper(s.[sequence])
--	FROM [sequence] s INNER JOIN inserted i ON s.id=i.id
--;
GO

/*
	sequencematchtype
	Defines the method for matching two peaks 
	Based on: PLGS matching, other vendor matching, native retention/drift/MZ/intensity/relative intensity matching
*/

IF OBJECT_ID (N'sequencematchtype', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[sequencematchtype]
END

CREATE TABLE [dbo].[sequencematchtype] (
	[id] tinyint identity NOT NULL,

	-- Data
	[title]			nvarchar(32) NOT NULL,
	[description]	nvarchar(512) NOT NULL
)
GO

INSERT INTO [dbo].[sequencematchtype]
	SELECT 'PLGS1',		 'These are sequences that have been matched to mspeaks based on database search' UNION
	SELECT 'Algorithm1', 'These are sequences that have been matched to mspeaks based on high scoring mspeakmatch links in this database'
GO

IF OBJECT_ID (N'protein', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[protein]
END

CREATE TABLE [dbo].[protein] (
	[id] bigint identity NOT NULL,

	-- Data
	-- Even genbank can't decide who long an accession number should be
	-- http://www.ncbi.nlm.nih.gov/Sitemap/samplerecord.html
	-- max in data is 10
	[accession] nvarchar(110) NOT NULL,
);
GO

/*
	mspeaksequence is a link table to match peaks to sequence data based on a type and score

*/
IF OBJECT_ID (N'mspeaksequence', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[mspeaksequence]
END

CREATE TABLE [dbo].[mspeaksequence] (
	[id] bigint identity NOT NULL,

	-- Foreign keys
	[mspeakid]			bigint			NOT NULL,
	[proteinid]			bigint			NOT NULL,
	[sequenceid]		bigint			NOT NULL,
	[sequencematchtype]	tinyint			NOT NULL,

	-- Data
	[proteinscore]		numeric(12, 6)	NOT NULL,
	[score]				numeric(12, 6)	NOT NULL,
);
GO

here down

/*
	Add all primary key constraints
*/
ALTER TABLE [dbo].[mspeak] ADD CONSTRAINT mspeak_id_pk PRIMARY KEY (id)
ALTER TABLE [dbo].[mspeaktype] ADD CONSTRAINT mspeaktype_id_pk PRIMARY KEY (id)
ALTER TABLE [dbo].[mspeakmatchtype] ADD CONSTRAINT mspeakmatchtype_id_pk PRIMARY KEY (id)
ALTER TABLE [dbo].[mspeakx] ADD CONSTRAINT mspeakx_id_pk PRIMARY KEY (id)
ALTER TABLE [dbo].[sequence] ADD CONSTRAINT sequence_id_pk PRIMARY KEY (id)
ALTER TABLE [dbo].[sequencematchtype] ADD CONSTRAINT sequencematchtype_id_pk PRIMARY KEY (id)
ALTER TABLE [dbo].[protein] ADD	CONSTRAINT protein_id_pk PRIMARY KEY (id)
ALTER TABLE [dbo].[mspeaksequence] ADD	CONSTRAINT mspeaksequence_id_pk PRIMARY KEY (id)
ALTER TABLE [dbo].[aamass] ADD	CONSTRAINT aamass_id_pk PRIMARY KEY (id)

/*
	Add Unique constraints
*/
ALTER TABLE [dbo].[sequence] ADD CONSTRAINT sequence_sequence_uq UNIQUE (sequence)
ALTER TABLE [dbo].[protein] ADD CONSTRAINT protein_accession_uq UNIQUE (accession)

/*
	Add all foreign key constraints
*/

IF OBJECT_ID (N'dataset', N'U') IS NOT NULL AND OBJECT_ID('mspeak_dataset_fk', 'F') IS NULL BEGIN
	ALTER TABLE [dbo].[mspeak] ADD
		CONSTRAINT mspeak_dataset_fk	FOREIGN KEY (datasetid)		REFERENCES dataset (id)
END

ALTER TABLE [dbo].[mspeak] ADD
	CONSTRAINT mspeak_mspeaktype_fk	FOREIGN KEY (mspeaktypeid)	REFERENCES mspeaktype (id)

ALTER TABLE [dbo].[mspeakx] ADD
	CONSTRAINT mspeakx_mspeak1id_fk			FOREIGN KEY ([mspeak1id])		REFERENCES mspeak (id),
	CONSTRAINT mspeakx_mspeak2id_fk			FOREIGN KEY ([mspeak2id])		REFERENCES mspeak (id),
	CONSTRAINT mspeakx_peakmatchtype_fk		FOREIGN KEY ([mspeakmatchtype])	REFERENCES mspeakmatchtype (id)

ALTER TABLE [dbo].[mspeaksequence] ADD 
	CONSTRAINT mspeaksequence_mspeakid_fk			FOREIGN KEY ([mspeakid])			REFERENCES [mspeak] (id),
	CONSTRAINT mspeaksequence_proteinid_fk			FOREIGN KEY ([proteinid])			REFERENCES [protein] (id),
	CONSTRAINT mspeaksequence_sequenceid_fk			FOREIGN KEY ([sequenceid])			REFERENCES [sequence] (id),
	CONSTRAINT mspeaksequence_sequencematchtype_fk	FOREIGN KEY ([sequencematchtype])	REFERENCES [sequencematchtype] (id)



/*
	amino acid mass reference table

*/
IF OBJECT_ID (N'aamass', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[aamass]
END

CREATE TABLE [dbo].[aamass] (
	[id] bigint identity PRIMARY KEY NOT NULL,

	-- Data
	[label]				nvarchar(32) NOT NULL,
	[lettercode]		nvarchar(1) NOT NULL,
	[monoisotopicmass]	numeric(12, 6) NULL,
	[averagemass]		numeric(12, 6) NULL,
);
GO

INSERT INTO aamass (label, lettercode, monoisotopicmass, averagemass)
	SELECT 'Alanine', 'A', 71.037114, 71.0779 UNION
	SELECT 'Arginine', 'R', 156.101111, 156.1857 UNION
	SELECT 'Asparagine', 'N', 114.042927, 114.1026 UNION
	SELECT 'Aspartate', 'D', 115.026943, 115.0874 UNION
	SELECT 'Cysteine', 'C',	103.009185, 103.1429 UNION
	SELECT 'Glutamate', 'E', 129.042593, 129.114 UNION
	SELECT 'Glutamine', 'Q', 128.058578, 128.1292 UNION	 
	SELECT 'Glycine', 'G', 57.021464, 57.0513 UNION
	SELECT 'Histidine', 'H', 137.058912, 137.1393 UNION
	SELECT 'Isoleucine', 'I', 113.084064, 113.1576 UNION
	SELECT 'Leucine', 'L', 113.084064, 113.1576 UNION
	SELECT 'Lysine', 'K', 128.094963, 128.1723 UNION
	SELECT 'Methionine', 'M', 131.040485, 131.1961 UNION
	SELECT 'Phenylalanine', 'F', 147.068414, 147.1739 UNION
	SELECT 'Proline', 'P', 97.052764, 97.1152 UNION
	SELECT 'Serine', 'S', 87.032028, 87.0773 UNION
	SELECT 'Threonine', 'T', 101.047679, 101.1039 UNION
	SELECT 'Selenocysteine', 'U', 150.95363, 150.0379 UNION
	SELECT 'Tryptophan', 'W', 186.079313, 186.2099 UNION
	SELECT 'Tyrosine', 'Y',	163.06332, 163.1733 UNION
	SELECT 'Unknown', 'X', null, null UNION 	 	 
	SELECT 'Valine', 'V', 99.068414, 99.1311


SELECT * FROM [dbo].[aamass]

SELECT * FROM [dbo].[mspeak]

SELECT * FROM [dbo].[mspeakmatchtype]

SELECT * FROM [dbo].[mspeaksequence]

SELECT * FROM [dbo].[mspeaktype]

SELECT * FROM [dbo].[mspeakx]

SELECT * FROM [dbo].[protein]

SELECT * FROM [dbo].[sequence]

SELECT * FROM [dbo].[sequencematchtype]

