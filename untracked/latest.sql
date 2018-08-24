


select * 
from measurecontribution
WHERE peptidesequence = 'IFSPVLAAR'	 AND fragmentsequence = 'SPVLAAR'
group by
`


ORDER BY count(*) DESC

select count(*) from measurecontribution where datasetid = 1


select count(*) from fragmentfile																-- 9120096

select count(distinct peptidesequence) from fragmentfile										-- 119670

select count(distinct fragmentsequence) from fragmentfile										-- 612914

select count(*) FROM (select distinct peptidesequence, fragmentsequence from fragmentfile) a	-- 923599

ALTER TABLE [dbo].[DimDataSet]	ADD CONSTRAINT DimDataSet_label_uq UNIQUE (label)
ALTER TABLE [dbo].[DimDataSet]	ADD CONSTRAINT DimDataSet_label_uq UNIQUE (label)



Using temporary tables to hold calculated fields
Adding appropriate indexes to such fields
Reducing cardinality complexity by 


store minto calculate the normalised min, max, weighted average 

normalise each dataset 

the min for each data set will be zero
the max for each data set will be one


(datasetmin - abolutemin) /  (absolutemax - absolute min)

normalised - new data is bounded... ouliers have a greater impact



select top 10 peptidesequence, fragmentsequence, count(*)
from measurecontribution
group by peptidesequence, fragmentsequence
ORDER BY count(*) DESC

select top 10 peptidesequence, fragmentsequence, count(*)
from fragmentfile
group by peptidesequence, fragmentsequence
ORDER BY count(*) DESC

/*
peptidesequence	fragmentsequence	(No column name)
LQIWDTAGQER	WDTAGQER	1347
LQIWDTAGQER	QIWDTAGQER	1312
VEIIANDQGNR	ANDQGNR	1224
LQIWDTAGQER	IWDTAGQER	1151
LQIWDTAGQER	DTAGQER	1123
VEIIANDQGNR	IANDQGNR	1116
LQIWDTAGQER	LQ	1113
LQIWDTAGQER	LQI	1080
GYSFTTTAER	GYSFTTTAER	1071
VEIIANDQGNR	IIANDQGNR	1020
*/

select distinct precursormz from fragmentfile WHERE peptidesequence = 'LQIWDTAGQER'	 AND fragmentsequence = 'WDTAGQER'
ORDER by precursormz

SELECT  precursormz
FROM fragmentfile 
WHERE peptidesequence = 'LQIWDTAGQER' AND fragmentsequence = 'WDTAGQER'

-- For each precursor value
SELECT  x.precursormz ,
CASE WHEN min(x.precursormz) = max(x.precursormz) THEN 0 ELSE (x.precursormz - min(x.precursormz)) /  (max(x.precursormz) - min(x.precursormz)) END normalised,
CASE WHEN stdev(x.precursormz) = 0 THEN avg(x.precursormz) ELSE (x.precursormz - avg(x.precursormz)) / stdev(x.precursormz) END standard

--select *  
FROM (select distinct precursormz from fragmentfile WHERE peptidesequence = 'LQIWDTAGQER'	 AND fragmentsequence = 'WDTAGQER') x 
--WHERE x.peptidesequence = 'LQIWDTAGQER' AND x.fragmentsequence = 'WDTAGQER'
--GROUP BY x.precursormz



select datasetid, min(precursorrettime), max(precursorrettime)
FROM fragmentfile 
WHERE peptidesequence = 'LQIWDTAGQER' AND fragmentsequence = 'WDTAGQER'-- and datasetid =15
GROUP by datasetid

-- is measurecontribution right? (no...)


select id, datasetid, pept
idesequence, fragmentsequence, (min( - abolutemin) /  (absolutemax - absolute mix) from measurecontribution WHERE peptidesequence = 'IFSPVLAAR'	 AND fragmentsequence = 'SPVLAAR'


select * from fragmentfile WHERE peptidesequence = 'LQIWDTAGQER' AND fragmentsequence = 'WDTAGQER'

select * from fragmentfile WHERE id = 12540
select top 1 * from measurecontribution where precuros

select * from fragmentfile WHERE peptidesequence = 'LQIWDTAGQER' AND fragmentsequence = 'WDTAGQER'
select * from measurecontribution WHERE peptidesequence = 'LQIWDTAGQER' AND fragmentsequence = 'WDTAGQER'

select distinct peptidesequence, fragmentsequence from measurecontribution --
-- count of above is: 923599

select count(*) from measurecontribution
-- count of measurecontribution is 3783590

-- change select to delete
-- delete from measurecontribution where id in (
	select top 5 id, peptidesequence, fragmentsequence /*, (select min(id)
										from (select top 20 * from measurecontribution) ismc
										WHERE ismc.peptidesequence = mc.fragmentsequence and ismc.peptidesequence = mc.fragmentsequence
									) mini*/
	FROM  measurecontribution mc 
	WHERE ID NOT IN (
		select min(id)
		from (select top 20 * from measurecontribution) smc
		WHERE smc.peptidesequence = mc.fragmentsequence and smc.peptidesequence = mc.fragmentsequence
	)
--)


select min(len(peptidesequence)), max(len(peptidesequence)) from fragmentfile


select min(len(fragmentsequence)), max(len(fragmentsequence)) from fragmentfile


histogram of peptide sequence length

histogram of fragment sequence length

select distinct peptidesequence, fragmentsequence from measurecontribution

923599