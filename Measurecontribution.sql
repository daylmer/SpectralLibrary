
-- Purpose: To evaluate the specifity that each measure contributes

-- Use protein database
use protein;
GO

-- When SET XACT_ABORT is ON, if a Transact-SQL statement raises a run-time error, the entire transaction is terminated and rolled back.
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/set-xact-abort-transact-sql
SET XACT_ABORT ON;

-- Stops the message that shows the count of the number of rows affected by a Transact-SQL statement or stored procedure from being returned as part of the result set.
-- When SET NOCOUNT is ON, the count is not returned. When SET NOCOUNT is OFF, the count is returned. The @@ROWCOUNT function is updated even when SET NOCOUNT is ON.
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/set-nocount-transact-sql
SET NOCOUNT ON;

-- Sets the BEGIN TRANSACTION mode to implicit, for the connection.
-- When OFF, each of the preceding T-SQL statements is bounded by an unseen BEGIN TRANSACTION and an unseen COMMIT TRANSACTION statement.
-- When OFF, we say the transaction mode is autocommit. If your T-SQL code visibly issues a BEGIN TRANSACTION, we say the transaction mode is explicit.
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/set-implicit-transactions-transact-sql
SET IMPLICIT_TRANSACTIONS OFF;
GO

-- Clean up transactions
WHILE (@@TranCount > 0) COMMIT TRANSACTION;  
GO

-- Declare errormessage variable
DECLARE @errormessage varchar(1024);

-- Output to console
-- Typically, this script uses RAISERROR in preference to PRINT for console output. 
-- This is because PRINT typically uses an output buffer and is not directly printed to output.
-- Raiserror in conjunction with: "WITH NOWAIT" flushes the output buffer immediately to the console output
-- A raiserror call with a severity of 0 is outputed in the same style as the print function
RAISERROR ('Starting Script. Purpose: To evaluate the specifity that each measure contributes', 0, 1) WITH NOWAIT;

-- Variables to control program flow 

-- recalculatemeasuretables
-- if recalculatemeasuretables is set to 1, The following tables will be droped, re-created and re-populated:
-- s_precursorgroup				-- all fragments, grouped by peptide sequence, aggregating min, max and avg for: mz, rettime, mobility, intensity, deltappm, fwhm, mhp
-- s_productgroup				-- all fragments, grouped by fragment sequence, aggregating min, max and avg for: mz, rettime, mobility, intensity, deltappm, fwhm, mhp
-- c_precursorproductgroup		-- all fragments, grouped by peptide sequence THEN by fragment sequence, aggregating min, max and avg for: mz, rettime, mobility, intensity, deltappm, fwhm, mhp
-- s_peptideweightedaverages	-- all fragments, grouped by peptide sequence and the relevant measure to calculate a weighted average for each measure
-- s_fragmentweightedaverages	-- all fragments, grouped by fragment sequence and the relevant measure to calculate a weighted average for each measure
-- c_peptideweightedaverages    -- all fragments, grouped by peptide sequence THEN by fragment sequence and the relevant measure to calculate a weighted average for each precursor measure
-- c_fragmentweightedaverages   -- all fragments, grouped by peptide sequence THEN by fragment sequence and the relevant measure to calculate a weighted average for each product measure
-- All of the above tables are later used to populate s_precursor_range
DECLARE @recalculatemeasuretables bit; SET @recalculatemeasuretables = 0;

-- recalculatecontributiontables
-- if recalculatecontributiontables is set to 1, The following tables will be droped, re-created and re-populated:
-- s_precursor_range			-- For all peptides, and all measures (mz, rettime, mobility, intensity, deltappm, fwhm, mhp), record the total number of peptides that where the measure falls into the min and max range (total) and of those, the ones that match on the peptide sequence (match). The ratio of match to total as well as the match number gives and idea of how well the measure contributes to identification/
-- e.g. s_precursor_range_precursormz_r measures the total number of fragments where the peptide mz is between the min and max values and the total number of fragments where the precursor mz is between the min and max values and the peptide sequence matches.

-- s_precursor_avgdelta			-- For all peptides, and all measures (mz, rettime, mobility, intensity, deltappm, fwhm, mhp), record the total number of peptides that where the measure is the closest the average value nto the min and max range (total) and of those, the ones that match on the peptide sequence (match). The ratio of match to total as well as the match number gives and idea of how well the measure contributes to identification/
-- s_precursor_wavgdelta
-- s_product_range
-- s_product_avgdelta
-- s_product_wavgdelta
-- Each of these tables is populated with s_precursor_range_precursormobility_r





-- s_precursor_range_precursorrettime_r
-- s_precursor_range_precursormz_r
-- s_precursor_range_precursorfwhm_r
-- s_precursor_range_precursorintensity_r
-- s_precursor_range_precursormhp_r
-- s_precursor_range_precursordeltappm_r
-- s_precursor_range_precursormobility_r


DECLARE @recalculatecontributiontables bit; SET @recalculatecontributiontables = 1;


DECLARE @resetmeasurecontributiontable bit; SET @resetmeasurecontributiontable = 0;
DECLARE @updatemeasures bit; SET @updatemeasures = 0;
DECLARE @updatecontributions bit; SET @updatecontributions = 0;
DECLARE @calculatecontribution bit; SET @calculatecontribution = 0;
DECLARE @reportstats bit; SET @reportstats = 0;



-- Declare timestampstart to record timing data for proceses 
DECLARE @timestampstart datetime;
SET @timestampstart = getdate();

IF (@recalculatemeasuretables = 0) BEGIN
	RAISERROR ('Using existing measure tables', 0, 1) WITH NOWAIT;
