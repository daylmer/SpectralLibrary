-- Naive prediction

/*

select top 5  f.id, f.peptidesequence, f.precursormz, dmcr.id, dmcr.label 'MassChargeBand', f.precursorrettime * 60, drtr.id, drtr.minrange, drtr.label 'RetentionTimeBand', drtr.maxrange --, f.precursormobility * 60, ddtr.label 'DriftTimeBand', f.precursorintensity --, dir.label 'IntensityBand'
from fragmentfile f
INNER JOIN DimMassChargeRel dmcr on f.precursormz >= dmcr.minrange and  f.precursormz < dmcr.maxrange
INNER JOIN DimRetentionTimeRel drtr on f.precursorrettime * 60 >= drtr.minrange and  f.precursorrettime * 60 < drtr.maxrange
--INNER JOIN DimDriftTimeRel ddtr on f.precursormobility * 60 >= ddtr.minrange and  f.precursormobility * 60  < ddtr.maxrange
--INNER JOIN DimIntensityRel dir on f.precursorintensity >= dir.minrange and  f.precursorintensity < dir.maxrange
where f.id in (
	select (select top 1 id from fragmentfile where peptidesequence = a.peptidesequence) from (
		select top 10 peptidesequence from fragmentfile group by peptidesequence
	) a
)

select top 50 75.575500 * 60, * from DimRetentionTimeRel where id in (166,167,168,169)

select top 5 precursorrettime * 60 from fragmentfile

	SELECT top 5 cast(retentiontime*60 as int) as retentiontime --, count(retentiontime) Frequency
	FROM mspeak
	GROUP BY  cast(retentiontime*60 as int)

minrange	maxrange
4460.000000	4539.000000
4480.000000	4559.000000
4500.000000	4579.000000
4520.000000	4599.000000

*/

-- OVERLAPPING CLUSTERS

select count(*) 'Total retention time clusters' from DimRetentionTimeRel 
select count(*) 'overlapping retention time clusters'
FROM DimRetentionTimeRel mc1, DimRetentionTimeRel mc2
where mc1.minrange > mc2.minrange and mc1.minrange < mc2.maxrange and mc1.id <> mc2.id or 
mc1.maxrange > mc2.minrange and mc1.minrange < mc2.maxrange and mc1.id <> mc2.id

select mc1.id, mc1.label, mc1.minrange, mc1.maxrange, mc2.id, mc2.label, mc2.minrange, mc2.maxrange
FROM DimRetentionTimeRel mc1, DimRetentionTimeRel mc2
where mc1.minrange BETWEEN mc2.minrange and mc2.maxrange and mc1.id <> mc2.id or 
mc1.maxrange > mc2.minrange and mc1.minrange < mc2.maxrange and mc1.id <> mc2.id

select drtr.label, min(msp.retentiontime) * 60 'min' , avg(msp.retentiontime) * 60 'avg' , max(msp.retentiontime) * 60 'max' , min(msp.retentiontime) * 60 , count(*) 'count'
FROM mspeak msp with (nolock)
LEFT JOIN DimRetentionTimeRel drtr with (nolock) on msp.retentiontime * 60 >= drtr.minrange and msp.retentiontime * 60 < drtr.maxrange -- 
GROUP BY drtr.label
/*
select top 2 * 
FROM DimMassChargeRel mc1, DimMassChargeRel mc2
where
mc1.minrange > mc2.minrange and mc1.minrange < mc2.maxrange and mc1.id <> mc2.id
or 
mc1.maxrange > mc2.minrange and mc1.minrange < mc2.maxrange and mc1.id <> mc2.id


select count(*) from DimIntensityRel
select count(*) 
FROM DimIntensityRel mc1, DimIntensityRel mc2
where
mc1.minrange > mc2.minrange and mc1.minrange < mc2.maxrange and mc1.id <> mc2.id
or 
mc1.maxrange > mc2.minrange and mc1.minrange < mc2.maxrange and mc1.id <> mc2.id



INNER JOIN FactSpectra fs on fs.MassChargeRelID = mc.id



LEFT JOIN DimSequence mcs 
LEFT JOIN mspeaksequence msps on msp.id = msps.mspeakid
LEFT JOIN sequence s on msps.sequenceid = s.id

select top 50 * from DimMassChargeRel


ISNULL((select top 1 id from DimRetentionTimeRel where msp.retentiontime >= minrange and  msp.retentiontime < maxrange), 1) RetentionTimeRelID,

ISNULL((select top 1 id from DimDriftTimeRel where msp.drifttime >= minrange and  msp.drifttime < maxrange), 1) DriftTimeRelID,

ISNULL((select top 1 id from DimIntensityRel where msp.intensity >= minrange and  msp.intensity < maxrange), 1) IntensityRelID,

*/