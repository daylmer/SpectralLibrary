select max(len(peptidesequence)) from fragmentfile 

select max(len(fragmentsequence)) from fragmentfile 


select top 1 * from fragmentfilebak
select max(len(proteinaccession)) from fragmentfilebak

select * from fragmentfile where len(fragmentsequence) > 31