END ELSE BEGIN
	RAISERROR ('Recalculating measure tables', 0, 1) WITH NOWAIT;	

	IF OBJECT_ID (N's_precursorgroup', N'U') IS NOT NULL BEGIN
		DROP TABLE s_precursorgroup
	END

	CREATE TABLE s_precursorgroup (
		peptidesequence varchar(128) NOT NULL UNIQUE NONCLUSTERED(peptidesequence),
		peptidefrequency bigint,
		s_min_precursormz numeric(18,6),
		s_avg_precursormz numeric(18,6),
		s_max_precursormz numeric(18,6),
		s_min_precursorrettime numeric(18,6),
		s_avg_precursorrettime numeric(18,6),
		s_max_precursorrettime numeric(18,6),
		s_min_precursormobility numeric(18,6),
		s_avg_precursormobility numeric(18,6),
		s_max_precursormobility numeric(18,6),
		s_min_precursorintensity numeric(36,6),
		s_avg_precursorintensity numeric(36,6),
		s_max_precursorintensity numeric(36,6),
		s_min_precursordeltappm numeric(18,6),
		s_avg_precursordeltappm numeric(18,6),
		s_max_precursordeltappm numeric(18,6),
		s_min_precursorfwhm numeric(18,6),
		s_avg_precursorfwhm numeric(18,6),
		s_max_precursorfwhm numeric(18,6),
		s_min_precursormhp numeric(18,6),
		s_avg_precursormhp numeric(18,6),
		s_max_precursormhp numeric(18,6)
	)

	--Commented out for review and removal
	--DROP index s_precursorgroup_s_min_precursormz_idx ON s_precursorgroup
	--CREATE NONCLUSTERED INDEX s_precursorgroup_s_min_precursormz_idx ON s_precursorgroup (s_min_precursormz, peptidesequence);
	--CREATE NONCLUSTERED INDEX fragmentfile_s_min_precursormz_idx ON s_precursorgroup (s_min_precursormz ASC);
	
	-- All fragments, grouped by peptide sequence, aggregating min, max and avg for: mz, rettime, mobility, intensity, deltappm, fwhm, mhp
	-- This table is used to populate s_precursor_range
	INSERT INTO s_precursorgroup
		SELECT
			ff.peptidesequence,
			count(*) peptidefrequency,
			min(ff.precursormz) s_min_precursormz,
			avg(ff.precursormz) s_avg_precursormz,
			max(ff.precursormz) s_max_precursormz,
			min(ff.precursorrettime) s_min_precursorrettime,
			avg(ff.precursorrettime) s_avg_precursorrettime,
			max(ff.precursorrettime) s_max_precursorrettime,
			min(ff.precursormobility) s_min_precursormobility,
			avg(ff.precursormobility) s_avg_precursormobility,
			max(ff.precursormobility) s_max_precursormobility,
			min(ff.precursorintensity) s_min_precursorintensity,
			avg(cast(ff.precursorintensity as bigint)) s_avg_precursorintensity,
			max(ff.precursorintensity) s_max_precursorintensity,
			min(ff.precursordeltappm) s_min_precursordeltappm,
			avg(ff.precursordeltappm) s_avg_precursordeltappm,
			max(ff.precursordeltappm) s_max_precursordeltappm,
			min(ff.precursorfwhm) s_min_precursorfwhm,
			avg(ff.precursorfwhm) s_avg_precursorfwhm,
			max(ff.precursorfwhm) s_max_precursorfwhm,
			min(ff.precursormhp) s_min_precursormhp,
			avg(ff.precursormhp) s_avg_precursormhp,
			max(ff.precursormhp) s_max_precursormhp
		FROM fragmentfile ff
		GROUP BY peptidesequence 

	SET @errormessage = 's_precursorgroup table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	IF OBJECT_ID (N's_productgroup', N'U') IS NOT NULL BEGIN
		DROP TABLE s_productgroup
	END

	CREATE TABLE s_productgroup (
		fragmentsequence varchar(128) NOT NULL UNIQUE NONCLUSTERED(fragmentsequence),
		fragmentfrequency bigint,
		s_min_productmz numeric(18,6),
		s_avg_productmz numeric(18,6),
		s_max_productmz numeric(18,6),
		s_min_productrettime numeric(18,6),
		s_avg_productrettime numeric(18,6),
		s_max_productrettime numeric(18,6),
		s_min_productmobility numeric(18,6),
		s_avg_productmobility numeric(18,6),
		s_max_productmobility numeric(18,6),
		s_min_productintensity numeric(36,6),
		s_avg_productintensity numeric(36,6),
		s_max_productintensity numeric(36,6),
		s_min_productdeltappm numeric(18,6),
		s_avg_productdeltappm numeric(18,6),
		s_max_productdeltappm numeric(18,6),
		s_min_productfwhm numeric(18,6),
		s_avg_productfwhm numeric(18,6),
		s_max_productfwhm numeric(18,6),
		s_min_productmhp numeric(18,6),
		s_avg_productmhp numeric(18,6),
		s_max_productmhp numeric(18,6)
	)	
	
	INSERT INTO s_productgroup
		SELECT
			fragmentsequence,
			count(*) fragmentfrequency,
			min(productmz) s_min_productmz,
			avg(productmz) s_avg_productmz,
			max(productmz) s_max_productmz,
			min(productrettime) s_min_productrettime,
			avg(productrettime) s_avg_productrettime,
			max(productrettime) s_max_productrettime,
			min(productmobility) s_min_productmobility,
			avg(productmobility) s_avg_productmobility,
			max(productmobility) s_max_productmobility,
			min(productintensity) s_min_productintensity,
			avg(cast(productintensity as bigint)) s_avg_productintensity,
			max(productintensity) s_max_productintensity,
			min(productdeltappm) s_min_productdeltappm,
			avg(productdeltappm) s_avg_productdeltappm,
			max(productdeltappm) s_max_productdeltappm,
			min(productfwhm) s_min_productfwhm,
			avg(productfwhm) s_avg_productfwhm,
			max(productfwhm) s_max_productfwhm,
			min(productmhp) s_min_productmhp,
			avg(productmhp) s_avg_productmhp,
			max(productmhp) s_max_productmhp
		FROM fragmentfile iff
		GROUP BY fragmentsequence 

	SET @errormessage = 's_productgroup table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	IF OBJECT_ID (N'c_precursorproductgroup', N'U') IS NOT NULL BEGIN
		DROP TABLE c_precursorproductgroup
	END

	CREATE TABLE c_precursorproductgroup (
		peptidesequence varchar(128) NOT NULL,
		fragmentsequence varchar(128) NOT NULL,
		peptidefrequency bigint,
		c_min_precursormz numeric(18,6),
		c_avg_precursormz numeric(18,6),
		c_max_precursormz numeric(18,6),
		c_min_precursorrettime numeric(18,6),
		c_avg_precursorrettime numeric(18,6),
		c_max_precursorrettime numeric(18,6),
		c_min_precursormobility numeric(18,6),
		c_avg_precursormobility numeric(18,6),
		c_max_precursormobility numeric(18,6),
		c_min_precursorintensity numeric(36,6),
		c_avg_precursorintensity numeric(36,6),
		c_max_precursorintensity numeric(36,6),
		c_min_precursordeltappm numeric(18,6),
		c_avg_precursordeltappm numeric(18,6),
		c_max_precursordeltappm numeric(18,6),
		c_min_precursorfwhm numeric(18,6),
		c_avg_precursorfwhm numeric(18,6),
		c_max_precursorfwhm numeric(18,6),
		c_min_precursormhp numeric(18,6),
		c_avg_precursormhp numeric(18,6),
		c_max_precursormhp numeric(18,6),
		fragmentfrequency bigint,
		c_min_productmz numeric(18,6),
		c_avg_productmz numeric(18,6),
		c_max_productmz numeric(18,6),
		c_min_productrettime numeric(18,6),
		c_avg_productrettime numeric(18,6),
		c_max_productrettime numeric(18,6),
		c_min_productmobility numeric(18,6),
		c_avg_productmobility numeric(18,6),
		c_max_productmobility numeric(18,6),
		c_min_productintensity numeric(36,6),
		c_avg_productintensity numeric(36,6),
		c_max_productintensity numeric(36,6),
		c_min_productdeltappm numeric(18,6),
		c_avg_productdeltappm numeric(18,6),
		c_max_productdeltappm numeric(18,6),
		c_min_productfwhm numeric(18,6),
		c_avg_productfwhm numeric(18,6),
		c_max_productfwhm numeric(18,6),
		c_min_productmhp numeric(18,6),
		c_avg_productmhp numeric(18,6),
		c_max_productmhp numeric(18,6)
	)
	CREATE INDEX c_precursorproductgroup_peptidesequence_idx ON c_precursorproductgroup (peptidesequence);  
	CREATE INDEX c_precursorproductgroup_fragmentsequence_idx ON c_precursorproductgroup (fragmentsequence);  
	
	INSERT INTO c_precursorproductgroup
		SELECT
			peptidesequence,
			fragmentsequence,
			count(*) peptidefrequency,
			min(precursormz) c_min_precursormz,
			avg(precursormz) c_avg_precursormz,
			max(precursormz) c_max_precursormz,
			min(precursorrettime) c_min_precursorrettime,
			avg(precursorrettime) c_avg_precursorrettime,
			max(precursorrettime) c_max_precursorrettime,
			min(precursormobility) c_min_precursormobility,
			avg(precursormobility) c_avg_precursormobility,
			max(precursormobility) c_max_precursormobility,
			min(precursorintensity) c_min_precursorintensity,
			avg(cast(precursorintensity as bigint)) c_avg_precursorintensity,
			max(precursorintensity) c_max_precursorintensity,
			min(precursordeltappm) c_min_precursordeltappm,
			avg(precursordeltappm) c_avg_precursordeltappm,
			max(precursordeltappm) c_max_precursordeltappm,
			min(precursorfwhm) c_min_precursorfwhm,
			avg(precursorfwhm) c_avg_precursorfwhm,
			max(precursorfwhm) c_max_precursorfwhm,
			min(precursormhp) c_min_precursormhp,
			avg(precursormhp) c_avg_precursormhp,
			max(precursormhp) c_max_precursormhp,
			count(*) fragmentfrequency,
			min(productmz) c_min_productmz,
			avg(productmz) c_avg_productmz,
			max(productmz) c_max_productmz,
			min(productrettime) c_min_productrettime,
			avg(productrettime) c_avg_productrettime,
			max(productrettime) c_max_productrettime,
			min(productmobility) c_min_productmobility,
			avg(productmobility) c_avg_productmobility,
			max(productmobility) c_max_productmobility,
			min(productintensity) c_min_productintensity,
			avg(cast(productintensity as bigint)) c_avg_productintensity,
			max(productintensity) c_max_productintensity,
			min(productdeltappm) c_min_productdeltappm,
			avg(productdeltappm) c_avg_productdeltappm,
			max(productdeltappm) c_max_productdeltappm,
			min(productfwhm) c_min_productfwhm,
			avg(productfwhm) c_avg_productfwhm,
			max(productfwhm) c_max_productfwhm,
			min(productmhp) c_min_productmhp,
			avg(productmhp) c_avg_productmhp,
			max(productmhp) c_max_productmhp
		FROM fragmentfile iff
		GROUP BY peptidesequence, fragmentsequence 
	
	SET @errormessage = 'c_precursorproductgroup table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	SET @errormessage = 'measurecontribution population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_peptideproteincounttable TABLE (
		peptidesequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_peptideproteincounttable
		SELECT peptidesequence, count(proteinaccession)
		FROM fragmentfile f
		GROUP BY peptidesequence

	SET @errormessage = '@s_peptideproteincounttable table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_precursormztable TABLE (
		peptidesequence varchar(128) UNIQUE CLUSTERED, -- no index 2:31, unuci 1:27, unc 1:24
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_precursormztable
		SELECT peptidesequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, precursormz as data, count(precursormz) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, precursormz
		) wt
		GROUP BY wt.peptidesequence

	SET @errormessage = '@s_wavg_precursormztable table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_precursorrettimetable TABLE (
		peptidesequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_precursorrettimetable
		SELECT peptidesequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, precursorrettime as data, count(precursorrettime) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, precursorrettime
		) wt
		GROUP BY wt.peptidesequence

	SET @errormessage = '@s_precursorrettime table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_precursormobilitytable TABLE (
		peptidesequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_precursormobilitytable
		SELECT peptidesequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, precursormobility as data, count(precursormobility) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, precursormobility
		) wt
		GROUP BY wt.peptidesequence

	SET @errormessage = '@s_precursormobility table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_precursorintensitytable TABLE (
		peptidesequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_precursorintensitytable
		SELECT peptidesequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, cast(precursorintensity as bigint) as data, count(precursorintensity) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, precursorintensity
		) wt
		GROUP BY wt.peptidesequence

	SET @errormessage = '@s_precursorintensity table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_precursormobility TABLE (
		peptidesequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_precursormobility
		SELECT peptidesequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, precursormobility as data, count(precursormobility) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, precursormobility
		) wt
		GROUP BY wt.peptidesequence

	SET @errormessage = '@s_wavg_precursormobility table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_precursordeltappmtable TABLE (
		peptidesequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_precursordeltappmtable
		SELECT peptidesequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, CAST(precursorintensity	as bigint) as data, count(precursorintensity) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, precursorintensity
		) wt
		GROUP BY wt.peptidesequence

	SET @errormessage = '@s_precursorintensity table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_precursorfwhmtable TABLE (
		peptidesequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_precursorfwhmtable
		SELECT peptidesequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, precursorfwhm as data, count(precursorfwhm) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, precursorfwhm
		) wt
		GROUP BY wt.peptidesequence

	SET @errormessage = '@s_precursorfwhm table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_precursormhptable TABLE (
		peptidesequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_precursormhptable
		SELECT peptidesequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, precursormhp as data, count(precursormhp) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, precursormhp
		) wt
		GROUP BY wt.peptidesequence

	SET @errormessage = '@s_precursormhp table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	IF OBJECT_ID (N's_peptideweightedaverages', N'U') IS NOT NULL BEGIN
		DROP TABLE s_peptideweightedaverages
	END

	CREATE TABLE s_peptideweightedaverages (
		peptidesequence varchar(128) UNIQUE CLUSTERED,
		peptideproteincount numeric(18,6),
		s_wavg_precursormz numeric(18,6),
		s_wavg_precursorrettime numeric(18,6),
		s_wavg_precursormobility numeric(18,6),
		s_wavg_precursorintensity numeric(18,6),
		s_wavg_precursordeltappm numeric(18,6),
		s_wavg_precursorfwhm numeric(18,6),
		s_wavg_precursormhp  numeric(18,6)
	)
	INSERT INTO s_peptideweightedaverages
		SELECT	peptideproteincounttable.peptidesequence,
				peptideproteincounttable.value,
				s_wavg_precursormztable.value,
				s_wavg_precursorrettimetable.value,
				s_wavg_precursormobilitytable.value,
				s_wavg_precursorintensitytable.value,
				s_wavg_precursordeltappmtable.value,
				s_wavg_precursorfwhmtable.value,
				s_wavg_precursormhptable.value
		FROM  @s_peptideproteincounttable peptideproteincounttable --ON peptideproteincounttable.peptidesequence = mc.peptidesequence
		LEFT JOIN  @s_wavg_precursormztable s_wavg_precursormztable ON s_wavg_precursormztable.peptidesequence = peptideproteincounttable.peptidesequence
		LEFT JOIN  @s_wavg_precursorrettimetable s_wavg_precursorrettimetable ON s_wavg_precursorrettimetable.peptidesequence = peptideproteincounttable.peptidesequence
		LEFT JOIN  @s_wavg_precursormobilitytable s_wavg_precursormobilitytable ON s_wavg_precursormobilitytable.peptidesequence = peptideproteincounttable.peptidesequence
		LEFT JOIN  @s_wavg_precursorintensitytable s_wavg_precursorintensitytable ON s_wavg_precursorintensitytable.peptidesequence = peptideproteincounttable.peptidesequence
		LEFT JOIN  @s_wavg_precursordeltappmtable s_wavg_precursordeltappmtable ON s_wavg_precursordeltappmtable.peptidesequence = peptideproteincounttable.peptidesequence
		LEFT JOIN  @s_wavg_precursorfwhmtable s_wavg_precursorfwhmtable ON s_wavg_precursorfwhmtable.peptidesequence = peptideproteincounttable.peptidesequence
		LEFT JOIN  @s_wavg_precursormhptable s_wavg_precursormhptable ON s_wavg_precursormhptable.peptidesequence = peptideproteincounttable.peptidesequence

	SET @errormessage = 's_peptideweightedaverages table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_fragmentproteincounttable TABLE (
		fragmentsequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_fragmentproteincounttable
		SELECT fragmentsequence, count(proteinaccession)
		FROM fragmentfile f
		GROUP BY fragmentsequence

	SET @errormessage = '@s_fragmentproteincounttable table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_productmztable TABLE (
		fragmentsequence varchar(128) UNIQUE CLUSTERED, -- no index 2:31, unuci 1:27, unc 1:24
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_productmztable
		SELECT fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT fragmentsequence, productmz as data, count(productmz) as weight
				FROM fragmentfile f
				GROUP BY fragmentsequence, productmz
		) wt
		GROUP BY wt.fragmentsequence

	SET @errormessage = '@s_wavg_productmztable table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_productrettimetable TABLE (
		fragmentsequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_productrettimetable
		SELECT fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT fragmentsequence, productrettime as data, count(productrettime) as weight
				FROM fragmentfile f
				GROUP BY fragmentsequence, productrettime
		) wt
		GROUP BY wt.fragmentsequence

	SET @errormessage = '@s_productrettime table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_productmobilitytable TABLE (
		fragmentsequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_productmobilitytable
		SELECT fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT fragmentsequence, productmobility as data, count(productmobility) as weight
				FROM fragmentfile f
				GROUP BY fragmentsequence, productmobility
		) wt
		GROUP BY wt.fragmentsequence

	SET @errormessage = '@s_productmobility table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_productintensitytable TABLE (
		fragmentsequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_productintensitytable
		SELECT fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT fragmentsequence, cast(productintensity as bigint) as data, count(productintensity) as weight
				FROM fragmentfile f
				GROUP BY fragmentsequence, productintensity
		) wt
		GROUP BY wt.fragmentsequence

	SET @errormessage = '@s_productintensity table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;


	DECLARE @s_wavg_productmobility TABLE (
		fragmentsequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_productmobility
		SELECT fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT fragmentsequence, productmobility as data, count(productmobility) as weight
				FROM fragmentfile f
				GROUP BY fragmentsequence, productmobility
		) wt
		GROUP BY wt.fragmentsequence

	SET @errormessage = '@s_wavg_productmobility table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_productdeltappmtable TABLE (
		fragmentsequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_productdeltappmtable
		SELECT fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT fragmentsequence, CAST(productintensity	as bigint) as data, count(productintensity) as weight
				FROM fragmentfile f
				GROUP BY fragmentsequence, productintensity
		) wt
		GROUP BY wt.fragmentsequence

	SET @errormessage = '@s_productintensity table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_productfwhmtable TABLE (
		fragmentsequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_productfwhmtable
		SELECT fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT fragmentsequence, productfwhm as data, count(productfwhm) as weight
				FROM fragmentfile f
				GROUP BY fragmentsequence, productfwhm
		) wt
		GROUP BY wt.fragmentsequence

	SET @errormessage = '@s_productfwhm table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @s_wavg_productmhptable TABLE (
		fragmentsequence varchar(128) UNIQUE CLUSTERED,
		value numeric(18,6)
	)
	INSERT INTO @s_wavg_productmhptable
		SELECT fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT fragmentsequence, productmhp as data, count(productmhp) as weight
				FROM fragmentfile f
				GROUP BY fragmentsequence, productmhp
		) wt
		GROUP BY wt.fragmentsequence

	SET @errormessage = '@s_productmhp table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	IF OBJECT_ID (N's_fragmentweightedaverages', N'U') IS NOT NULL BEGIN
		DROP TABLE s_fragmentweightedaverages
	END

	CREATE TABLE s_fragmentweightedaverages (
		fragmentsequence varchar(128) UNIQUE CLUSTERED,
		fragmentproteincount numeric(18,6),
		s_wavg_productmz numeric(18,6),
		s_wavg_productrettime numeric(18,6),
		s_wavg_productmobility numeric(18,6),
		s_wavg_productintensity numeric(18,6),
		s_wavg_productdeltappm numeric(18,6),
		s_wavg_productfwhm numeric(18,6),
		s_wavg_productmhp  numeric(18,6)
	)

	INSERT INTO s_fragmentweightedaverages
		SELECT	fragmentproteincounttable.fragmentsequence,
				fragmentproteincounttable.value,
				s_wavg_productmztable.value,
				s_wavg_productrettimetable.value,
				s_wavg_productmobilitytable.value,
				s_wavg_productintensitytable.value,
				s_wavg_productdeltappmtable.value,
				s_wavg_productfwhmtable.value,
				s_wavg_productmhptable.value
		FROM  @s_fragmentproteincounttable fragmentproteincounttable --ON fragmentproteincounttable.fragmentsequence = mc.fragmentsequence
		LEFT JOIN  @s_wavg_productmztable s_wavg_productmztable ON s_wavg_productmztable.fragmentsequence = fragmentproteincounttable.fragmentsequence
		LEFT JOIN  @s_wavg_productrettimetable s_wavg_productrettimetable ON s_wavg_productrettimetable.fragmentsequence = fragmentproteincounttable.fragmentsequence
		LEFT JOIN  @s_wavg_productmobilitytable s_wavg_productmobilitytable ON s_wavg_productmobilitytable.fragmentsequence = fragmentproteincounttable.fragmentsequence
		LEFT JOIN  @s_wavg_productintensitytable s_wavg_productintensitytable ON s_wavg_productintensitytable.fragmentsequence = fragmentproteincounttable.fragmentsequence
		LEFT JOIN  @s_wavg_productdeltappmtable s_wavg_productdeltappmtable ON s_wavg_productdeltappmtable.fragmentsequence = fragmentproteincounttable.fragmentsequence
		LEFT JOIN  @s_wavg_productfwhmtable s_wavg_productfwhmtable ON s_wavg_productfwhmtable.fragmentsequence = fragmentproteincounttable.fragmentsequence
		LEFT JOIN  @s_wavg_productmhptable s_wavg_productmhptable ON s_wavg_productmhptable.fragmentsequence = fragmentproteincounttable.fragmentsequence

	SET @errormessage = 's_fragmentweightedaverages table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_peptideproteincounttable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	 --PRIMARY KEY (Column1,Column2)  UNIQUE CLUSTERED (peptidesequence, fragmentsequence),

	INSERT INTO @c_peptideproteincounttable
		SELECT peptidesequence, fragmentsequence, count(proteinaccession)
		FROM fragmentfile f
		GROUP BY peptidesequence, fragmentsequence

	SET @errormessage = '@c_peptideproteincounttable table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_precursormztable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_precursormztable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, precursormz as data, count(precursormz) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, precursormz
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_wavg_precursormztable table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_precursorrettimetable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_precursorrettimetable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, precursorrettime as data, count(precursorrettime) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, precursorrettime
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_precursorrettime table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_precursormobilitytable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_precursormobilitytable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, precursormobility as data, count(precursormobility) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, precursormobility
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_precursormobility table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_precursorintensitytable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_precursorintensitytable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, cast(precursorintensity as bigint) as data, count(precursorintensity) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, precursorintensity
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_precursorintensity table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_precursormobility TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_precursormobility
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, precursormobility as data, count(precursormobility) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, precursormobility
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_wavg_precursormobility table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_precursordeltappmtable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_precursordeltappmtable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, CAST(precursorintensity	as bigint) as data, count(precursorintensity) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, precursorintensity
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_precursorintensity table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_precursorfwhmtable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_precursorfwhmtable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, precursorfwhm as data, count(precursorfwhm) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, precursorfwhm
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_precursorfwhm table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_precursormhptable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_precursormhptable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, precursormhp as data, count(precursormhp) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, precursormhp
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_precursormhp table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	IF OBJECT_ID (N'c_peptideweightedaverages', N'U') IS NOT NULL BEGIN
		DROP TABLE c_peptideweightedaverages
	END

	CREATE TABLE c_peptideweightedaverages (
		peptidesequence varchar(128) NOT NULL,
		fragmentsequence varchar(128) NOT NULL,
		peptideproteincount numeric(18,6),
		c_wavg_precursormz numeric(18,6),
		c_wavg_precursorrettime numeric(18,6),
		c_wavg_precursormobility numeric(18,6),
		c_wavg_precursorintensity numeric(18,6),
		c_wavg_precursordeltappm numeric(18,6),
		c_wavg_precursorfwhm numeric(18,6),
		c_wavg_precursormhp  numeric(18,6)
	);
	CREATE INDEX c_peptideweightedaverages_peptidesequence_idx ON c_peptideweightedaverages (peptidesequence);  
	CREATE INDEX c_peptideweightedaverages_fragmentsequence_idx ON c_peptideweightedaverages (fragmentsequence);  

	INSERT INTO c_peptideweightedaverages
		SELECT	peptideproteincounttable.peptidesequence,
				peptideproteincounttable.fragmentsequence,
				peptideproteincounttable.value,
				c_wavg_precursormztable.value,
				c_wavg_precursorrettimetable.value,
				c_wavg_precursormobilitytable.value,
				c_wavg_precursorintensitytable.value,
				c_wavg_precursordeltappmtable.value,
				c_wavg_precursorfwhmtable.value,
				c_wavg_precursormhptable.value
		--FROM @c_mc mc
		FROM  @c_peptideproteincounttable peptideproteincounttable --ON peptideproteincounttable.peptidesequence = mc.peptidesequence
		LEFT JOIN  @c_wavg_precursormztable c_wavg_precursormztable ON c_wavg_precursormztable.peptidesequence = peptideproteincounttable.peptidesequence AND c_wavg_precursormztable.fragmentsequence = peptideproteincounttable.fragmentsequence
		LEFT JOIN  @c_wavg_precursorrettimetable c_wavg_precursorrettimetable ON c_wavg_precursorrettimetable.peptidesequence = peptideproteincounttable.peptidesequence AND c_wavg_precursorrettimetable.fragmentsequence = peptideproteincounttable.fragmentsequence
		LEFT JOIN  @c_wavg_precursormobilitytable c_wavg_precursormobilitytable ON c_wavg_precursormobilitytable.peptidesequence = peptideproteincounttable.peptidesequence AND c_wavg_precursormobilitytable.fragmentsequence = peptideproteincounttable.fragmentsequence
		LEFT JOIN  @c_wavg_precursorintensitytable c_wavg_precursorintensitytable ON c_wavg_precursorintensitytable.peptidesequence = peptideproteincounttable.peptidesequence AND c_wavg_precursorintensitytable.fragmentsequence = peptideproteincounttable.fragmentsequence
		LEFT JOIN  @c_wavg_precursordeltappmtable c_wavg_precursordeltappmtable ON c_wavg_precursordeltappmtable.peptidesequence = peptideproteincounttable.peptidesequence AND c_wavg_precursordeltappmtable.fragmentsequence = peptideproteincounttable.fragmentsequence
		LEFT JOIN  @c_wavg_precursorfwhmtable c_wavg_precursorfwhmtable ON c_wavg_precursorfwhmtable.peptidesequence = peptideproteincounttable.peptidesequence AND c_wavg_precursorfwhmtable.fragmentsequence = peptideproteincounttable.fragmentsequence
		LEFT JOIN  @c_wavg_precursormhptable c_wavg_precursormhptable ON c_wavg_precursormhptable.peptidesequence = peptideproteincounttable.peptidesequence AND c_wavg_precursormhptable.fragmentsequence = peptideproteincounttable.fragmentsequence

	SET @errormessage = 'c_peptideweightedaverages table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_fragmentproteincounttable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_fragmentproteincounttable
		SELECT peptidesequence, fragmentsequence, count(proteinaccession)
		FROM fragmentfile f
		GROUP BY peptidesequence, fragmentsequence

	SET @errormessage = '@c_fragmentproteincounttable table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_productmztable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_productmztable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, productmz as data, count(productmz) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, productmz
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_wavg_productmztable table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_productrettimetable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_productrettimetable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, productrettime as data, count(productrettime) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, productrettime
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_productrettime table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_productmobilitytable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_productmobilitytable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, productmobility as data, count(productmobility) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, productmobility
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_productmobility table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_productintensitytable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_productintensitytable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, cast(productintensity as bigint) as data, count(productintensity) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, productintensity
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_productintensity table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_productmobility TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_productmobility
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, productmobility as data, count(productmobility) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, productmobility
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_wavg_productmobility table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_productdeltappmtable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_productdeltappmtable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, CAST(productintensity	as bigint) as data, count(productintensity) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, productintensity
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_productintensity table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_productfwhmtable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		value numeric(18,6)
	)
	INSERT INTO @c_wavg_productfwhmtable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, productfwhm as data, count(productfwhm) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, productfwhm
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_productfwhm table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @c_wavg_productmhptable TABLE (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,

		value numeric(18,6)
                                                                              	)
	INSERT INTO @c_wavg_productmhptable
		SELECT peptidesequence, fragmentsequence, SUM(wt.data * wt.weight) / SUM(wt.weight) value
		FROM (
				SELECT peptidesequence, fragmentsequence, productmhp as data, count(productmhp) as weight
				FROM fragmentfile f
				GROUP BY peptidesequence, fragmentsequence, productmhp
		) wt
		GROUP BY wt.peptidesequence, wt.fragmentsequence

	SET @errormessage = '@c_productmhp table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	IF OBJECT_ID (N'c_fragmentweightedaverages', N'U') IS NOT NULL BEGIN
		DROP TABLE c_fragmentweightedaverages
	END

	CREATE TABLE c_fragmentweightedaverages (
		peptidesequence varchar(128) NOT NULL UNIQUE CLUSTERED (peptidesequence, fragmentsequence),
		fragmentsequence varchar(128) NOT NULL,
		fragmentproteincount numeric(18,6),
		c_wavg_productmz numeric(18,6),
		c_wavg_productrettime numeric(18,6),
		c_wavg_productmobility numeric(18,6),
		c_wavg_productintensity numeric(18,6),
		c_wavg_productdeltappm numeric(18,6),
		c_wavg_productfwhm numeric(18,6),
		c_wavg_productmhp  numeric(18,6)
	)
	INSERT INTO c_fragmentweightedaverages
		SELECT	fragmentproteincounttable.peptidesequence,
				fragmentproteincounttable.fragmentsequence,
				fragmentproteincounttable.value,
				c_wavg_productmztable.value,
				c_wavg_productrettimetable.value,
				c_wavg_productmobilitytable.value,
				c_wavg_productintensitytable.value,
				c_wavg_productdeltappmtable.value,
				c_wavg_productfwhmtable.value,
				c_wavg_productmhptable.value
		FROM  @c_fragmentproteincounttable fragmentproteincounttable --ON fragmentproteincounttable.fragmentsequence = mc.fragmentsequence
		LEFT JOIN  @c_wavg_productmztable c_wavg_productmztable ON c_wavg_productmztable.peptidesequence = fragmentproteincounttable.peptidesequence AND c_wavg_productmztable.fragmentsequence = fragmentproteincounttable.fragmentsequence
		LEFT JOIN  @c_wavg_productrettimetable c_wavg_productrettimetable ON c_wavg_productrettimetable.peptidesequence = fragmentproteincounttable.peptidesequence AND c_wavg_productrettimetable.fragmentsequence = fragmentproteincounttable.fragmentsequence
		LEFT JOIN  @c_wavg_productmobilitytable c_wavg_productmobilitytable ON c_wavg_productmobilitytable.peptidesequence = fragmentproteincounttable.peptidesequence AND c_wavg_productmobilitytable.fragmentsequence = fragmentproteincounttable.fragmentsequence
		LEFT JOIN  @c_wavg_productintensitytable c_wavg_productintensitytable ON c_wavg_productintensitytable.peptidesequence = fragmentproteincounttable.peptidesequence AND c_wavg_productintensitytable.fragmentsequence = fragmentproteincounttable.fragmentsequence
		LEFT JOIN  @c_wavg_productdeltappmtable c_wavg_productdeltappmtable ON c_wavg_productdeltappmtable.peptidesequence = fragmentproteincounttable.peptidesequence AND c_wavg_productdeltappmtable.fragmentsequence = fragmentproteincounttable.fragmentsequence
		LEFT JOIN  @c_wavg_productfwhmtable c_wavg_productfwhmtable ON c_wavg_productfwhmtable.peptidesequence = fragmentproteincounttable.peptidesequence AND c_wavg_productfwhmtable.fragmentsequence = fragmentproteincounttable.fragmentsequence
		LEFT JOIN  @c_wavg_productmhptable c_wavg_productmhptable ON c_wavg_productmhptable.peptidesequence = fragmentproteincounttable.peptidesequence AND c_wavg_productmhptable.fragmentsequence = fragmentproteincounttable.fragmentsequence

	SET @errormessage = 'c_fragmentweightedaverages table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

