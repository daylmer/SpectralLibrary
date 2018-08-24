/*
	SELECT cast(retentiontime*60 as int) as retentiontime, count(retentiontime) Frequency
	FROM mspeak
	GROUP BY  cast(retentiontime*60 as int)

		SELECT cast(drifttime*60 as int) as drifttime, count(drifttime) Frequency
	FROM mspeak
	GROUP BY  cast(drifttime*60 as int)

		SELECT cast(intensity/10 as bigint)*10 as intensity, count(intensity) Frequency
	FROM mspeak
	GROUP BY cast(intensity/10 as bigint)

	select * from DimRetentionTimeRel
*/

select
mc.id, s.sequence, (select top 1 label from DimMassChargeRel where id = mc.id) label, min(msp.masscharge) 'min', avg(msp.masscharge) 'avg', max(msp.masscharge) 'max', count(*) 'count'

-- ISNULL((select top 1 id from DimMassChargeRel where msp.masscharge >= minrange and  msp.masscharge < maxrange), 1) MassChargeRelID
-- ,*
from mspeak msp
LEFT join DimMassChargeRel mc on msp.retentiontime >= mc.minrange and msp.retentiontime < mc.maxrange
LEFT JOIN mspeaksequence msps on msp.id = msps.mspeakid
LEFT JOIN sequence s on msps.sequenceid = s.id	
group by mc.id, s.sequence
order by label, len(s.sequence), s.sequence, mc.id



select
rt.id, s.sequence, (select top 1 label from DimRetentionTimeRel where id = rt.id) label, min(msp.retentiontime) * 60 'min', avg(msp.retentiontime) * 60 'avg', max(msp.retentiontime) * 60 'max', count(*) 'count'

-- ISNULL((select top 1 id from DimMassChargeRel where msp.masscharge >= minrange and  msp.masscharge < maxrange), 1) MassChargeRelID
-- ,*
from mspeak msp
LEFT join DimRetentionTimeRel rt on msp.retentiontime * 60 > rt.minrange and msp.retentiontime * 60 <= rt.maxrange
LEFT JOIN mspeaksequence msps on msp.id = msps.mspeakid
LEFT JOIN sequence s on msps.sequenceid = s.id	
group by rt.id, s.sequence
order by len(s.sequence), s.sequence, rt.id


select
dt.id, s.sequence, (select top 1 label from DimDriftTimeRel where id = dt.id) label, min(msp.drifttime) * 60 'min', avg(msp.drifttime) * 60 'avg', max(msp.drifttime) * 60 'max', count(*) 'count'

-- ISNULL((select top 1 id from DimMassChargeRel where msp.masscharge >= minrange and  msp.masscharge < maxrange), 1) MassChargeRelID
-- ,*
from mspeak msp
LEFT join DimDriftTimeRel dt on msp.drifttime * 60 > dt.minrange and msp.drifttime * 60 <= dt.maxrange
LEFT JOIN mspeaksequence msps on msp.id = msps.mspeakid
LEFT JOIN sequence s on msps.sequenceid = s.id	
group by dt.id, s.sequence
order by len(s.sequence), s.sequence, dt.id



select
--rt.id, --s.sequence, 
dt.label, min(msp.drifttime) 'min', avg(msp.drifttime) 'avg', max(msp.drifttime) 'max', count(*) 'count'

-- ISNULL((select top 1 id from DimMassChargeRel where msp.masscharge >= minrange and  msp.masscharge < maxrange), 1) MassChargeRelID
-- ,*
from mspeak msp
LEFT join DimDriftTimeRel dt on msp.retentiontime * 60 > dt.minrange and msp.retentiontime * 60 <= dt.maxrange
LEFT JOIN mspeaksequence msps on msp.id = msps.mspeakid
LEFT JOIN sequence s on msps.sequenceid = s.id
group by dt.label --, s.sequence
--order by mc.id --len(s.sequence), s.sequence

select * from DimDriftTimeRel

select top 50 drifttime * 60, * from mspeak