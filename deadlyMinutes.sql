with time_pos as (select
    round(time,0) :: int as time,
    x_pos,
    y_pos
from kills
where time IS NOT NULL)

select 
    time,
    count(*) as num_kills
From time_pos
group by time
order by time asc