END

IF (@recalculatecontributiontables = 0) BEGIN
	RAISERROR ('Using existing contribution tables', 0, 1) WITH NOWAIT;
END ELSE BEGIN
	RAISERROR ('Recalculating contribution tables', 0, 1) WITH NOWAIT;	


	-- paste the shite here:






-- Temporarally commented out
-- Good stuff here that populates different string constants into the measure column for calcs

/*

	select count(*) from s_precursor_range
	-- 837690

	IF OBJECT_ID (N's_precursor_range', N'U') IS NOT NULL BEGIN
		DROP TABLE s_precursor_range
	END

	CREATE TABLE s_precursor_range (
		measure varchar(64),
		peptidesequence varchar(128),
		match bigint NOT NULL,
		total bigint NOT NULL
	)
	CREATE UNIQUE CLUSTERED INDEX s_precursor_range_productmz_measure_peptidesequence_idx ON s_precursor_range (measure, peptidesequence);

	INSERT INTO s_precursor_range
		SELECT 's_precursor_range_precursormz_r', spg.peptidesequence, match.value, total.value
		FROM s_precursorgroup spg
		CROSS APPLY (
			SELECT spg.peptidesequence, count(*) value
			FROM fragmentfile ff1
			WHERE ff1.precursormz BETWEEN spg.s_min_precursormz and spg.s_max_precursormz AND ff1.peptidesequence = spg.peptidesequence
		) match
		CROSS APPLY
		(
			SELECT spg.peptidesequence, count(*) value
			FROM fragmentfile ff2 
			WHERE ff2.precursormz BETWEEN spg.s_min_precursormz and spg.s_max_precursormz
		) total
		SET @errormessage = 's_precursor_range table population for mz ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_range
	SELECT 's_precursor_range_precursorrettime_r', spg.peptidesequence, match.value, total.value
	FROM s_precursorgroup spg
	CROSS APPLY (
		SELECT spg.peptidesequence, count(*) value
		FROM fragmentfile ff1
		WHERE ff1.precursorrettime BETWEEN spg.s_min_precursorrettime and spg.s_max_precursorrettime AND ff1.peptidesequence = spg.peptidesequence
	) match
	CROSS APPLY
	(
		SELECT spg.peptidesequence, count(*) value
		FROM fragmentfile ff2 
		WHERE ff2.precursorrettime BETWEEN spg.s_min_precursorrettime and spg.s_max_precursorrettime
	) total

	SET @errormessage = 's_precursor_range table population for rettime ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_range
		SELECT 's_precursor_range_precursormobility_r', spg.peptidesequence, match.value, total.value
		FROM s_precursorgroup spg
		CROSS APPLY (
			SELECT spg.peptidesequence, count(*) value
			FROM fragmentfile ff1
			WHERE ff1.precursormobility BETWEEN spg.s_min_precursormobility and spg.s_max_precursormobility AND ff1.peptidesequence = spg.peptidesequence
		) match
		CROSS APPLY
		(
			SELECT spg.peptidesequence, count(*) value
			FROM fragmentfile ff2 
			WHERE ff2.precursormobility BETWEEN spg.s_min_precursormobility and spg.s_max_precursormobility
		) total

	SET @errormessage = 's_precursor_range table population for mobility ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_range
		SELECT 's_precursor_range_precursorintensity_r', spg.peptidesequence, match.value, total.value
		FROM s_precursorgroup spg
		CROSS APPLY (
			SELECT spg.peptidesequence, count(*) value
			FROM fragmentfile ff1
			WHERE ff1.precursorintensity BETWEEN spg.s_min_precursorintensity and spg.s_max_precursorintensity AND ff1.peptidesequence = spg.peptidesequence
		) match
		CROSS APPLY
		(
			SELECT spg.peptidesequence, count(*) value
			FROM fragmentfile ff2 
			WHERE ff2.precursorintensity BETWEEN spg.s_min_precursorintensity and spg.s_max_precursorintensity
		) total

	SET @errormessage = 's_precursor_range table population for intensity ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_range
		SELECT 's_precursor_range_precursordeltappm_r', spg.peptidesequence, match.value, total.value
		FROM s_precursorgroup spg
		CROSS APPLY (
			SELECT spg.peptidesequence, count(*) value
			FROM fragmentfile ff1
			WHERE ff1.precursordeltappm BETWEEN spg.s_min_precursordeltappm and spg.s_max_precursordeltappm AND ff1.peptidesequence = spg.peptidesequence
		) match
		CROSS APPLY
		(
			SELECT spg.peptidesequence, count(*) value
			FROM fragmentfile ff2 
			WHERE ff2.precursordeltappm BETWEEN spg.s_min_precursordeltappm and spg.s_max_precursordeltappm
		) total

	SET @errormessage = 's_precursor_range table population for deltappm ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_range
		SELECT 's_precursor_range_precursorfwhm_r', spg.peptidesequence, match.value, total.value
		FROM s_precursorgroup spg
		CROSS APPLY (
			SELECT spg.peptidesequence, count(*) value
			FROM fragmentfile ff1
			WHERE ff1.precursorfwhm BETWEEN spg.s_min_precursorfwhm and spg.s_max_precursorfwhm AND ff1.peptidesequence = spg.peptidesequence
		) match
		CROSS APPLY
		(
			SELECT spg.peptidesequence, count(*) value
			FROM fragmentfile ff2 
			WHERE ff2.precursorfwhm BETWEEN spg.s_min_precursorfwhm and spg.s_max_precursorfwhm
		) total

	SET @errormessage = 's_precursor_range table population for fwhm ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_range
		SELECT 's_precursor_range_precursormhp_r', spg.peptidesequence, match.value, total.value
		FROM s_precursorgroup spg
		CROSS APPLY (
			SELECT spg.peptidesequence, count(*) value
			FROM fragmentfile ff1
			WHERE ff1.precursormhp BETWEEN spg.s_min_precursormhp and spg.s_max_precursormhp AND ff1.peptidesequence = spg.peptidesequence
		) match
		CROSS APPLY
		(
			SELECT spg.peptidesequence, count(*) value
			FROM fragmentfile ff2 
			WHERE ff2.precursormhp BETWEEN spg.s_min_precursormhp and spg.s_max_precursormhp
		) total

	SET @errormessage = 's_precursor_range table population for mhp ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	-- Drop procedure if exists
	IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.midpoint'))
		DROP PROCEDURE midpoint
	GO

	select count(*) from s_product_range
	-- 837690

	IF OBJECT_ID (N's_product_range', N'U') IS NOT NULL BEGIN
		DROP TABLE s_product_range
	END

	DROP INDEX s_product_range_productmz_measure_fragmentsequence_idx ON s_product_avgdelta;

	CREATE TABLE s_product_range (
		measure varchar(64),
		fragmentsequence varchar(128),
		match bigint NOT NULL,
		total bigint NOT NULL
	)

	INSERT INTO s_product_range
		SELECT 's_product_range_productmz_r', spg.fragmentsequence, match.value, total.value
		FROM s_productgroup spg
		CROSS APPLY (
			SELECT spg.fragmentsequence, count(*) value
			FROM fragmentfile ff1
			WHERE ff1.productmz BETWEEN spg.s_min_productmz and spg.s_max_productmz AND ff1.fragmentsequence = spg.fragmentsequence
		) match
		CROSS APPLY
		(
			SELECT spg.fragmentsequence, count(*) value
			FROM fragmentfile ff2 
			WHERE ff2.productmz BETWEEN spg.s_min_productmz and spg.s_max_productmz
		) total
	SET @errormessage = 's_product_range table population for mz ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_range
	SELECT 's_product_range_productrettime_r', spg.fragmentsequence, match.value, total.value
	FROM s_productgroup spg
	CROSS APPLY (
		SELECT spg.fragmentsequence, count(*) value
		FROM fragmentfile ff1
		WHERE ff1.productrettime BETWEEN spg.s_min_productrettime and spg.s_max_productrettime AND ff1.fragmentsequence = spg.fragmentsequence
	) match
	CROSS APPLY
	(
		SELECT spg.fragmentsequence, count(*) value
		FROM fragmentfile ff2 
		WHERE ff2.productrettime BETWEEN spg.s_min_productrettime and spg.s_max_productrettime
	) total

	SET @errormessage = 's_product_range table population for rettime ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_range
		SELECT 's_product_range_productmobility_r', spg.fragmentsequence, match.value, total.value
		FROM s_productgroup spg
		CROSS APPLY (
			SELECT spg.fragmentsequence, count(*) value
			FROM fragmentfile ff1
			WHERE ff1.productmobility BETWEEN spg.s_min_productmobility and spg.s_max_productmobility AND ff1.fragmentsequence = spg.fragmentsequence
		) match
		CROSS APPLY
		(
			SELECT spg.fragmentsequence, count(*) value
			FROM fragmentfile ff2 
			WHERE ff2.productmobility BETWEEN spg.s_min_productmobility and spg.s_max_productmobility
		) total

	SET @errormessage = 's_product_range table population for mobility ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_range
		SELECT 's_product_range_productintensity_r', spg.fragmentsequence, match.value, total.value
		FROM s_productgroup spg
		CROSS APPLY (
			SELECT spg.fragmentsequence, count(*) value
			FROM fragmentfile ff1
			WHERE ff1.productintensity BETWEEN spg.s_min_productintensity and spg.s_max_productintensity AND ff1.fragmentsequence = spg.fragmentsequence
		) match
		CROSS APPLY
		(
			SELECT spg.fragmentsequence, count(*) value
			FROM fragmentfile ff2 
			WHERE ff2.productintensity BETWEEN spg.s_min_productintensity and spg.s_max_productintensity
		) total

	SET @errormessage = 's_product_range table population for intensity ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_range
		SELECT 's_product_range_productdeltappm_r', spg.fragmentsequence, match.value, total.value
		FROM s_productgroup spg
		CROSS APPLY (
			SELECT spg.fragmentsequence, count(*) value
			FROM fragmentfile ff1
			WHERE ff1.productdeltappm BETWEEN spg.s_min_productdeltappm and spg.s_max_productdeltappm AND ff1.fragmentsequence = spg.fragmentsequence
		) match
		CROSS APPLY
		(
			SELECT spg.fragmentsequence, count(*) value
			FROM fragmentfile ff2 
			WHERE ff2.productdeltappm BETWEEN spg.s_min_productdeltappm and spg.s_max_productdeltappm
		) total

	SET @errormessage = 's_product_range table population for deltappm ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	select count(*) from s_product_range
	-- 3064570

	INSERT INTO s_product_range
		SELECT 's_product_range_productfwhm_r', spg.fragmentsequence, match.value, total.value
		FROM s_productgroup spg
		CROSS APPLY (
			SELECT spg.fragmentsequence, count(*) value
			FROM fragmentfile ff1
			WHERE ff1.productfwhm BETWEEN spg.s_min_productfwhm and spg.s_max_productfwhm AND ff1.fragmentsequence = spg.fragmentsequence
		) match
		CROSS APPLY
		(
			SELECT spg.fragmentsequence, count(*) value
			FROM fragmentfile ff2 
			WHERE ff2.productfwhm BETWEEN spg.s_min_productfwhm and spg.s_max_productfwhm
		) total

	SET @errormessage = 's_product_range table population for fwhm ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	select count(*) from s_product_range
	-- 3677484


	INSERT INTO s_product_range
		SELECT 's_product_range_productmhp_r', spg.fragmentsequence, match.value, total.value
		FROM s_productgroup spg
		CROSS APPLY (
			SELECT spg.fragmentsequence, count(*) value
			FROM fragmentfile ff1
			WHERE ff1.productmhp BETWEEN spg.s_min_productmhp and spg.s_max_productmhp AND ff1.fragmentsequence = spg.fragmentsequence
		) match
		CROSS APPLY
		(
			SELECT spg.fragmentsequence, count(*) value
			FROM fragmentfile ff2  
			WHERE ff2.productmhp BETWEEN spg.s_min_productmhp and spg.s_max_productmhp
		) total

	SET @errormessage = 's_product_range table population for mhp ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	select count(*) from s_product_range
	-- 4290398
	
	CREATE UNIQUE CLUSTERED INDEX s_product_range_productmz_measure_fragmentsequence_idx ON s_product_range (measure, fragmentsequence);


	*/

	-- Table variable to store the results of a call tot he midpoint procedure. Used to populate s_precursorgroup_bounds/s_peptideweightedaverages_bounds
	DECLARE @midpoint TABLE (
		-- Add the column definitions for the TABLE variable here
		id bigint PRIMARY KEY,
		sequence varchar(128) UNIQUE NONCLUSTERED,
		value numeric(18,6),
		value_min numeric(18,6) null,
		value_max numeric(18,6) null
	)


	/*

	DROP PROCEDURE midpoint

	-- Create a procedure that finds the midpoints between centre points to make bounding in a linear space easier
	CREATE PROCEDURE midpoint(
		@SequenceName nvarchar(128),
		@ColumnName nvarchar(128),
		@TableName nvarchar(128)
	) AS BEGIN

		CREATE TABLE #midpoint (
			-- Add the column definitions for the TABLE variable here
			id bigint identity PRIMARY KEY,
			sequence varchar(128) UNIQUE NONCLUSTERED,
			value numeric(18,6),
			value_min numeric(18,6) null,
			value_max numeric(18,6) null
		)

		-- top 5 
		DECLARE @Query nvarchar(1024)
		SET @Query = 
		N' INSERT INTO #midpoint
		SELECT ' + @SequenceName + N', ' + @ColumnName + N', null, null
		FROM ' + @TableName + N' 
		ORDER BY ' + @ColumnName + N' ASC'
		--EXEC (@Query);

		EXECUTE sp_executesql @Query

		DECLARE @peptidesequence varchar(128); SET @peptidesequence = '';
		DECLARE @value numeric(18,6);
		DECLARE @value_min numeric(18,6); SET @value_min = 0.0;
		DECLARE @value_max numeric(18,6); SET @value_max = 0.0;
		DECLARE @previous_value numeric(18,6); SET @previous_value = 0.0;

		DECLARE @index bigint SET @index = (select min(id) from #midpoint);
		DECLARE @maxid bigint; SET @maxid = (select max(id) from #midpoint);

		WHILE (@index < @maxid + 2) BEGIN

			SELECT @value = value
			FROM #midpoint
			WHERE id = @index
	
			IF @value is null SET @value = @previous_value
			SET @value_min = @value + (@previous_value - @value) / 2

			UPDATE #midpoint
			SET		value_min = @value_min
			WHERE id = @index

			UPDATE #midpoint
			SET		value_max = @value_min
			WHERE id = @index - 1

			SET @previous_value = @value;

			SET @index = @index + 1;
		END

		-- After processing, update the first minimum bounds to zero.
		UPDATE #midpoint	SET value_min = 0 WHERE id = 1

		-- Return contents of temporary table
		SELECT * FROM #midpoint
	END
	GO


	-- Create permanent table to create bounds binning for each peptide and measure. Precursor averages
	IF OBJECT_ID (N's_precursorgroup_bounds', N'U') IS NOT NULL BEGIN
		DROP TABLE s_precursorgroup_bounds
	END

	-- Table to store mid bounds between average centre points in order to easily determine which values are closest (euclidian distance) to each average centre point.
	CREATE TABLE s_precursorgroup_bounds (
		peptidesequence varchar(128) NOT NULL UNIQUE NONCLUSTERED(peptidesequence),
		s_avg_precursormz_minbound numeric(18,6),
		s_avg_precursormz_maxbound numeric(18,6),
		s_avg_precursorrettime_minbound numeric(18,6),
		s_avg_precursorrettime_maxbound numeric(18,6),
		s_avg_precursormobility_minbound numeric(18,6),
		s_avg_precursormobility_maxbound numeric(18,6),
		s_avg_precursorintensity_minbound numeric(18,6),
		s_avg_precursorintensity_maxbound numeric(18,6),
		s_avg_precursordeltappm_minbound numeric(18,6),
		s_avg_precursordeltappm_maxbound numeric(18,6),
		s_avg_precursorfwhm_minbound numeric(18,6),
		s_avg_precursorfwhm_maxbound numeric(18,6),
		s_avg_precursormhp_minbound numeric(18,6),
		s_avg_precursormhp_maxbound numeric(18,6)
	)

	-- Populate above table with known sequences
	INSERT INTO s_precursorgroup_bounds (peptidesequence)
		SELECT peptidesequence FROM s_precursorgroup

	-- Create permanent table to create bounds binning for each peptide and measure. Precursor weighted averages
	IF OBJECT_ID (N's_peptideweightedaverages_bounds', N'U') IS NOT NULL BEGIN
		DROP TABLE s_peptideweightedaverages_bounds
	END

	-- Table to store mid bounds between average centre points in order to easily determine which values are closest (euclidian distance) to each average centre point.
	CREATE TABLE s_peptideweightedaverages_bounds (
		peptidesequence varchar(128) UNIQUE CLUSTERED,
		s_wavg_precursormz_minbound numeric(18,6),
		s_wavg_precursormz_maxbound numeric(18,6),
		s_wavg_precursorrettime_minbound numeric(18,6),
		s_wavg_precursorrettime_maxbound numeric(18,6),
		s_wavg_precursormobility_minbound numeric(18,6),
		s_wavg_precursormobility_maxbound numeric(18,6),
		s_wavg_precursorintensity_minbound numeric(18,6),
		s_wavg_precursorintensity_maxbound numeric(18,6),
		s_wavg_precursordeltappm_minbound numeric(18,6),
		s_wavg_precursordeltappm_maxbound numeric(18,6),
		s_wavg_precursorfwhm_minbound numeric(18,6),
		s_wavg_precursorfwhm_maxbound numeric(18,6),
		s_wavg_precursormhp_minbound  numeric(18,6),
		s_wavg_precursormhp_maxbound  numeric(18,6)
	)

	INSERT INTO s_peptideweightedaverages_bounds (peptidesequence)
		SELECT peptidesequence FROM s_peptideweightedaverages

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_avg_precursormz', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursormz_minbound = m.value_min,
		s_avg_precursormz_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_avg_precursorrettime', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursorrettime_minbound = m.value_min,
		s_avg_precursorrettime_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_avg_precursormobility', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursormobility_minbound = m.value_min,
		s_avg_precursormobility_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_avg_precursorintensity', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursorintensity_minbound = m.value_min,
		s_avg_precursorintensity_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_avg_precursordeltappm', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursordeltappm_minbound = m.value_min,
		s_avg_precursordeltappm_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_avg_precursorfwhm', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursorfwhm_minbound = m.value_min,
		s_avg_precursorfwhm_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_avg_precursormhp', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursormhp_minbound = m.value_min,
		s_avg_precursormhp_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_wavg_precursormz', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursormz_minbound = m.value_min,
		s_wavg_precursormz_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_wavg_precursorrettime', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursorrettime_minbound = m.value_min,
		s_wavg_precursorrettime_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_wavg_precursormobility', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursormobility_minbound = m.value_min,
		s_wavg_precursormobility_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_wavg_precursorintensity', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursorintensity_minbound = m.value_min,
		s_wavg_precursorintensity_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_wavg_precursordeltappm', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursordeltappm_minbound = m.value_min,
		s_wavg_precursordeltappm_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_wavg_precursorfwhm', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursorfwhm_minbound = m.value_min,
		s_wavg_precursorfwhm_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'peptidesequence', 's_wavg_precursormhp', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursormhp_minbound = m.value_min,
		s_wavg_precursormhp_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint


	*/

		-- Do all of the above again for precursor-product combinations

