


describe SQL tables

s_ are used for analysis, decsription of eahc table.





mz
rettime


SELECT 's_precursor_avgdelta£_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
FROM s_precursorgroup spg
INNER JOIN s_precursorgroup_bounds b on spg.peptidesequence = b.peptidesequence
CROSS APPLY
(
	SELECT count(*) value 
	FROM (
		SELECT ff1.precursor£
		FROM fragmentfile ff1 
		WHERE ff1.precursor£ BETWEEN b.s_avg_precursor£_minbound AND b.s_avg_precursor£_maxbound
		AND ff1.peptidesequence = spg.peptidesequence
	) total
) matchcount	







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







/*




*/
	

/*SET NOCOUNT ON

/*

SELECT 's_precursor_avgdeltamz_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
FROM s_precursorgroup spg
CROSS APPLY
(
	SELECT count(*) value FROM (
		SELECT TOP (spg.peptidefrequency) ff1.precursormz
		FROM fragmentfile ff1 
		WHERE ff1.peptidesequence = spg.peptidesequence
		ORDER BY ABS(ff1.precursormz - spg.s_avg_precursormz)
	) total
) matchcount
where peptidesequence = 'LPVR'

*/




s_precursor_avgdeltamz_r	QFLITR	2 /	5
select * from s_precursorgroup where peptidesequence = 'QFLITR'

select s_avg_precursormz, * FROM s_precursorgroup where peptidesequence = 'QFLITR'

--SELECT TOP (68) ff1.peptidesequence, ff1.precursormz, ABS(ff1.precursormz - 389.233180)
--FROM fragmentfile ff1 
--ORDER BY ABS(ff1.precursormz - 389.233180)

select max(precursormz) from fragmentfile where peptidesequence= 'QFLITR'
select min(precursormz) from fragmentfile where peptidesequence= 'QFLITR'
select s_avg_precursormz from s_precursorgroup where peptidesequence= 'QFLITR'
select * from s_precursorgroup where peptidesequence= 'QFLITR'

-- Either
-- 1. do total count of all things where their closest average is this one
-- 2. Do total count of all things that are closer than the furtherest one from the average that matches

-- # Take all fragments that are nearest to avg than any other avg, call this total . Of subset, those that match sequence become match.


select s_avg_precursormz from s_precursorgroup where peptidesequence= 'QFLITR' -- 389.233180

-- Take all fragments that are nearest to avg than any other avg
select peptidesequence, s_avg_precursormz from s_precursorgroup where s_avg_precursormz between 388 and 390 order by s_avg_precursormz

select top 5 peptidesequence, s_avg_precursormz from s_precursorgroup where s_avg_precursormz between 388 and 390 order by ABS(s_avg_precursormz - 389.233180)


peptidesequence	s_avg_precursormz
RIKDHVLSR	389.232600
QFLITR		389.233180
LFQLTR		389.234500

select top 1 peptidesequence, s_avg_precursormz from s_precursorgroup where s_avg_precursormz < 389.233180 order by s_avg_precursormz desc	-- TVRFNVLKVSK	430.936000
select 389.233180 + (389.232600 - 389.233180) / 2  -- 389.23289000

select top 1 peptidesequence, s_avg_precursormz from s_precursorgroup where s_avg_precursormz > 389.233180 order by s_avg_precursormz		-- EVDAALLK		431.062276
select 389.233180 + (389.234500 - 389.233180) / 2  -- 389.23384000


select * from fragmentfile where precursormz between 389.23289000 and 389.23384000
--peptidesequence		precursormz
--DSFNNWSSDEETNLMMSK	430.980300
--DSFNNWSSDEETNLMMSK	430.979100
--DSFNNWSSDEETNLMMSK	430.979100


select top 5 * from s_precursorgroup order by s_avg_precursormz

SELECT top 3 peptidesequence, s_avg_precursormz
FROM s_precursorgroup
--WHERE s_avg_precursormz between 400 and 450 
order by ABS(s_avg_precursormz - 431.016845)

SELECT 's_precursor_avgdeltamz_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
FROM s_precursorgroup spg
CROSS APPLY
(
	SELECT count(*) value FROM (
		SELECT TOP (spg.peptidefrequency) ff1.precursormz
		FROM fragmentfile ff1 
		WHERE ff1.peptidesequence = spg.peptidesequence
		ORDER BY ABS(ff1.precursormz - spg.s_avg_precursormz)
	) total
) matchcount
where peptidesequence = 'LPVR'


*/

/*

DECLARE @midpoint TABLE (
	id bigint identity PRIMARY KEY,
	sequence varchar(128) UNIQUE NONCLUSTERED,
	value numeric(18,6),
	value_min numeric(18,6) null,
	value_max numeric(18,6) null
)

INSERT INTO @midpoint
SELECT peptidesequence, s_avg_precursormz, null, null
FROM	s_precursorgroup
ORDER BY s_avg_precursormz ASC

DECLARE @peptidesequence varchar(128); SET @peptidesequence = '';
DECLARE @value numeric(18,6);
DECLARE @value_min numeric(18,6); SET @value_min = 0.0;
DECLARE @value_max numeric(18,6); SET @value_max = 0.0;
DECLARE @previous_value numeric(18,6); SET @previous_value = 0.0;

DECLARE @index bigint SET @index = (select min(id) from @midpoint);
DECLARE @maxid bigint; SET @maxid = (select max(id) from @midpoint);



WHILE (@index < @maxid + 2) BEGIN

	SELECT @value = value
	FROM @midpoint
	WHERE id = @index
	
	IF @value is null SET @value = @previous_value
	SET @value_min = @value + (@previous_value - @value) / 2

	UPDATE @midpoint
	SET		value_min = @value_min
	WHERE id = @index

	UPDATE @midpoint
	SET		value_max = @value_min
	WHERE id = @index - 1

	SET @previous_value = @value;

	SET @index = @index + 1;
END

UPDATE @midpoint	SET value_min = 0 WHERE id = 1


SELECT 's_precursor_avgdeltamz_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
FROM s_precursorgroup spg
INNER JOIN @midpoint mp on spg.peptidesequence = mp.sequence
CROSS APPLY
(
	SELECT count(*) value 
	FROM (
		SELECT ff1.precursormz
		FROM fragmentfile ff1 
		WHERE ff1.precursormz BETWEEN mp.value_min AND mp.value_max
		AND ff1.peptidesequence = spg.peptidesequence
	) total
) matchcount




*/


