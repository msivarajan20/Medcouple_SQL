# refer to this link to read more about this method :
# http://d-scholarship.pitt.edu/7948/1/Seo.pdf

select a.Entity_ID
       ,a.median_entity
	   ,a.Q1
	   ,a.Q3
	   ,a.IQR
       ,round(percentile_cont(0.5) within group (order by H_i_j desc),3) MEDCOUPLE
       ,round(a.Q3+1.5*a.IQR*exp(4*medcouple),0) as ADJUSTED_BOXPLOT
       from (
select  a.Entity_ID
		,a.median_entity
		,a.Q1,a.Q3,a.IQR
		,a.PVS as Xi
		,b.PVS as Xj
		,(xj-a.median_entity)
		,(a.median_entity-xi)
		,xj-xi,
decode((xj-xi),0,0,((xj-a.median_entity)-(a.median_entity-xi))/(xj-xi)) as H_i_j from 
(select a.Entity_ID
	    ,Q1
		,Q3
		,IQR
		,PVS
		,median_entity 
		from entity_table a join 
(select Entity_ID 
		,percentile_cont(0.5) within group (order by pvs desc)median_entity
        ,percentile_cont(0.25) within group (order by pvs asc) Q1
        ,percentile_cont(0.75) within group (order by pvs asc) Q3
        ,percentile_cont(0.75) within group (order by pvs asc) - percentile_cont(0.25) within group (order by pvs asc) IQR 
from  entity_table a 
group by Entity_ID) b on a.Entity_ID =b.Entity_ID
where PVS <= median_entity 
order by PVS) a inner join
(select a.Entity_ID
		,Q1
		,Q3
		,IQR
		,PVS
		,median_entity 
		from entity_table a join 
(select Entity_ID, 
        percentile_cont(0.5) within group (order by pvs desc)median_entity,
        percentile_cont(0.25) within group (order by pvs asc) Q1,
        percentile_cont(0.75) within group (order by pvs asc) Q3,
        percentile_cont(0.75) within group (order by pvs asc)- percentile_cont(0.25) within group (order by pvs asc) IQR 
from  entity_table a
group by Entity_ID) b on a.Entity_ID =b.Entity_ID
where PVS>=median_entity 
order by PVS) 
b on a.Entity_ID=b.Entity_ID 
where XJ<>XI  
order by a.Entity_ID,XI,XJ)a
group by a.Entity_ID
	  ,a.median_entity
	  ,a.Q1
	  ,a.Q3
	  ,a.IQR