/*

	-- s_precursor_avgdelta
	-- commented because populated.


	IF OBJECT_ID (N's_precursor_avgdelta', N'U') IS NOT NULL BEGIN
		DROP TABLE s_precursor_avgdelta
	END

	--DROP INDEX s_precursor_avgdelta_measure_peptidesequence_idx ON s_precursor_avgdelta;

	CREATE TABLE s_precursor_avgdelta (
		measure varchar(64),
		peptidesequence varchar(128),
		match bigint NOT NULL,
		total bigint NOT NULL
	)
	DELETE FROM s_precursor_avgdelta

	INSERT INTO s_precursor_avgdelta
		SELECT 's_precursor_avgdeltamz_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_precursorgroup_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursormz
				FROM fragmentfile ff1 
				WHERE ff1.precursormz BETWEEN b.s_avg_precursormz_minbound AND b.s_avg_precursormz_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	--  time 01:22
	SET @errormessage = 's_precursor_avgdelta table population for mz ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;
	
	INSERT INTO s_precursor_avgdelta
		SELECT 's_precursor_avgdelta_rettime_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_precursorgroup_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursorrettime
				FROM fragmentfile ff1 
				WHERE ff1.precursorrettime BETWEEN b.s_avg_precursorrettime_minbound AND b.s_avg_precursorrettime_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	SET @errormessage = 's_precursor_avgdelta table population for rettime ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_avgdelta
		SELECT 's_precursor_avgdelta_mobility_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_precursorgroup_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursormobility
				FROM fragmentfile ff1 
				WHERE ff1.precursormobility BETWEEN b.s_avg_precursormobility_minbound AND b.s_avg_precursormobility_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	SET @errormessage = 's_precursor_avgdelta table population for mobility ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_avgdelta
		SELECT 's_precursor_avgdelta_intensity_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_precursorgroup_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursorintensity
				FROM fragmentfile ff1 
				WHERE ff1.precursorintensity BETWEEN b.s_avg_precursorintensity_minbound AND b.s_avg_precursorintensity_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	SET @errormessage = 's_precursor_avgdelta table population for intensity ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_avgdelta
		SELECT 's_precursor_avgdelta_deltappm_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_precursorgroup_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursordeltappm
				FROM fragmentfile ff1 
				WHERE ff1.precursordeltappm BETWEEN b.s_avg_precursordeltappm_minbound AND b.s_avg_precursordeltappm_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	SET @errormessage = 's_precursor_avgdelta table population for deltappm ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_avgdelta
		SELECT 's_precursor_avgdelta_fwhm_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_precursorgroup_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursorfwhm
				FROM fragmentfile ff1 
				WHERE ff1.precursorfwhm BETWEEN b.s_avg_precursorfwhm_minbound AND b.s_avg_precursorfwhm_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	SET @errormessage = 's_precursor_avgdelta table population for fwhm ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_avgdelta
		SELECT 's_precursor_avgdelta_mhp_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_precursorgroup_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursormhp
				FROM fragmentfile ff1 
				WHERE ff1.precursormhp BETWEEN b.s_avg_precursormhp_minbound AND b.s_avg_precursormhp_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	SET @errormessage = 's_precursor_avgdelta table population for mhp ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	CREATE UNIQUE CLUSTERED INDEX s_precursor_avgdelta_measure_peptidesequence_idx ON s_precursor_avgdelta (measure, peptidesequence);
*/

