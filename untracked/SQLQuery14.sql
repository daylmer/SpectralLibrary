--SELECT * FROM DimSequence WITH (NOLOCK)			--658922
--select * from DimSequenceType WITH (NOLOCK)
--select * from dimprotein  WITH (NOLOCK)			--6225



select p.accession --smt.title --percent
--s.sequence, ISNULL((select count(*) from DimSequence where sequence = s.sequence), -1) SequenceID,
--count(*) --smt.title, ISNULL((select count(*) from DimSequenceType WITH (NOLOCK) where label = smt.title), -1) SequenceTypeID --,
--p.accession, ISNULL((select count(*) from DimProtein where label = p.accession), -1) ProteinID --,

from mspeak msp WITH (NOLOCK)
--LEFT JOIN dataset d WITH (NOLOCK) on msp.datasetid = d.id
--LEFT JOIN mspeaktype mspt WITH (NOLOCK) on msp.mspeaktypeid = mspt.id
LEFT JOIN mspeaksequence msps WITH (NOLOCK) on msp.id = msps.mspeakid
--LEFT JOIN sequencematchtype smt WITH (NOLOCK) on msps.sequencematchtype = smt.id
--LEFT JOIN sequence s WITH (NOLOCK) on msps.sequenceid = s.id
LEFT JOIN protein p WITH (NOLOCK) on p.id = msps.proteinid

WHERE 
--(select count(*) from DimSequence where sequence = s.sequence) <> 1 OR
--(select count(*) from DimSequenceType WITH (NOLOCK) where label = smt.title) <> 1 -- OR
(select count(*) from DimProtein WITH (NOLOCK) where label = p.accession) <> 1 