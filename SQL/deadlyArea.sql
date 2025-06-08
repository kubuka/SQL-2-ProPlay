with time_pos as (select
    round(time,0) :: int as time,
    (x_pos :: int)/100 as x_pos,
    (y_pos :: int)/100 as y_pos
from kills
where time IS NOT NULL AND x_pos != 'TooEarly' AND y_pos != 'TooEarly')

select 
    x_pos * 10 as x_pos,
    y_pos * 10 as y_pos,
    count(*) as num_kills
From time_pos
group by x_pos, y_pos
order by num_kills desc
limit 100;