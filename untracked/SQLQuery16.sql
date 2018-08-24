select top 5 precursorrettime, productrettime , * from fragmentfile where productrettime < precursorrettime
select top 5 productrettime, precursorrettime, * from fragmentfile where productrettime > precursorrettime
select count(*) from fragmentfile where productrettime < precursorrettime
select count(*) from fragmentfile where productrettime > precursorrettime

select top 5 precursormobility, productmobility, * from fragmentfile where precursormobility > productmobility
select top 5 productmobility, precursormobility, * from fragmentfile where productmobility > precursormobility
select count(*) from fragmentfile where precursormobility > productmobility
select count(*) from fragmentfile where productmobility > precursormobility

select top 5 precursorrettime, precursormobility, * from fragmentfile where precursorrettime < precursormobility
select top 5 precursorrettime, precursormobility, * from fragmentfile where precursorrettime > precursormobility
select count(*) from fragmentfile where precursorrettime < precursormobility
select count(*) from fragmentfile where precursorrettime > precursormobility




select top 5 precursormobility, productmobility, * from fragmentfile where precursormobility = productmobility
select top 5 precursorrettime, productrettime, * from fragmentfile where precursorrettime <> productrettime

select count(*) from fragmentfile where precursormobility = productmobility
select count(*) from fragmentfile where precursormobility <> productmobility

select min(max)