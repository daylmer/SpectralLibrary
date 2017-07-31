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
IF OBJECT_ID('mspeakx_peakmatchtype_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[mspeakx] DROP CONSTRAINT mspeakx_peakmatchtype_fk
IF OBJECT_ID('datasetcondition_datasetid_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[datasetcondition] DROP CONSTRAINT datasetcondition_datasetid_fk
IF OBJECT_ID('datasetcondition_conditionid_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[datasetcondition] DROP CONSTRAINT datasetcondition_conditionid_fk
IF OBJECT_ID('condition_conditioncategoryid_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[condition] DROP CONSTRAINT condition_conditioncategoryid_fk
IF OBJECT_ID('datasetconditionuserdata_datasetconditionid_fk', 'F') IS NOT NULL
	ALTER TABLE [dbo].[datasetconditionuserdata] DROP CONSTRAINT datasetconditionuserdata_datasetconditionid_fk
IF OBJECT_ID('fragmentfile_dataset_fk', 'F') IS NOT NULL
	ALTER TABLE fragmentfile DROP CONSTRAINT fragmentfile_dataset_fk

GO


/*
	Flat mapping for the fragment csv file 

*/

IF OBJECT_ID (N'fragmentfile', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[fragmentfile]
END

CREATE TABLE [dbo].[fragmentfile] (
	[id] bigint identity	PRIMARY KEY NOT NULL,

	-- Foreign Keys
	[datasetid]			bigint			NOT NULL,
	
	-- Data
	[proteinaccession]	nvarchar(10)	NOT NULL,
	[proteinscore]		numeric(12, 6)	NOT NULL,
	
	[peptidesequence]	nvarchar(128)	NOT NULL,
	[peptidescore]		numeric(12, 6)	NOT NULL,

	[precursormz]		numeric(12, 6)	NOT NULL,
	[precursormhp]		numeric(12, 6)	NOT NULL, -- Deconvoluted mass minus charged hydron (This is storing a calculated field)
	[precursorz]		tinyint			NOT NULL,
	[precursorintensity]bigint			NOT NULL,
	[precursorrettime]	numeric(12, 6)	NOT NULL,
	[precursormobility]	numeric(12, 6)	NOT NULL,
	[precursordeltappm] numeric(12, 6)	NOT NULL,
	[precursorfwhm]		numeric(12, 6)	NOT NULL,

	-- Theoretical match
	[fragmentsequence]	nvarchar(128)	NOT NULL,	

	-- Product Ion spectra
	[productmz]			numeric(12, 6)	NOT NULL,
	[productmhp]		numeric(12, 6)	NOT NULL,
	[productz]			tinyint			NOT NULL,
	[productintensity]	bigint			NOT NULL,
	[productrettime]	numeric(12, 6)	NOT NULL,
	[productmobility]	numeric(12, 6)	NOT NULL,
	[productdeltappm]   numeric(12, 6)	NOT NULL,
	[productfwhm]		numeric(12, 6)	NOT NULL,

	[processeddate]		datetime		NULL
)

/*


Protein Accession nvarchar
Protein Score

Peptide mhp
peptide sequence nvarchar
peptide score

precursor mhp
precursor ret
precursor intensity
precursor z int
precursor mz
precursor mobility
precursor fwhm
fragment mhp
fragment seq nvarchar
product m_z
product retT
product z int
product Mobility
product fwhm
fragmentproduct deltamhpppm
peptideprecursor deltamhpppm
*/



/*
	A dataset row represents a "file", a "run", a "sample"... a single load.
	This table has a one to many relationship with each MS spectrum peak [mspeak] that is loaded in per file
*/

IF OBJECT_ID (N'dataset', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[dataset]
END

CREATE TABLE [dbo].[dataset] (
	[id] bigint identity	PRIMARY KEY NOT NULL,
	
	-- Data
	[title]			nvarchar(512)	NULL,
	[description]	nvarchar(512)	NULL,
	[loaddate]		datetime		NOT NULL,
	[sampledate]	datetime		NOT NULL,
	[filename]		nvarchar(512)	NOT NULL,
	[createdate]	datetime		NOT NULL,
	[modifydate]	datetime		NOT NULL,

	
		--instrument
		--monoisotopic
		--experiment
		--deconvoluted
		--database searched
		--etc...
	
)
GO

IF OBJECT_ID (N'datasetcondition', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[datasetcondition]
END

CREATE TABLE [dbo].[datasetcondition] (
	[id] bigint identity	PRIMARY KEY NOT NULL,

	-- Foreign Keys
	[datasetid]		bigint			NOT NULL,
	[conditionid]	bigint			NOT NULL,
)
GO

IF OBJECT_ID (N'datasetconditionuserdata', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[datasetconditionuserdata]
END

CREATE TABLE [dbo].[datasetconditionuserdata] (
	[id] bigint identity	PRIMARY KEY NOT NULL,

	-- Foreign Keys
	[datasetconditionid]	bigint		NOT NULL,

	-- User Data (?)... tag additional information (in atomic form) about a datasetcondition.
	[userstring]			nvarchar(128)		NULL,
	[usernumeric]			numeric(12, 6)		NULL,
)
GO


IF OBJECT_ID (N'condition', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[condition]
END

CREATE TABLE [dbo].[condition] (
	[id] bigint identity	PRIMARY KEY NOT NULL,
	
	-- Foreign Keys
	[conditioncategoryid]	bigint NOT NULL,

	-- Data
	[title]			nvarchar(512)	NOT NULL,
	[description]	nvarchar(512)	NOT NULL,
)
GO

IF OBJECT_ID (N'conditioncategory', N'U') IS NOT NULL BEGIN
	DROP TABLE [dbo].[conditioncategory]
END

CREATE TABLE [dbo].[conditioncategory] (
	[id] bigint identity	PRIMARY KEY NOT NULL,
	
	-- Data
	[title]			nvarchar(512)	NOT NULL,
	[description]	nvarchar(512)	NOT NULL,
)
GO

declare @categoryid int 

-- Experiment
INSERT INTO conditioncategory ([title], [description]) VALUES('Experiment', 'Which experiment does the data belong to')
SELECT @categoryid = IDENT_CURRENT('conditioncategory');
INSERT INTO condition 
	SELECT @categoryid, 'AB', 'The AB TimeCourse Accounts' UNION
	SELECT @categoryid, 'X', 'Unknown'

-- Timepoint
INSERT INTO conditioncategory ([title], [description]) VALUES('Timepoint', 'The timepoint in the study')
SELECT @categoryid = IDENT_CURRENT('conditioncategory');
INSERT INTO condition 
	SELECT @categoryid, '1', '1st TimePoint' UNION
	SELECT @categoryid, '2', '2nd TimePoint' UNION
	SELECT @categoryid, '3', '3rd TimePoint' UNION
	SELECT @categoryid, '4', '4th TimePoint' UNION
	SELECT @categoryid, '5', '5th TimePoint'

-- Biological replicate
-- Biological Replicates: Replicates where different samples are used for both replicates
-- biological replicates are when the same type of organism is grown/treated under the same conditions
-- to establish the biological variability which exists between organisms which should be identical. Knowing the inherent variability between “identical” organisms allows one to decide whether observed differences between groups of organisms exposed to different treatments is simply random or represents a “true” biological difference induced by such treatment.
-- Biological Factor: Single biological parameter controlled by the investigator. For example, genotype, diet, environmental stimulus, age, etc.
INSERT INTO conditioncategory ([title], [description]) VALUES('Biological replicate', 'The biological replicate number. Biological Replicates: Replicates where different samples are used for both replicates.')
SELECT @categoryid = IDENT_CURRENT('conditioncategory');
INSERT INTO condition 
	SELECT @categoryid, '1', '1st biological replicate' UNION
	SELECT @categoryid, '2', '2nd biological replicate' UNION
	SELECT @categoryid, '3', '3rd biological replicate' UNION
	SELECT @categoryid, '4', '4th biological replicate' UNION
	SELECT @categoryid, '5', '5th biological replicate'

-- Technical Replicate
-- Technical Replicates: Replicates that share the same sample; i.e. the measurements are repeated.
--technical replicate would be when the exact same sample (after all preparatory techniques) is analyzed multiple times. The point of such a technical replicate would be to establish the variability (experimental error) of the analysis technique (mass spectrometry, LC, etc.), thus allowing one to set confidence limits for what is significant data.
INSERT INTO conditioncategory ([title], [description]) VALUES('Technical replicate', 'The technical replicate number. Technical Replicates: Replicates that share the same sample; i.e. the measurements are repeated.')
SELECT @categoryid = IDENT_CURRENT('conditioncategory');
INSERT INTO condition 
	SELECT @categoryid, '1', '1st technical replicate' UNION
	SELECT @categoryid, '2', '2nd technical replicate' UNION
	SELECT @categoryid, '3', '3rd technical replicate' UNION
	SELECT @categoryid, '4', '4th technical replicate' UNION
	SELECT @categoryid, '5', '5th technical replicate'

-- Cysteine Capping
INSERT INTO conditioncategory ([title], [description]) VALUES('Disulphide bond capping', 'The method used to cap cysteine residues to prevent disulphide bonding during sample preperation')
SELECT @categoryid = IDENT_CURRENT('conditioncategory');
INSERT INTO condition 
	SELECT @categoryid, 'IAE', 'Capper1' UNION
	SELECT @categoryid, 'MMCS', 'capper2'




/*
	Add all foreign key constraints
*/

-- This may throw error, but in some cases it is required.
IF OBJECT_ID (N'mspeak', N'U') IS NOT NULL AND OBJECT_ID('mspeak_dataset_fk', 'F') IS NULL BEGIN
	ALTER TABLE [dbo].[mspeak] ADD
		CONSTRAINT mspeak_dataset_fk	FOREIGN KEY (datasetid)		REFERENCES dataset (id)
END

ALTER TABLE [dbo].[datasetcondition] ADD 
	CONSTRAINT datasetcondition_datasetid_fk		FOREIGN KEY ([datasetid])			REFERENCES [dataset] (id),
	CONSTRAINT datasetcondition_conditionid_fk		FOREIGN KEY ([conditionid])			REFERENCES [condition] (id)

ALTER TABLE [dbo].[condition] ADD 
	CONSTRAINT condition_conditioncategoryid_fk		FOREIGN KEY ([conditioncategoryid])	REFERENCES [conditioncategory] (id)

ALTER TABLE [dbo].[datasetconditionuserdata] ADD 
	CONSTRAINT datasetconditionuserdata_datasetconditionid_fk	FOREIGN KEY ([datasetconditionid])	REFERENCES [datasetcondition] (id)

ALTER TABLE [dbo].[fragmentfile] ADD
	CONSTRAINT fragmentfile_dataset_fk	FOREIGN KEY (datasetid)		REFERENCES dataset (id)

DROP INDEX [fragmentfile_processeddate_idx] ON [dbo].[fragmentfile]
CREATE INDEX fragmentfile_processeddate_idx ON fragmentfile (processeddate) INCLUDE (id)

DROP INDEX fragmentfile_precursormz_idx ON fragmentfile
CREATE NONCLUSTERED INDEX fragmentfile_precursormz_idx ON fragmentfile (precursormz, id);

--CREATE NONCLUSTERED INDEX fragmentfile_s_min_precursormz_idx ON s_precursorgroup (s_min_precursormz ASC);


--CREATE INDEX fragmentfile_processeddate_idx ON fragmentfile (processeddate) INCLUDE (id)


DROP INDEX fragmentfile_peptidesequence_idx ON fragmentfile
DROP INDEX fragmentfile_fragmentsequence_idx ON fragmentfile

CREATE INDEX fragmentfile_peptidesequence_idx ON fragmentfile (peptidesequence) --INCLUDE (id, peptidesequence, fragmentsequence)
CREATE INDEX fragmentfile_fragmentsequence_idx ON fragmentfile (fragmentsequence) --INCLUDE (id, peptidesequence, fragmentsequence)

IF OBJECT_ID('DimDataSet_label_uq', 'UQ') IS NOT NULL
	ALTER TABLE [dbo].[DimDataSet] DROP CONSTRAINT DimDataSet_label_uq

