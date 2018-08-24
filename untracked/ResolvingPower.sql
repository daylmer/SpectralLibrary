--CREATE PROCEDURE ResolvingPower

-- We want to determine which dimensions might be useful for identifying peptide/fragment sequences


DECLARE @peptidesequence varchar(128);
DECLARE @fragmentsequence varchar(128);
SET @peptidesequence = 'LQIWDTAGQER';
SET @fragmentsequence = 'WDTAGQER';
SELECT top 1 * from measurecontribution
SELECT top 1 * from measurecontribution where peptidesequence = @peptidesequence and fragmentsequence = @fragmentsequence

SELECT peptidesequence, fragmentsequence, min(precursormz), max(precursormz)
FROM fragmentfile ff
WHERE peptidesequence = 'LQIWDTAGQER' and fragmentsequence = 'WDTAGQER'
GROUP BY peptidesequence, fragmentsequence

SELECT peptidesequence, fragmentsequence, min(precursormz) 'min(precursormz)', max(precursormz) 'max(precursormz)'
FROM fragmentfile ff
WHERE peptidesequence = 'LQIWDTAGQER' and fragmentsequence = 'WDTAGQER'
GROUP BY peptidesequence, fragmentsequence

select count(*) FROM fragmentfile

--get count from ff between min and max range for every row of mc
SELECT top 1 mc.peptidesequence, mc.fragmentsequence, 
count((
	SELECT 1
	FROM fragmentfile ff with (nolock)
	WHERE precursormz between mc.s_min_precursormz and mc.s_max_precursormz
)) 'numberinrange'/*,
count((
	SELECT 1
	FROM fragmentfile ff with (nolock)
	WHERE precursormz between mc.s_min_precursormz and mc.s_max_precursormz
	AND peptidesequence = mc.peptidesequence and fragmentsequence = mc.fragmentsequence)
)) 'numbercorrect',
mc.peptidefragmentfrequency, mc.peptidefragmentproteincount, mc.peptidefrequency, mc.peptideproteincount
*/
FROM measurecontribution mc
WHERE peptidesequence = 'LQIWDTAGQER' and fragmentsequence = 'WDTAGQER'

					--FDR
					SELECT count(*)
					FROM fragmentfile ff
					WHERE precursormz between 658.831500 and 679.840700
					AND (peptidesequence = 'LQIWDTAGQER' or fragmentsequence = 'WDTAGQER')
					--13664

					-- resolving power
					SELECT  1347.0 / 353105.0



					-- noramlised precursorintensity

					-- dataset 5 lowest min
					-- dataset 25 highest max
					--normalised (total)
					SELECT datasetid, min(precursorintensity) 'min', max(precursorintensity) 'max'
					FROM fragmentfile ff 
					WHERE datasetid in (5, 25)
					GROUP BY datasetid
					ORDER BY datasetid
					--datasetid	min	max
					--5			750	487077
					--25		750	1198544

					SELECT datasetid, min(precursorintensity) 'min', max(precursorintensity) 'max'
					FROM fragmentfile ff 
					WHERE datasetid in (5, 25)
					AND peptidesequence = 'LQIWDTAGQER' AND fragmentsequence = 'WDTAGQER'
					GROUP BY datasetid
					ORDER BY datasetid
					-- This peptide/fragment min max
					--datasetid	min	max
					--5	7816	7816
					--25	1217	303831

					-- normalised min for this thing
					--data set 5
					SELECT (7816.0 - 750.0) /  (487077.0 - 750.0)
					--0.0145293187
					--data set 25
					SELECT (1217.0 - 750.0) /  (1198544.0 - 750.0)
					--0.00038988340

					-- normalised max for this thing
					--data set 5
					SELECT (7816.0 - 750.0) /  (487077.0 - 750.0)
					--0.0145293187
					--data set 25
					SELECT (303831.0 - 750.0) /  (1198544.0 - 750.0)
					-- 0.25303265837


					--fragment file where normalised dataset value is in this range
					-- dataset 5
					SELECT count(*)
					FROM fragmentfile ff
					WHERE (ff.precursorintensity - 750.0) /  (487077.0 - 750.0) 
					BETWEEN 0.0145293187 AND 0.0145293187
					AND ff.datasetid = 5 

					SELECT count(*)
					FROM fragmentfile ff
					WHERE (ff.precursorintensity - 750.0) /  (487077.0 - 750.0) 
					BETWEEN 0.0145293187 AND 0.0145293187
					AND peptidesequence = 'LQIWDTAGQER' AND fragmentsequence = 'WDTAGQER'
					AND ff.datasetid = 5 

					-- dataset 25
					SELECT count(*)
					FROM fragmentfile ff
					WHERE (ff.precursorintensity - 750.0) /  (487077.0 - 750.0) 
					BETWEEN 0.00038988340 AND 0.25303265837
					AND ff.datasetid = 5 

					SELECT count(*)
					FROM fragmentfile ff
					WHERE (ff.precursorintensity - 750.0) /  (487077.0 - 750.0) 
					BETWEEN 0.00038988340 AND 0.25303265837
					AND peptidesequence = 'LQIWDTAGQER' AND fragmentsequence = 'WDTAGQER'
					AND ff.datasetid = 5 

/*
CREATE  PROCEDURE ResolvingPowerNormalised (

@studentid INT,                   --Input parameter ,  Studentid of the student
@studentname VARCHAR (200) OUT,    -- Output parameter to collect the student name
@StudentEmail VARCHAR (200)OUT     -- Output Parameter to collect the student email
)
AS
BEGIN
SELECT @studentname= Firstname+' '+Lastname, 
    @StudentEmail=email FROM tbl_Students WHERE studentid=@studentid
END


*/



					--normalised (total)
					select min(precursormz), max(precursormz) FROM fragmentfile ff 
					-- 228.133900 1835.369200

					select min(precursormz), max(precursormz)
					FROM fragmentfile ff 
					WHERE datasetid = 1

					select min(precursormz), max(precursormz)
					FROM fragmentfile ff 
					WHERE datasetid = 2

					-- This peptide/fragment min max
					-- 658.831500 = 679.840700

					-- normalised min for this thing
					SELECT (658.831500 - 228.133900) /  (1835.369200 - 228.133900)
					--0.267974203901569359

					-- normalised max for this thing
					SELECT (679.840700 - 228.133900) /  (1835.369200 - 228.133900)
					--0.281045843131991936
					

					--fragment file where normalised dataset value is in this range
					SELECT count(*)
					FROM fragmentfile ff
					WHERE (ff.precursormz - 228.133900) /  (1835.369200 - 228.133900)
					BETWEEN 0.267974203901569359 AND 0.281045843131991936
					--353105

					SELECT count(*)
					FROM fragmentfile ff
					WHERE (ff.precursormz - 228.133900) /  (1835.369200 - 228.133900)
					BETWEEN 0.267974203901569359 AND 0.281045843131991936
					AND (peptidesequence = 'LQIWDTAGQER' or fragmentsequence = 'WDTAGQER')
					--13664