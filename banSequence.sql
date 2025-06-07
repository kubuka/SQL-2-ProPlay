with ban_list as (select 
    address,
    team as team,
    ban_1 as bans,
    1 as ban_order
From bans
UNION ALL
select 
    address,
    team as team,
    ban_2 as bans,
    2 as ban_order
From bans
UNION ALL
select 
    address,
    team as team,
    ban_3 as bans,
    3 as ban_order
From bans
UNION ALL
select 
    address,
    team as team,
    ban_4 as bans,
    4 as ban_order
From bans
UNION ALL
select 
    address,
    team as team,
    ban_5 as bans,
    5 as ban_order
From bans)

SELECT 
    ll.year,
    ll.season,
    b.team,
    b.bans,
    b.ban_order,
    count(b.bans) as num_bans,
    round(count(b.bans) / sum(count(b.bans)) over (PARTITION BY ll.year,ll.season,b.team,b.ban_order) * 100, 2) as ban_percentage
From ban_list b
LEFT JOIN
    leagueoflegends ll on b.address = ll.address
where b.bans IS NOT NULL
GROUP BY
    ll.year,
    ll.season,
    b.team,
    b.bans,
    b.ban_order
ORDER BY
    ll.year,
    ll.season,
    b.team,
    b.ban_order,
    ban_percentage DESC