/*
	-- s_precursor_wavgdelta
	-- commented because populated.

	IF OBJECT_ID (N's_precursor_wavgdelta', N'U') IS NOT NULL BEGIN
		DROP TABLE s_precursor_wavgdelta
	END

	--DROP INDEX s_precursor_wavgdelta_measure_peptidesequence_idx ON s_precursor_wavgdelta;

	CREATE TABLE s_precursor_wavgdelta (
		measure varchar(64),
		peptidesequence varchar(128),
		match bigint NOT NULL,
		total bigint NOT NULL
	)

	INSERT INTO s_precursor_wavgdelta
		SELECT 's_precursor_wavgdelta_mz_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_peptideweightedaverages_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursormz
				FROM fragmentfile ff1 
				WHERE ff1.precursormz BETWEEN b.s_wavg_precursormz_minbound AND b.s_wavg_precursormz_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	SET @errormessage = 's_precursor_wavgdelta table population for mz ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_wavgdelta
		SELECT 's_precursor_wavgdelta_rettime_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_peptideweightedaverages_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursorrettime
				FROM fragmentfile ff1 
				WHERE ff1.precursorrettime BETWEEN b.s_wavg_precursorrettime_minbound AND b.s_wavg_precursorrettime_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	SET @errormessage = 's_precursor_wavgdelta table population for rettime ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_wavgdelta
		SELECT 's_precursor_wavgdelta_mobility_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_peptideweightedaverages_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursormobility
				FROM fragmentfile ff1 
				WHERE ff1.precursormobility BETWEEN b.s_wavg_precursormobility_minbound AND b.s_wavg_precursormobility_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	SET @errormessage = 's_precursor_wavgdelta table population for mobility ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_wavgdelta
		SELECT 's_precursor_wavgdelta_intensity_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_peptideweightedaverages_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursorintensity
				FROM fragmentfile ff1 
				WHERE ff1.precursorintensity BETWEEN b.s_wavg_precursorintensity_minbound AND b.s_wavg_precursorintensity_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	SET @errormessage = 's_precursor_wavgdelta table population for intensity ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_wavgdelta
		SELECT 's_precursor_wavgdelta_deltappm_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_peptideweightedaverages_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursordeltappm
				FROM fragmentfile ff1 
				WHERE ff1.precursordeltappm BETWEEN b.s_wavg_precursordeltappm_minbound AND b.s_wavg_precursordeltappm_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	SET @errormessage = 's_precursor_wavgdelta table population for deltappm ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_wavgdelta
		SELECT 's_precursor_wavgdelta_fwhm_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_peptideweightedaverages_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursorfwhm
				FROM fragmentfile ff1 
				WHERE ff1.precursorfwhm BETWEEN b.s_wavg_precursorfwhm_minbound AND b.s_wavg_precursorfwhm_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	SET @errormessage = 's_precursor_wavgdelta table population for fwhm ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_precursor_wavgdelta
		SELECT 's_precursor_wavgdelta_mhp_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
		FROM s_precursorgroup spg
		INNER JOIN s_peptideweightedaverages_bounds b on spg.peptidesequence = b.peptidesequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.precursormhp
				FROM fragmentfile ff1 
				WHERE ff1.precursormhp BETWEEN b.s_wavg_precursormhp_minbound AND b.s_wavg_precursormhp_maxbound
				AND ff1.peptidesequence = spg.peptidesequence
			) total
		) matchcount

	SET @errormessage = 's_precursor_wavgdelta table population for mhp ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	CREATE UNIQUE CLUSTERED INDEX s_precursor_wavgdelta_measure_peptidesequence_idx ON s_precursor_wavgdelta (measure, peptidesequence);

	*/


	/*
	
	-- Create permanent table to create bounds binning for each fragment and measure. product averages
	IF OBJECT_ID (N's_productgroup_bounds', N'U') IS NOT NULL BEGIN
		DROP TABLE s_productgroup_bounds
	END

	-- Table to store mid bounds between average centre points in order to easily determine which values are closest (euclidian distance) to each average centre point.
	CREATE TABLE s_productgroup_bounds (
		fragmentsequence varchar(128) NOT NULL UNIQUE NONCLUSTERED(fragmentsequence),
		s_avg_productmz_minbound numeric(18,6),
		s_avg_productmz_maxbound numeric(18,6),
		s_avg_productrettime_minbound numeric(18,6),
		s_avg_productrettime_maxbound numeric(18,6),
		s_avg_productmobility_minbound numeric(18,6),
		s_avg_productmobility_maxbound numeric(18,6),
		s_avg_productintensity_minbound numeric(18,6),
		s_avg_productintensity_maxbound numeric(18,6),
		s_avg_productdeltappm_minbound numeric(18,6),
		s_avg_productdeltappm_maxbound numeric(18,6),
		s_avg_productfwhm_minbound numeric(18,6),
		s_avg_productfwhm_maxbound numeric(18,6),
		s_avg_productmhp_minbound numeric(18,6),
		s_avg_productmhp_maxbound numeric(18,6)
	)

	-- Populate above table with known sequences
	INSERT INTO s_productgroup_bounds (fragmentsequence)
		SELECT fragmentsequence FROM s_productgroup

	-- Create permanent table to create bounds binning for each fragment and measure. product weighted averages
	IF OBJECT_ID (N's_fragmentweightedaverages_bounds', N'U') IS NOT NULL BEGIN
		DROP TABLE s_fragmentweightedaverages_bounds
	END

	-- Table to store mid bounds between average centre points in order to easily determine which values are closest (euclidian distance) to each average centre point.
	CREATE TABLE s_fragmentweightedaverages_bounds (
		fragmentsequence varchar(128) UNIQUE CLUSTERED,
		s_wavg_productmz_minbound numeric(18,6),
		s_wavg_productmz_maxbound numeric(18,6),
		s_wavg_productrettime_minbound numeric(18,6),
		s_wavg_productrettime_maxbound numeric(18,6),
		s_wavg_productmobility_minbound numeric(18,6),
		s_wavg_productmobility_maxbound numeric(18,6),
		s_wavg_productintensity_minbound numeric(18,6),
		s_wavg_productintensity_maxbound numeric(18,6),
		s_wavg_productdeltappm_minbound numeric(18,6),
		s_wavg_productdeltappm_maxbound numeric(18,6),
		s_wavg_productfwhm_minbound numeric(18,6),
		s_wavg_productfwhm_maxbound numeric(18,6),
		s_wavg_productmhp_minbound  numeric(18,6),
		s_wavg_productmhp_maxbound  numeric(18,6)
	)

	INSERT INTO s_fragmentweightedaverages_bounds (fragmentsequence)
		SELECT fragmentsequence FROM s_fragmentweightedaverages

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_avg_productmz', 's_productgroup'
	UPDATE s_productgroup_bounds
	SET s_avg_productmz_minbound = m.value_min,
		s_avg_productmz_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_avg_productrettime', 's_productgroup'
	UPDATE s_productgroup_bounds
	SET s_avg_productrettime_minbound = m.value_min,
		s_avg_productrettime_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_avg_productmobility', 's_productgroup'
	UPDATE s_productgroup_bounds
	SET s_avg_productmobility_minbound = m.value_min,
		s_avg_productmobility_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_avg_productintensity', 's_productgroup'
	UPDATE s_productgroup_bounds
	SET s_avg_productintensity_minbound = m.value_min,
		s_avg_productintensity_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_avg_productdeltappm', 's_productgroup'
	UPDATE s_productgroup_bounds
	SET s_avg_productdeltappm_minbound = m.value_min,
		s_avg_productdeltappm_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_avg_productfwhm', 's_productgroup'
	UPDATE s_productgroup_bounds
	SET s_avg_productfwhm_minbound = m.value_min,
		s_avg_productfwhm_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_avg_productmhp', 's_productgroup'
	UPDATE s_productgroup_bounds
	SET s_avg_productmhp_minbound = m.value_min,
		s_avg_productmhp_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_wavg_productmz', 's_fragmentweightedaverages'
	UPDATE s_fragmentweightedaverages_bounds
	SET s_wavg_productmz_minbound = m.value_min,
		s_wavg_productmz_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_wavg_productrettime', 's_fragmentweightedaverages'
	UPDATE s_fragmentweightedaverages_bounds
	SET s_wavg_productrettime_minbound = m.value_min,
		s_wavg_productrettime_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_wavg_productmobility', 's_fragmentweightedaverages'
	UPDATE s_fragmentweightedaverages_bounds
	SET s_wavg_productmobility_minbound = m.value_min,
		s_wavg_productmobility_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_wavg_productintensity', 's_fragmentweightedaverages'
	UPDATE s_fragmentweightedaverages_bounds
	SET s_wavg_productintensity_minbound = m.value_min,
		s_wavg_productintensity_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_wavg_productdeltappm', 's_fragmentweightedaverages'
	UPDATE s_fragmentweightedaverages_bounds
	SET s_wavg_productdeltappm_minbound = m.value_min,
		s_wavg_productdeltappm_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_wavg_productfwhm', 's_fragmentweightedaverages'
	UPDATE s_fragmentweightedaverages_bounds
	SET s_wavg_productfwhm_minbound = m.value_min,
		s_wavg_productfwhm_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 'fragmentsequence', 's_wavg_productmhp', 's_fragmentweightedaverages'
	UPDATE s_fragmentweightedaverages_bounds
	SET s_wavg_productmhp_minbound = m.value_min,
		s_wavg_productmhp_maxbound = m.value_max
	FROM @midpoint m
	WHERE fragmentsequence = m.sequence
	DELETE @midpoint

	SET @errormessage = 's_fragmentweightedaverages_bounds table population ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	-- s_fragmentweightedaverages_bounds table population 0:8:01
	
	*/	







	-- s_product_avgdelta
	-- commented because populated.

	IF OBJECT_ID (N's_product_avgdelta', N'U') IS NOT NULL BEGIN
		DROP TABLE s_product_avgdelta
	END

	--DROP INDEX s_product_avgdelta_measure_fragmentsequence_idx ON s_product_avgdelta;

	CREATE TABLE s_product_avgdelta (
		measure varchar(64),
		fragmentsequence varchar(128),
		match bigint NOT NULL,
		total bigint NOT NULL
	)
	DELETE FROM s_product_avgdelta

	INSERT INTO s_product_avgdelta
		SELECT 's_product_avgdeltamz_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_productgroup_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productmz
				FROM fragmentfile ff1 
				WHERE ff1.productmz BETWEEN b.s_avg_productmz_minbound AND b.s_avg_productmz_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	--  time 01:22
	SET @errormessage = 's_product_avgdelta table population for mz ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;
	
	INSERT INTO s_product_avgdelta
		SELECT 's_product_avgdelta_rettime_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_productgroup_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productrettime
				FROM fragmentfile ff1 
				WHERE ff1.productrettime BETWEEN b.s_avg_productrettime_minbound AND b.s_avg_productrettime_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	SET @errormessage = 's_product_avgdelta table population for rettime ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_avgdelta
		SELECT 's_product_avgdelta_mobility_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_productgroup_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productmobility
				FROM fragmentfile ff1 
				WHERE ff1.productmobility BETWEEN b.s_avg_productmobility_minbound AND b.s_avg_productmobility_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	SET @errormessage = 's_product_avgdelta table population for mobility ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_avgdelta
		SELECT 's_product_avgdelta_intensity_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_productgroup_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productintensity
				FROM fragmentfile ff1 
				WHERE ff1.productintensity BETWEEN b.s_avg_productintensity_minbound AND b.s_avg_productintensity_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	SET @errormessage = 's_product_avgdelta table population for intensity ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_avgdelta
		SELECT 's_product_avgdelta_deltappm_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_productgroup_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productdeltappm
				FROM fragmentfile ff1 
				WHERE ff1.productdeltappm BETWEEN b.s_avg_productdeltappm_minbound AND b.s_avg_productdeltappm_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	SET @errormessage = 's_product_avgdelta table population for deltappm ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_avgdelta
		SELECT 's_product_avgdelta_fwhm_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_productgroup_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productfwhm
				FROM fragmentfile ff1 
				WHERE ff1.productfwhm BETWEEN b.s_avg_productfwhm_minbound AND b.s_avg_productfwhm_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	SET @errormessage = 's_product_avgdelta table population for fwhm ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_avgdelta
		SELECT 's_product_avgdelta_mhp_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_productgroup_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productmhp
				FROM fragmentfile ff1 
				WHERE ff1.productmhp BETWEEN b.s_avg_productmhp_minbound AND b.s_avg_productmhp_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	SET @errormessage = 's_product_avgdelta table population for mhp ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	CREATE UNIQUE CLUSTERED INDEX s_product_avgdelta_measure_fragmentsequence_idx ON s_product_avgdelta (measure, fragmentsequence);



	-- s_product_wavgdelta
	-- commented because populated.
	select top 1 * from s_fragmentweightedaverages_bounds

	IF OBJECT_ID (N's_product_wavgdelta', N'U') IS NOT NULL BEGIN
		DROP TABLE s_product_wavgdelta
	END

	--DROP INDEX s_product_wavgdelta_measure_fragmentsequence_idx ON s_product_wavgdelta;

	CREATE TABLE s_product_wavgdelta (
		measure varchar(64),
		fragmentsequence varchar(128),
		match bigint NOT NULL,
		total bigint NOT NULL
	)

	INSERT INTO s_product_wavgdelta
		SELECT 's_product_wavgdelta_mz_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_fragmentweightedaverages_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productmz
				FROM fragmentfile ff1 
				WHERE ff1.productmz BETWEEN b.s_wavg_productmz_minbound AND b.s_wavg_productmz_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	SET @errormessage = 's_product_wavgdelta table population for mz ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_wavgdelta
		SELECT 's_product_wavgdelta_rettime_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_fragmentweightedaverages_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productrettime
				FROM fragmentfile ff1 
				WHERE ff1.productrettime BETWEEN b.s_wavg_productrettime_minbound AND b.s_wavg_productrettime_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	SET @errormessage = 's_product_wavgdelta table population for rettime ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_wavgdelta
		SELECT 's_product_wavgdelta_mobility_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_fragmentweightedaverages_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productmobility
				FROM fragmentfile ff1 
				WHERE ff1.productmobility BETWEEN b.s_wavg_productmobility_minbound AND b.s_wavg_productmobility_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	SET @errormessage = 's_product_wavgdelta table population for mobility ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_wavgdelta
		SELECT 's_product_wavgdelta_intensity_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_fragmentweightedaverages_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productintensity
				FROM fragmentfile ff1 
				WHERE ff1.productintensity BETWEEN b.s_wavg_productintensity_minbound AND b.s_wavg_productintensity_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	SET @errormessage = 's_product_wavgdelta table population for intensity ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_wavgdelta
		SELECT 's_product_wavgdelta_deltappm_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_fragmentweightedaverages_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productdeltappm
				FROM fragmentfile ff1 
				WHERE ff1.productdeltappm BETWEEN b.s_wavg_productdeltappm_minbound AND b.s_wavg_productdeltappm_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	SET @errormessage = 's_product_wavgdelta table population for deltappm ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_wavgdelta
		SELECT 's_product_wavgdelta_fwhm_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_fragmentweightedaverages_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productfwhm
				FROM fragmentfile ff1 
				WHERE ff1.productfwhm BETWEEN b.s_wavg_productfwhm_minbound AND b.s_wavg_productfwhm_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	SET @errormessage = 's_product_wavgdelta table population for fwhm ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	INSERT INTO s_product_wavgdelta
		SELECT 's_product_wavgdelta_mhp_r', spg.fragmentsequence, matchcount.value, spg.fragmentfrequency
		FROM s_productgroup spg
		INNER JOIN s_fragmentweightedaverages_bounds b on spg.fragmentsequence = b.fragmentsequence
		CROSS APPLY
		(
			SELECT count(*) value 
			FROM (
				SELECT ff1.productmhp
				FROM fragmentfile ff1 
				WHERE ff1.productmhp BETWEEN b.s_wavg_productmhp_minbound AND b.s_wavg_productmhp_maxbound
				AND ff1.fragmentsequence = spg.fragmentsequence
			) total
		) matchcount

	SET @errormessage = 's_product_wavgdelta table population for mhp ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	CREATE UNIQUE CLUSTERED INDEX s_product_wavgdelta_measure_fragmentsequence_idx ON s_product_wavgdelta (measure, fragmentsequence);


	/*
		s_product_avgdelta table population for mz 0:1:06
		s_product_avgdelta table population for rettime 0:1:45
		s_product_avgdelta table population for mobility 0:2:25
		s_product_avgdelta table population for intensity 0:3:04
		s_product_avgdelta table population for deltappm 0:3:44
		s_product_avgdelta table population for fwhm 0:4:24
		s_product_avgdelta table population for mhp 0:5:04
		s_product_wavgdelta table population for mz 0:6:16
		s_product_wavgdelta table population for rettime 0:6:55
		s_product_wavgdelta table population for mobility 0:7:35
		s_product_wavgdelta table population for intensity 0:8:14
		s_product_wavgdelta table population for deltappm 0:8:53
		s_product_wavgdelta table population for fwhm 0:9:33
		s_product_wavgdelta table population for mhp 0:10:13
*/














