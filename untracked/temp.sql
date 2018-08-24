select count(*) from fragmentfile


select top 1 id, proteinaccession from fragmentfile where proteinaccession = 'P29310' UNION
-- select id, proteinaccession from fragmentfile where proteinaccession = 'A1Z6N4' UNION
select top 1 id, proteinaccession from fragmentfile where proteinaccession = 'A8JNP2' and id >= 212171 UNION
-- select id, proteinaccession from fragmentfile where proteinaccession = 'A1Z7Y7' and id >= 212171 UNION
select top 1 id, proteinaccession from fragmentfile where proteinaccession = 'M9PD75' and id >= 522880 UNION
-- select id, proteinaccession from fragmentfile where proteinaccession = 'Q9VIE7' and id >= 522880 UNION
select top 1 id, proteinaccession from fragmentfile where proteinaccession = 'P29310' and id >= 727300 UNION
-- select id, proteinaccession from fragmentfile where proteinaccession = 'Q9VHC7' and id >= 727300 UNION
select top 1 id, proteinaccession from fragmentfile where proteinaccession = 'P29310' and id >= 906380 --UNION
-- select id, proteinaccession from fragmentfile where proteinaccession = 'Q9VTU3' and id >= 906380 
order by id


select id, datasetid, proteinaccession from fragmentfile where id in (
1, 212169, 212170, 212171, 522879, 522880, 522881, 727311, 727312, 727313, 906379, 906380, 906381, 1016246, 1016247, 1016248, 1132863, 1132864, 1132865, 1311352, 1311353, 1311354
)
204433

179068
116617
select * from fragmentfile where id > 906380 and id < 1128553

SELECT * FROM dataset
select * from datasetcondition
select * from condition


/*

-- UPDATE fragmentfile set datasetid = 2 where id >= 1 and id < 212171
-- UPDATE fragmentfile set datasetid = 3 where id >= 212171 and id < 522880
-- UPDATE fragmentfile set datasetid = 4 where id >= 522880 and id < 727312
-- UPDATE fragmentfile set datasetid = 5 where id >= 727312 and id < 906380
-- UPDATE fragmentfile set datasetid = 6 where id >= 906380 and id < 1016247
-- UPDATE fragmentfile set datasetid = 7 where id >= 1016247 and id < 1132864
-- UPDATE fragmentfile set datasetid = 8 where id >= 1132864 and id < 1311353

select * from datasetcondition
UPDATE datasetcondition set datasetid = 2 where id IN (4,5,6)
UPDATE datasetcondition set datasetid = 3 where id IN (7,8,9)
UPDATE datasetcondition set datasetid = 4 where id IN (10,11,12)
UPDATE datasetcondition set datasetid = 5 where id IN (13,14,15)
UPDATE datasetcondition set datasetid = 6 where id IN (16,17,18)
UPDATE datasetcondition set datasetid = 7 where id IN (19,20,21)
UPDATE datasetcondition set datasetid = 8 where id IN (22,23,24)

*/


