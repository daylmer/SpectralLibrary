-- TAU
select *
FROM fragmentfile
WHERE proteinaccession in (
	'A1ZBL5',
	'A1ZBL7',
	'A1ZBL9',
	'E1JGM9',
	'E1JGN0',
	'Q6NPA6',
	'Q7YU80',
	'Q963E5',
	'Q9V8V8',
	'Q9VB13'
)

--AB Toxicity
select (	SELECT DISTINCT c.description
	FROM conditioncategory cc 
	INNER JOIN condition c on c.conditioncategoryid = cc.id
	INNER JOIN datasetcondition dsc on dsc.conditionid = c.id
	INNER JOIN dataset ds on ds.id = dsc.datasetid
	WHERE cc.title = 'TimePoint' and ds.id = ff.datasetid) as timepoint ,
	
	* --datasetid, count(*),

FROM fragmentfile ff
--INNER JOIN dataset ds on ff.datasetid = ds.id
WHERE proteinaccession in (
	'Q9VPT9'
)

order by timepoint
/*
	FROM conditioncategory cc 
	INNER JOIN condition c on c.conditioncategoryid = cc.id
	INNER JOIN datasetcondition dsc on dsc.conditionid = c.id
	INNER JOIN dataset ds on ds.id = dsc.datasetid
	WHERE cc.title = 'Technical replicate'

	*/