END

IF (@resetmeasurecontributiontable = 0) BEGIN
	RAISERROR ('Using existing table measurecontribution', 0, 1) WITH NOWAIT;

END ELSE BEGIN
	RAISERROR ('Resetting table measurecontribution', 0, 1) WITH NOWAIT;
	
	IF OBJECT_ID (N'measurecontribution', N'U') IS NOT NULL BEGIN
		DROP TABLE measurecontribution;
	END

	CREATE TABLE measurecontribution (
		ID bigint identity PRIMARY KEY,
		peptidesequence varchar(128) NOT NULL,
		fragmentsequence varchar(128) NOT NULL,
		peptidefragmentfrequency bigint NOT NULL,
		peptidefrequency bigint NOT NULL DEFAULT 0,
		fragmentfrequency bigint NOT NULL DEFAULT 0,
		peptidefragmentproteincount bigint NOT NULL DEFAULT 0,
		peptideproteincount bigint NOT NULL DEFAULT 0,
		fragmentproteincount bigint NOT NULL DEFAULT 0,
		s_min_precursormz numeric(18,6) NOT NULL DEFAULT 0, s_avg_precursormz numeric(18,6) NOT NULL DEFAULT 0, s_wavg_precursormz numeric(18,6) NOT NULL DEFAULT 0, s_max_precursormz numeric(18,6) NOT NULL DEFAULT 0, s_std_precursormz numeric(18,6) NOT NULL DEFAULT 0, s_range_precursormz_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_precursormz_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_precursormz_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_precursorrettime numeric(18,6) NOT NULL DEFAULT 0, s_avg_precursorrettime numeric(18,6) NOT NULL DEFAULT 0, s_wavg_precursorrettime numeric(18,6) NOT NULL DEFAULT 0, s_max_precursorrettime numeric(18,6) NOT NULL DEFAULT 0, s_std_precursorrettime numeric(18,6) NOT NULL DEFAULT 0, s_range_precursorrettime_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_precursorrettime_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_precursorrettime_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_precursormobility numeric(18,6) NOT NULL DEFAULT 0, s_avg_precursormobility numeric(18,6) NOT NULL DEFAULT 0, s_wavg_precursormobility numeric(18,6) NOT NULL DEFAULT 0, s_max_precursormobility numeric(18,6) NOT NULL DEFAULT 0, s_std_precursormobility numeric(18,6) NOT NULL DEFAULT 0, s_range_precursormobility_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_precursormobility_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_precursormobility_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_precursorintensity numeric(18,6) NOT NULL DEFAULT 0, s_avg_precursorintensity numeric(18,6) NOT NULL DEFAULT 0, s_wavg_precursorintensity numeric(18,6) NOT NULL DEFAULT 0, s_max_precursorintensity numeric(18,6) NOT NULL DEFAULT 0, s_std_precursorintensity numeric(18,6) NOT NULL DEFAULT 0, s_range_precursorintensity_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_precursorintensity_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_precursorintensity_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_precursordeltappm numeric(18,6) NOT NULL DEFAULT 0, s_avg_precursordeltappm numeric(18,6) NOT NULL DEFAULT 0, s_wavg_precursordeltappm numeric(18,6) NOT NULL DEFAULT 0, s_max_precursordeltappm numeric(18,6) NOT NULL DEFAULT 0, s_std_precursordeltappm numeric(18,6) NOT NULL DEFAULT 0, s_range_precursordeltappm_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_precursordeltappm_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_precursordeltappm_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_precursorfwhm numeric(18,6) NOT NULL DEFAULT 0, s_avg_precursorfwhm numeric(18,6) NOT NULL DEFAULT 0, s_wavg_precursorfwhm numeric(18,6) NOT NULL DEFAULT 0, s_max_precursorfwhm numeric(18,6) NOT NULL DEFAULT 0, s_std_precursorfwhm numeric(18,6) NOT NULL DEFAULT 0, s_range_precursorfwhm_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_precursorfwhm_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_precursorfwhm_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_precursormhp numeric(18,6) NOT NULL DEFAULT 0, s_avg_precursormhp numeric(18,6) NOT NULL DEFAULT 0, s_wavg_precursormhp numeric(18,6) NOT NULL DEFAULT 0, s_max_precursormhp numeric(18,6) NOT NULL DEFAULT 0, s_std_precursormhp numeric(18,6) NOT NULL DEFAULT 0, s_range_precursormhp_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_precursormhp_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_precursormhp_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_productmz numeric(18,6) NOT NULL DEFAULT 0, s_avg_productmz numeric(18,6) NOT NULL DEFAULT 0, s_wavg_productmz numeric(18,6) NOT NULL DEFAULT 0, s_max_productmz numeric(18,6) NOT NULL DEFAULT 0, s_std_productmz numeric(18,6) NOT NULL DEFAULT 0, s_range_productmz_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_productmz_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_productmz_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_productrettime numeric(18,6) NOT NULL DEFAULT 0, s_avg_productrettime numeric(18,6) NOT NULL DEFAULT 0, s_wavg_productrettime numeric(18,6) NOT NULL DEFAULT 0, s_max_productrettime numeric(18,6) NOT NULL DEFAULT 0, s_std_productrettime numeric(18,6) NOT NULL DEFAULT 0, s_range_productrettime_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_productrettime_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_productrettime_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_productmobility numeric(18,6) NOT NULL DEFAULT 0, s_avg_productmobility numeric(18,6) NOT NULL DEFAULT 0, s_wavg_productmobility numeric(18,6) NOT NULL DEFAULT 0, s_max_productmobility numeric(18,6) NOT NULL DEFAULT 0, s_std_productmobility numeric(18,6) NOT NULL DEFAULT 0, s_range_productmobility_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_productmobility_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_productmobility_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_productintensity numeric(18,6) NOT NULL DEFAULT 0, s_avg_productintensity numeric(18,6) NOT NULL DEFAULT 0, s_wavg_productintensity numeric(18,6) NOT NULL DEFAULT 0, s_max_productintensity numeric(18,6) NOT NULL DEFAULT 0, s_std_productintensity numeric(18,6) NOT NULL DEFAULT 0, s_range_productintensity_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_productintensity_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_productintensity_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_productdeltappm numeric(18,6) NOT NULL DEFAULT 0, s_avg_productdeltappm numeric(18,6) NOT NULL DEFAULT 0, s_wavg_productdeltappm numeric(18,6) NOT NULL DEFAULT 0, s_max_productdeltappm numeric(18,6) NOT NULL DEFAULT 0, s_std_productdeltappm numeric(18,6) NOT NULL DEFAULT 0, s_range_productdeltappm_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_productdeltappm_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_productdeltappm_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_productfwhm numeric(18,6) NOT NULL DEFAULT 0, s_avg_productfwhm numeric(18,6) NOT NULL DEFAULT 0, s_wavg_productfwhm numeric(18,6) NOT NULL DEFAULT 0, s_max_productfwhm numeric(18,6) NOT NULL DEFAULT 0, s_std_productfwhm numeric(18,6) NOT NULL DEFAULT 0, s_range_productfwhm_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_productfwhm_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_productfwhm_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_productmhp numeric(18,6) NOT NULL DEFAULT 0, s_avg_productmhp numeric(18,6) NOT NULL DEFAULT 0, s_wavg_productmhp numeric(18,6) NOT NULL DEFAULT 0, s_max_productmhp numeric(18,6) NOT NULL DEFAULT 0, s_std_productmhp numeric(18,6) NOT NULL DEFAULT 0, s_range_productmhp_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_productmhp_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_productmhp_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_precursormz numeric(18,6) NOT NULL DEFAULT 0, c_avg_precursormz numeric(18,6) NOT NULL DEFAULT 0, c_wavg_precursormz numeric(18,6) NOT NULL DEFAULT 0, c_max_precursormz numeric(18,6) NOT NULL DEFAULT 0, c_std_precursormz numeric(18,6) NOT NULL DEFAULT 0, c_range_precursormz_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_precursormz_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_precursormz_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_precursorrettime numeric(18,6) NOT NULL DEFAULT 0, c_avg_precursorrettime numeric(18,6) NOT NULL DEFAULT 0, c_wavg_precursorrettime numeric(18,6) NOT NULL DEFAULT 0, c_max_precursorrettime numeric(18,6) NOT NULL DEFAULT 0, c_std_precursorrettime numeric(18,6) NOT NULL DEFAULT 0, c_range_precursorrettime_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_precursorrettime_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_precursorrettime_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_precursormobility numeric(18,6) NOT NULL DEFAULT 0, c_avg_precursormobility numeric(18,6) NOT NULL DEFAULT 0, c_wavg_precursormobility numeric(18,6) NOT NULL DEFAULT 0, c_max_precursormobility numeric(18,6) NOT NULL DEFAULT 0, c_std_precursormobility numeric(18,6) NOT NULL DEFAULT 0, c_range_precursormobility_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_precursormobility_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_precursormobility_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_precursorintensity numeric(18,6) NOT NULL DEFAULT 0, c_avg_precursorintensity numeric(18,6) NOT NULL DEFAULT 0, c_wavg_precursorintensity numeric(18,6) NOT NULL DEFAULT 0, c_max_precursorintensity numeric(18,6) NOT NULL DEFAULT 0, c_std_precursorintensity numeric(18,6) NOT NULL DEFAULT 0, c_range_precursorintensity_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_precursorintensity_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_precursorintensity_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_precursordeltappm numeric(18,6) NOT NULL DEFAULT 0, c_avg_precursordeltappm numeric(18,6) NOT NULL DEFAULT 0, c_wavg_precursordeltappm numeric(18,6) NOT NULL DEFAULT 0, c_max_precursordeltappm numeric(18,6) NOT NULL DEFAULT 0, c_std_precursordeltappm numeric(18,6) NOT NULL DEFAULT 0, c_range_precursordeltappm_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_precursordeltappm_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_precursordeltappm_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_precursorfwhm numeric(18,6) NOT NULL DEFAULT 0, c_avg_precursorfwhm numeric(18,6) NOT NULL DEFAULT 0, c_wavg_precursorfwhm numeric(18,6) NOT NULL DEFAULT 0, c_max_precursorfwhm numeric(18,6) NOT NULL DEFAULT 0, c_std_precursorfwhm numeric(18,6) NOT NULL DEFAULT 0, c_range_precursorfwhm_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_precursorfwhm_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_precursorfwhm_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_precursormhp numeric(18,6) NOT NULL DEFAULT 0, c_avg_precursormhp numeric(18,6) NOT NULL DEFAULT 0, c_wavg_precursormhp numeric(18,6) NOT NULL DEFAULT 0, c_max_precursormhp numeric(18,6) NOT NULL DEFAULT 0, c_std_precursormhp numeric(18,6) NOT NULL DEFAULT 0, c_range_precursormhp_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_precursormhp_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_precursormhp_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_productmz numeric(18,6) NOT NULL DEFAULT 0, c_avg_productmz numeric(18,6) NOT NULL DEFAULT 0, c_wavg_productmz numeric(18,6) NOT NULL DEFAULT 0, c_max_productmz numeric(18,6) NOT NULL DEFAULT 0, c_std_productmz numeric(18,6) NOT NULL DEFAULT 0, c_range_productmz_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_productmz_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_productmz_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_productrettime numeric(18,6) NOT NULL DEFAULT 0, c_avg_productrettime numeric(18,6) NOT NULL DEFAULT 0, c_wavg_productrettime numeric(18,6) NOT NULL DEFAULT 0, c_max_productrettime numeric(18,6) NOT NULL DEFAULT 0, c_std_productrettime numeric(18,6) NOT NULL DEFAULT 0, c_range_productrettime_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_productrettime_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_productrettime_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_productmobility numeric(18,6) NOT NULL DEFAULT 0, c_avg_productmobility numeric(18,6) NOT NULL DEFAULT 0, c_wavg_productmobility numeric(18,6) NOT NULL DEFAULT 0, c_max_productmobility numeric(18,6) NOT NULL DEFAULT 0, c_std_productmobility numeric(18,6) NOT NULL DEFAULT 0, c_range_productmobility_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_productmobility_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_productmobility_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_productintensity numeric(18,6) NOT NULL DEFAULT 0, c_avg_productintensity numeric(18,6) NOT NULL DEFAULT 0, c_wavg_productintensity numeric(18,6) NOT NULL DEFAULT 0, c_max_productintensity numeric(18,6) NOT NULL DEFAULT 0, c_std_productintensity numeric(18,6) NOT NULL DEFAULT 0, c_range_productintensity_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_productintensity_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_productintensity_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_productdeltappm numeric(18,6) NOT NULL DEFAULT 0, c_avg_productdeltappm numeric(18,6) NOT NULL DEFAULT 0, c_wavg_productdeltappm numeric(18,6) NOT NULL DEFAULT 0, c_max_productdeltappm numeric(18,6) NOT NULL DEFAULT 0, c_std_productdeltappm numeric(18,6) NOT NULL DEFAULT 0, c_range_productdeltappm_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_productdeltappm_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_productdeltappm_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_productfwhm numeric(18,6) NOT NULL DEFAULT 0, c_avg_productfwhm numeric(18,6) NOT NULL DEFAULT 0, c_wavg_productfwhm numeric(18,6) NOT NULL DEFAULT 0, c_max_productfwhm numeric(18,6) NOT NULL DEFAULT 0, c_std_productfwhm numeric(18,6) NOT NULL DEFAULT 0, c_range_productfwhm_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_productfwhm_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_productfwhm_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_productmhp numeric(18,6) NOT NULL DEFAULT 0, c_avg_productmhp numeric(18,6) NOT NULL DEFAULT 0, c_wavg_productmhp numeric(18,6) NOT NULL DEFAULT 0, c_max_productmhp numeric(18,6) NOT NULL DEFAULT 0, c_std_productmhp numeric(18,6) NOT NULL DEFAULT 0, c_range_productmhp_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_productmhp_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_productmhp_r numeric(6,6) NOT NULL DEFAULT 0, 

		c_min_intensityratio1 numeric(18,6) NOT NULL DEFAULT 0, c_avg_intensityratio1 numeric(18,6) NOT NULL DEFAULT 0, c_wavg_intensityratio1 numeric(18,6) NOT NULL DEFAULT 0, c_max_intensityratio1 numeric(18,6) NOT NULL DEFAULT 0, c_std_intensityratio1 numeric(18,6) NOT NULL DEFAULT 0, c_range_intensityratio1_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_intensityratio1_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_intensityratio1_r numeric(6,6) NOT NULL DEFAULT 0, 
		s_min_intensityratio2 numeric(18,6) NOT NULL DEFAULT 0, s_avg_intensityratio2 numeric(18,6) NOT NULL DEFAULT 0, s_wavg_intensityratio2 numeric(18,6) NOT NULL DEFAULT 0, s_max_intensityratio2 numeric(18,6) NOT NULL DEFAULT 0, s_std_intensityratio2 numeric(18,6) NOT NULL DEFAULT 0, s_range_intensityratio2_r numeric(6,6) NOT NULL DEFAULT 0, s_avgdelta_intensityratio2_r numeric(6,6) NOT NULL DEFAULT 0, s_wavgdelta_intensityratio2_r numeric(6,6) NOT NULL DEFAULT 0, 
		c_min_intensityratio2 numeric(18,6) NOT NULL DEFAULT 0, c_avg_intensityratio2 numeric(18,6) NOT NULL DEFAULT 0, c_wavg_intensityratio2 numeric(18,6) NOT NULL DEFAULT 0, c_max_intensityratio2 numeric(18,6) NOT NULL DEFAULT 0, c_std_intensityratio2 numeric(18,6) NOT NULL DEFAULT 0, c_range_intensityratio2_r numeric(6,6) NOT NULL DEFAULT 0, c_avgdelta_intensityratio2_r numeric(6,6) NOT NULL DEFAULT 0, c_wavgdelta_intensityratio2_r numeric(6,6) NOT NULL DEFAULT 0, 

		measureprocesseddate datetime NULL, contributionprocessed datetime NULL
	)

	CREATE UNIQUE NONCLUSTERED INDEX measurecontribution_fragmentsequence_idx ON measurecontribution (peptidesequence, fragmentsequence);

	--CREATE INDEX measurecontribution_peptidesequence_idx ON measurecontribution (peptidesequence);  
	--CREATE INDEX measurecontribution_fragmentsequence_idx ON measurecontribution (fragmentsequence);  

	--Could use a where clause here to only include certain datasets

	RAISERROR ('Initial population of measurecontribution', 0, 1) WITH NOWAIT;

	INSERT INTO measurecontribution (peptidesequence, fragmentsequence, peptidefragmentfrequency)
		SELECT  peptidesequence, fragmentsequence, count(*) as peptidefragmentfrequency
		FROM fragmentfile
		GROUP BY peptidesequence, fragmentsequence 
		ORDER BY count(*) DESC, len(peptidesequence), peptidesequence, len(fragmentsequence), fragmentsequence
