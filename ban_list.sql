CREATE VIEW ban_list as select 
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
From bans