USE protein
GO


	-- Drop procedure if exists
	IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.midpoint'))
		DROP PROCEDURE midpoint
	GO

	-- Create a procedure that finds the midpoints between centre points to make bounding in a linear space easier
	CREATE PROCEDURE midpoint(
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
		SELECT peptidesequence, ' + @ColumnName + N', null, null
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

		UPDATE #midpoint	SET value_min = 0 WHERE id = 1

		SELECT * FROM #midpoint
	END
	GO

	
IF 1=0 BEGIN
	
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

	INSERT INTO s_precursorgroup_bounds (peptidesequence)
		SELECT peptidesequence FROM s_precursorgroup

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


	-- SELECT count(*) FROM s_precursorgroup			-- 119670
	-- SELECT count(*) FROM s_peptideweightedaverages	-- 119670
	-- SELECT count(*) FROM s_productgroup				-- 612914
	-- SELECT count(*) FROM c_precursorproductgroup		-- 923599
	-- 

	-- Table variable to store the results of a call tot he midpoint procedure
	DECLARE @midpoint TABLE (
		-- Add the column definitions for the TABLE variable here
		id bigint PRIMARY KEY,
		sequence varchar(128) UNIQUE NONCLUSTERED,
		value numeric(18,6),
		value_min numeric(18,6) null,
		value_max numeric(18,6) null
	)


	----SELECT top 2 * FROM s_precursorgroup
	--SELECT top 2 * FROM s_productgroup
	--SELECT top 2 * FROM c_precursorproductgroup

	--select top 2 * from s_precursorgroup_bounds
	--select top 2 * from s_peptideweightedaverages
	--select top 2 * from s_peptideweightedaverages_bounds


	INSERT INTO @midpoint
	EXEC midpoint 's_avg_precursormz', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursormz_minbound = m.value_min,
		s_avg_precursormz_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 's_avg_precursorrettime', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursorrettime_minbound = m.value_min,
		s_avg_precursorrettime_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 's_avg_precursormobility', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursormobility_minbound = m.value_min,
		s_avg_precursormobility_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint


	select top 5 * from s_precursorgroup_bounds
	INSERT INTO @midpoint
	EXEC midpoint 's_avg_precursorintensity', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursorintensity_minbound = m.value_min,
		s_avg_precursorintensity_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 's_avg_precursordeltappm', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursordeltappm_minbound = m.value_min,
		s_avg_precursordeltappm_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 's_avg_precursorfwhm', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursorfwhm_minbound = m.value_min,
		s_avg_precursorfwhm_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 's_avg_precursormhp', 's_precursorgroup'
	UPDATE s_precursorgroup_bounds
	SET s_avg_precursormhp_minbound = m.value_min,
		s_avg_precursormhp_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 's_wavg_precursormz', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursormz_minbound = m.value_min,
		s_wavg_precursormz_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 's_wavg_precursorrettime', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursorrettime_minbound = m.value_min,
		s_wavg_precursorrettime_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 's_wavg_precursormobility', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursormobility_minbound = m.value_min,
		s_wavg_precursormobility_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 's_wavg_precursorintensity', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursorintensity_minbound = m.value_min,
		s_wavg_precursorintensity_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 's_wavg_precursordeltappm', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursordeltappm_minbound = m.value_min,
		s_wavg_precursordeltappm_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 's_wavg_precursorfwhm', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursorfwhm_minbound = m.value_min,
		s_wavg_precursorfwhm_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint

	INSERT INTO @midpoint
	EXEC midpoint 's_wavg_precursormhp', 's_peptideweightedaverages'
	UPDATE s_peptideweightedaverages_bounds
	SET s_wavg_precursormhp_minbound = m.value_min,
		s_wavg_precursormhp_maxbound = m.value_max
	FROM @midpoint m
	WHERE peptidesequence = m.sequence
	DELETE @midpoint


	select top 50 * from s_precursorgroup_bounds

	select top 50 * from s_peptideweightedaverages_bounds

	RETURN

END
-- // GOAL HERE: Use s_precursorgroup_bounds instead of midpoint to perform matching




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

SELECT 's_precursor_avgdeltarettime_r', spg.peptidesequence, matchcount.value, spg.peptidefrequency
FROM s_precursorgroup spg
INNER JOIN s_precursorgroup_bounds b on spg.peptidesequence = b.peptidesequence
CROSS APPLY
(
	SELECT count(*) value 
	FROM (
		SELECT ff1.precursorrettime
		FROM fragmentfile ff1 
		WHERE ff1.precursormz BETWEEN b.s_avg_precursorrettime_minbound AND b.s_avg_precursorrettime_maxbound
		AND ff1.peptidesequence = spg.peptidesequence
	) total
) matchcount