END

IF (@updatemeasures = 0) BEGIN
	RAISERROR ('Using existing measure contribution table', 0, 1) WITH NOWAIT;
END ELSE BEGIN
	RAISERROR ('Updating measure contribution table', 0, 1) WITH NOWAIT;	
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	UPDATE mc SET
		mc.peptidefrequency = ffp.peptidefrequency,
		mc.s_min_precursormz = ffp.s_min_precursormz,
		mc.s_avg_precursormz = ffp.s_avg_precursormz,
		mc.s_max_precursormz = ffp.s_max_precursormz,
		mc.s_min_precursorrettime = ffp.s_min_precursorrettime,
		mc.s_avg_precursorrettime = ffp.s_avg_precursorrettime,
		mc.s_max_precursorrettime = ffp.s_max_precursorrettime,
		mc.s_min_precursormobility = ffp.s_min_precursormobility,
		mc.s_avg_precursormobility = ffp.s_avg_precursormobility,
		mc.s_max_precursormobility = ffp.s_max_precursormobility,
		mc.s_min_precursorintensity = ffp.s_min_precursorintensity,
		mc.s_avg_precursorintensity = ffp.s_avg_precursorintensity,
		mc.s_max_precursorintensity = ffp.s_max_precursorintensity,
		mc.s_min_precursordeltappm = ffp.s_min_precursordeltappm,
		mc.s_avg_precursordeltappm = ffp.s_avg_precursordeltappm,
		mc.s_max_precursordeltappm = ffp.s_max_precursordeltappm,
		mc.s_min_precursorfwhm = ffp.s_min_precursorfwhm,
		mc.s_avg_precursorfwhm = ffp.s_avg_precursorfwhm,
		mc.s_max_precursorfwhm = ffp.s_max_precursorfwhm,
		mc.s_min_precursormhp = ffp.s_min_precursormhp,
		mc.s_avg_precursormhp = ffp.s_avg_precursormhp,
		mc.s_max_precursormhp = ffp.s_max_precursormhp
	FROM measurecontribution mc 
	INNER JOIN s_precursorgroup ffp on mc.peptidesequence = ffp.peptidesequence

	SET @errormessage = 'mc update for s_precursorgroup ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	UPDATE mc SET
		mc.fragmentfrequency = fff.fragmentfrequency,
		mc.s_min_productmz = fff.s_min_productmz,
		mc.s_avg_productmz = fff.s_avg_productmz,
		mc.s_max_productmz = fff.s_max_productmz,
		mc.s_min_productrettime = fff.s_min_productrettime,
		mc.s_avg_productrettime = fff.s_avg_productrettime,
		mc.s_max_productrettime = fff.s_max_productrettime,
		mc.s_min_productmobility = fff.s_min_productmobility,
		mc.s_avg_productmobility = fff.s_avg_productmobility,
		mc.s_max_productmobility = fff.s_max_productmobility,
		mc.s_min_productintensity = fff.s_min_productintensity,
		mc.s_avg_productintensity = fff.s_avg_productintensity,
		mc.s_max_productintensity = fff.s_max_productintensity,
		mc.s_min_productdeltappm = fff.s_min_productdeltappm,
		mc.s_avg_productdeltappm = fff.s_avg_productdeltappm,
		mc.s_max_productdeltappm = fff.s_max_productdeltappm,
		mc.s_min_productfwhm = fff.s_min_productfwhm,
		mc.s_avg_productfwhm = fff.s_avg_productfwhm,
		mc.s_max_productfwhm = fff.s_max_productfwhm,
		mc.s_min_productmhp = fff.s_min_productmhp,
		mc.s_avg_productmhp = fff.s_avg_productmhp,
		mc.s_max_productmhp = fff.s_max_productmhp
	FROM measurecontribution mc 
	INNER JOIN s_productgroup fff on mc.fragmentsequence = fff.fragmentsequence

	SET @errormessage = 'mc update for s_productgroup ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	UPDATE mc SET
		mc.peptidefragmentfrequency = ffpf.peptidefrequency,
		mc.c_min_precursormz = ffpf.c_min_precursormz,
		mc.c_avg_precursormz = ffpf.c_avg_precursormz,
		mc.c_max_precursormz = ffpf.c_max_precursormz,
		mc.c_min_precursorrettime = ffpf.c_min_precursorrettime,
		mc.c_avg_precursorrettime = ffpf.c_avg_precursorrettime,
		mc.c_max_precursorrettime = ffpf.c_max_precursorrettime,
		mc.c_min_precursormobility = ffpf.c_min_precursormobility,
		mc.c_avg_precursormobility = ffpf.c_avg_precursormobility,
		mc.c_max_precursormobility = ffpf.c_max_precursormobility,
		mc.c_min_precursorintensity = ffpf.c_min_precursorintensity,
		mc.c_avg_precursorintensity = ffpf.c_avg_precursorintensity,
		mc.c_max_precursorintensity = ffpf.c_max_precursorintensity,
		mc.c_min_precursordeltappm = ffpf.c_min_precursordeltappm,
		mc.c_avg_precursordeltappm = ffpf.c_avg_precursordeltappm,
		mc.c_max_precursordeltappm = ffpf.c_max_precursordeltappm,
		mc.c_min_precursorfwhm = ffpf.c_min_precursorfwhm,
		mc.c_avg_precursorfwhm = ffpf.c_avg_precursorfwhm,
		mc.c_max_precursorfwhm = ffpf.c_max_precursorfwhm,
		mc.c_min_precursormhp = ffpf.c_min_precursormhp,
		mc.c_avg_precursormhp = ffpf.c_avg_precursormhp,
		mc.c_max_precursormhp = ffpf.c_max_precursormhp,
		mc.c_min_productmz = ffpf.c_min_productmz,
		mc.c_avg_productmz = ffpf.c_avg_productmz,
		mc.c_max_productmz = ffpf.c_max_productmz,
		mc.c_min_productrettime = ffpf.c_min_productrettime,
		mc.c_avg_productrettime = ffpf.c_avg_productrettime,
		mc.c_max_productrettime = ffpf.c_max_productrettime,
		mc.c_min_productmobility = ffpf.c_min_productmobility,
		mc.c_avg_productmobility = ffpf.c_avg_productmobility,
		mc.c_max_productmobility = ffpf.c_max_productmobility,
		mc.c_min_productintensity = ffpf.c_min_productintensity,
		mc.c_avg_productintensity = ffpf.c_avg_productintensity,
		mc.c_max_productintensity = ffpf.c_max_productintensity,
		mc.c_min_productdeltappm = ffpf.c_min_productdeltappm,
		mc.c_avg_productdeltappm = ffpf.c_avg_productdeltappm,
		mc.c_max_productdeltappm = ffpf.c_max_productdeltappm,
		mc.c_min_productfwhm = ffpf.c_min_productfwhm,
		mc.c_avg_productfwhm = ffpf.c_avg_productfwhm,
		mc.c_max_productfwhm = ffpf.c_max_productfwhm,
		mc.c_min_productmhp = ffpf.c_min_productmhp,
		mc.c_avg_productmhp = ffpf.c_avg_productmhp,
		mc.c_max_productmhp = ffpf.c_max_productmhp
	FROM measurecontribution mc 
	INNER JOIN c_precursorproductgroup ffpf on mc.peptidesequence = ffpf.peptidesequence and mc.fragmentsequence = ffpf.fragmentsequence

	SET @errormessage = 'mc update for c_precursorproductgroup ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	UPDATE mc SET
		mc.peptideproteincount = s_peptideweightedaverages.peptideproteincount,
		mc.s_wavg_precursormz = s_peptideweightedaverages.s_wavg_precursormz,
		mc.s_wavg_precursorrettime = s_peptideweightedaverages.s_wavg_precursorrettime,
		mc.s_wavg_precursormobility = s_peptideweightedaverages.s_wavg_precursormobility,
		mc.s_wavg_precursorintensity =  s_peptideweightedaverages.s_wavg_precursorintensity,
		mc.s_wavg_precursordeltappm = s_peptideweightedaverages.s_wavg_precursordeltappm,
		mc.s_wavg_precursorfwhm = s_peptideweightedaverages.s_wavg_precursorfwhm,
		mc.s_wavg_precursormhp = s_peptideweightedaverages.s_wavg_precursormhp
		FROM measurecontribution mc
		INNER JOIN s_peptideweightedaverages s_peptideweightedaverages ON mc.peptidesequence = s_peptideweightedaverages.peptidesequence

	SET @errormessage = 'mc update for peptide weighted averages ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	UPDATE mc SET
		mc.fragmentproteincount = s_fragmentweightedaverages.fragmentproteincount,
		mc.s_wavg_productmz = s_fragmentweightedaverages.s_wavg_productmz,
		mc.s_wavg_productrettime = s_fragmentweightedaverages.s_wavg_productrettime,
		mc.s_wavg_productmobility = s_fragmentweightedaverages.s_wavg_productmobility,
		mc.s_wavg_productintensity =  s_fragmentweightedaverages.s_wavg_productintensity,
		mc.s_wavg_productdeltappm = s_fragmentweightedaverages.s_wavg_productdeltappm,
		mc.s_wavg_productfwhm = s_fragmentweightedaverages.s_wavg_productfwhm,
		mc.s_wavg_productmhp = s_fragmentweightedaverages.s_wavg_productmhp
		FROM measurecontribution mc
		INNER JOIN s_fragmentweightedaverages s_fragmentweightedaverages ON mc.fragmentsequence = s_fragmentweightedaverages.fragmentsequence

	SET @errormessage = 'mc update for fragment weighted averages ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	UPDATE mc SET
		mc.peptidefragmentproteincount = c_peptideweightedaverages.peptideproteincount,
		mc.c_wavg_precursormz = c_peptideweightedaverages.c_wavg_precursormz,
		mc.c_wavg_precursorrettime = c_peptideweightedaverages.c_wavg_precursorrettime,
		mc.c_wavg_precursormobility = c_peptideweightedaverages.c_wavg_precursormobility,
		mc.c_wavg_precursorintensity =  c_peptideweightedaverages.c_wavg_precursorintensity,
		mc.c_wavg_precursordeltappm = c_peptideweightedaverages.c_wavg_precursordeltappm,
		mc.c_wavg_precursorfwhm = c_peptideweightedaverages.c_wavg_precursorfwhm,
		mc.c_wavg_precursormhp = c_peptideweightedaverages.c_wavg_precursormhp
		FROM measurecontribution mc
		INNER JOIN c_peptideweightedaverages c_peptideweightedaverages ON mc.peptidesequence = c_peptideweightedaverages.peptidesequence and  mc.fragmentsequence = c_peptideweightedaverages.fragmentsequence

	SET @errormessage = 'mc update for peptide weighted averages based on peptide/fragment matching ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	UPDATE mc SET
		mc.c_wavg_productmz = c_fragmentweightedaverages.c_wavg_productmz,
		mc.c_wavg_productrettime = c_fragmentweightedaverages.c_wavg_productrettime,
		mc.c_wavg_productmobility = c_fragmentweightedaverages.c_wavg_productmobility,
		mc.c_wavg_productintensity =  c_fragmentweightedaverages.c_wavg_productintensity,
		mc.c_wavg_productdeltappm = c_fragmentweightedaverages.c_wavg_productdeltappm,
		mc.c_wavg_productfwhm = c_fragmentweightedaverages.c_wavg_productfwhm,
		mc.c_wavg_productmhp = c_fragmentweightedaverages.c_wavg_productmhp
		FROM measurecontribution mc
		INNER JOIN c_fragmentweightedaverages c_fragmentweightedaverages ON mc.peptidesequence = c_fragmentweightedaverages.peptidesequence and  mc.fragmentsequence = c_fragmentweightedaverages.fragmentsequence

	SET @errormessage = 'mc update for fragment weighted averages based on peptide/fragment matching ' + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	UPDATE measurecontribution SET measureprocesseddate = getdate() WHERE measureprocesseddate IS NULL;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END

IF (@calculatecontribution = 0) BEGIN
	RAISERROR ('Using existing contribution calculations', 0, 1) WITH NOWAIT;
END ELSE BEGIN
	RAISERROR ('Recalculating contribution calculations', 0, 1) WITH NOWAIT;	
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	PRINT 'Calculating measurement contribution to sequence identification';
	DECLARE @nonredundantrows bigint; SET @nonredundantrows = 0;
	DECLARE @rate numeric(18,6); SET @rate = 0.0;
	DECLARE @index bigint SET @index = 0

	DECLARE @timestampend datetime;
	SET @timestampstart = GETDATE();
	DECLARE @batchsize int; SET @batchsize = 100;
	DECLARE @thisbatchsize int; SET @thisbatchsize = 0;
	DECLARE @numberofbatches int; SET @numberofbatches = 0;
	DECLARE @batchnumber int; SET @batchnumber = 0;
	DECLARE @minfragmentbatchidentity bigint;
	DECLARE @minfragmentbatchid bigint;
	DECLARE @maxfragmentbatchid bigint;
	DECLARE @updateResult bigint SET @updateResult = 0

	DECLARE @id bigint; SET @id = 0;

	DECLARE @fragmentbatch TABLE (
		[identity] bigint identity PRIMARY KEY,
		id bigint NOT NULL,
		peptidesequence varchar(128) NOT NULL, 
		fragmentsequence varchar(128) NOT NULL,
		s_min_precursormz numeric(18,6) NOT NULL,
		s_max_precursormz numeric(18,6) NOT NULL,
		rangecount bigint NOT NULL DEFAULT 0,
		rangecountcorrect bigint NOT NULL DEFAULT 0,
		s_min_precursormz_r numeric(18,6) NOT NULL
	);

	SET @nonredundantrows = (SELECT count(*) FROM measurecontribution WHERE contributionprocessed is NULL);
	SET @numberofbatches = @nonredundantrows / @batchsize + 1;
	SET @errormessage =  cast(@nonredundantrows as varchar(10))  + ' non-redundant related MS/MS spectra to be processed in ' + cast(@numberofbatches as varchar(10)) + ' batches of size ' + cast(@batchsize as varchar(10)) + ' ' +  + format(getdate() - @timestampstart, 'H:m:ss');
	RAISERROR (@errormessage, 0, 1) WITH NOWAIT;

	DECLARE @fragmentfilecount bigint;
	SET @fragmentfilecount = (select count(*) FROM fragmentfile);

	DECLARE @peptidesequence varchar(128); SET @peptidesequence = '';
	DECLARE @fragmentsequence varchar(128); SET @fragmentsequence = '';

	DECLARE @s_min_precursormz numeric(18,6);
	DECLARE @s_max_precursormz numeric(18,6);
	DECLARE @rangecount bigint;
	DECLARE @rangecountcorrect bigint;
	DECLARE @FDR numeric(18,6);

	SET @timestampend = GETDATE();
	WHILE (@batchnumber < @numberofbatches) BEGIN

		-- WARNING: This doesn't reset the identity (can't be done of table variables)
		DELETE FROM @fragmentbatch;

		BEGIN TRANSACTION
			INSERT INTO @fragmentbatch
				(id,
				peptidesequence,
				fragmentsequence,
				s_min_precursormz,
				s_max_precursormz,
				s_min_precursormz_r)
			SELECT TOP (@batchsize)
				id,
				peptidesequence,
				fragmentsequence,
				s_min_precursormz,
				s_max_precursormz,
				s_min_precursormz_r
			FROM measurecontribution
			WHERE contributionprocessed is NULL
			ORDER BY id

			SET @thisbatchsize = @@ROWCOUNT;
			SET @minfragmentbatchidentity = (select min([identity]) from @fragmentbatch);
			SET @minfragmentbatchid = (select min(id) from @fragmentbatch);
			SET @maxfragmentbatchid = (select max(id) from @fragmentbatch);

			WHILE (@index < @thisbatchsize) BEGIN         
		
				BEGIN TRY
					SELECT
						@id = id,
						@peptidesequence = peptidesequence,
						@fragmentsequence = fragmentsequence,
						@s_min_precursormz = s_min_precursormz,
						@s_max_precursormz = s_max_precursormz
					FROM @fragmentbatch
					WHERE [identity] = @minfragmentbatchidentity + @index
					

					--create dipshit table here (not here, before...

					-- resolving power

					UPDATE @fragmentbatch
					SET 
						rangecount = @rangecount,
						rangecountcorrect = @rangecountcorrect,
						s_min_precursormz_r = cast(@rangecountcorrect as numeric(18,6)) / cast(@rangecount as numeric(18,6))
					WHERE id = @id
					
					RETURN
				END TRY
				BEGIN CATCH
					-- Execute the error retrieval routine.			
					SET @errormessage = cast(ERROR_NUMBER() as nvarchar(64)) + CHAR(13) + CHAR(10)
					SET @errormessage = @errormessage + cast(ERROR_SEVERITY() as nvarchar(64)) + CHAR(13) + CHAR(10)
					SET @errormessage = @errormessage + cast(ERROR_STATE() as nvarchar(64)) + CHAR(13) + CHAR(10)
					SET @errormessage = @errormessage + cast(ERROR_PROCEDURE() as nvarchar(64)) + CHAR(13) + CHAR(10)
					SET @errormessage = @errormessage + cast(ERROR_LINE() as nvarchar(64)) + CHAR(13) + CHAR(10)
					SET @errormessage = @errormessage + cast(ERROR_MESSAGE() as nvarchar(1024))
					PRINT @errormessage
					RAISERROR (@errormessage, 20, 1) WITH LOG
				END CATCH
		
				SET @index = @index + 1;

			END

			-- Update the current record of fragmentfile with the current datetime to mark as 'processed'
			-- PRINT cast(@minfragmentbatchid as varchar(12)) + ' - ' + cast(@maxfragmentbatchid as varchar(12));

			--UPDATE measurecontribution
			--SET contributionprocessed = getdate()
			--WHERE id >= @minfragmentbatchid and id <= @maxfragmentbatchid;

			--SET @updateResult = @@ROWCOUNT;
			-- PRINT cast(@updateResult as varchar(12)) + ' rows updated';
			--IF (@updateResult <>  (select count(*) from @fragmentbatch)) BEGIN
			--	RAISERROR ('Was not able to update processed date for fragment file row', 20, 1) WITH LOG;
			--END

			SET @timestampend = GETDATE();
			DECLARE @timediff numeric(18,6);
			SET @timediff = (SELECT DATEDIFF(MICROSECOND, @timestampstart, @timestampend));
			IF (@timediff > 0) BEGIN
				SET @rate = @batchsize / @timediff * 1000000.0;
			END ELSE BEGIN
				PRINT @timestampstart;
				PRINT @timestampend;
				PRINT @timediff;
			END
			SET @timestampstart = GETDATE();

			DECLARE @statusmessage varchar(256);
			SET @statusmessage = 'Processing row ' + cast(@id as varchar(16)) + ' ' + cast((@batchnumber * @batchsize + @index) as varchar(64)) + ' of ' + cast(@nonredundantrows as varchar(16)) + ' (' + @peptidesequence + ' - ' + @peptidesequence + ') ' +
				cast(cast(round(cast((@batchnumber * @batchsize + @index) as numeric(18,6)) / @nonredundantrows * 100.0, 2) as numeric(18,2)) as varchar(64)) + '% ';
			IF (@rate > 0) BEGIN
				SET @statusmessage = @statusmessage + cast(cast(round((@nonredundantrows - (@batchnumber * @batchsize + @index)) / @rate, 2) as numeric(18,2)) as varchar(32)) + ' secs remain ';
			END
			SET @statusmessage = @statusmessage + cast(cast(round(@rate, 2) as numeric(18,2)) as varchar(32)) + ' trans / sec';

			RAISERROR (@statusmessage, 0, 1) WITH NOWAIT;

			BEGIN TRY
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				-- Execute the error retrieval routine.
				
				SET @errormessage = cast(ERROR_NUMBER() as nvarchar(64)) + CHAR(13) + CHAR(10)
				SET @errormessage = @errormessage + cast(ERROR_SEVERITY() as nvarchar(64)) + CHAR(13) + CHAR(10)
				SET @errormessage = @errormessage + cast(ERROR_STATE() as nvarchar(64)) + CHAR(13) + CHAR(10)
				SET @errormessage = @errormessage + cast(ERROR_PROCEDURE() as nvarchar(64)) + CHAR(13) + CHAR(10)
				SET @errormessage = @errormessage + cast(ERROR_LINE() as nvarchar(64)) + CHAR(13) + CHAR(10)
				SET @errormessage = @errormessage + cast(ERROR_MESSAGE() as nvarchar(1024))
				PRINT @errormessage
				ROLLBACK TRANSACTION
				RAISERROR (@errormessage, 20, 1) WITH LOG
			END CATCH
	
		SET @batchnumber = @batchnumber + 1;
		SET @index = 0;
	END

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END

IF (@reportstats = 0) BEGIN
	RAISERROR ('Skipping QAstats', 0, 1) WITH NOWAIT;
END ELSE BEGIN
	RAISERROR ('QA stats', 0, 1) WITH NOWAIT;	
	
	select count(*) from fragmentfile																-- 9120096
	select count(distinct peptidesequence) from fragmentfile										-- 119670
	select count(distinct fragmentsequence) from fragmentfile										-- 612914
	select count(*) FROM (select distinct peptidesequence, fragmentsequence from fragmentfile) a	-- 923599
	 
	--select count(*) FROM s_precursorgroup --119670
	select top 10 * FROM s_precursorgroup
	--select count(*) FROM s_productgroup --612914
	select top 10 * FROM s_productgroup
	select count(*) FROM c_precursorproductgroup
	select top 10 * FROM c_precursorproductgroup
	select count(*) FROM s_peptideweightedaverages
	select top 10 * FROM s_peptideweightedaverages
	select count(*) FROM s_fragmentweightedaverages
	select top 10 * FROM s_fragmentweightedaverages
	select count(*) FROM c_peptideweightedaverages
	select top 10 * FROM c_peptideweightedaverages
	select count(*) FROM c_fragmentweightedaverages
	select top 10 * FROM c_fragmentweightedaverages

	select count(*) FROM measurecontribution
	select top 10 * FROM measurecontribution
END 

PRINT 'Finished processing!';

SET IMPLICIT_TRANSACTIONS ON;




/*
	TODO: put indexes on peptidesequence and fragmentsequence on fragmentfile

	remove all sequence indices, and replace with a foreign key to the sequence table

*/

--select * from measurecontribution
