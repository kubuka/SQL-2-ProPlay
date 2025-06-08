
with avg_min_diff_notspec as (select
type,
round(avg(min_1:: INT),0) as avg_min_1_diff,
round(avg(min_2:: INT),0) as avg_min_2_diff,
round(avg(min_3:: INT),0) as avg_min_3_diff,
round(avg(min_4:: INT),0) as avg_min_4_diff,
round(avg(min_5:: INT),0) as avg_min_5_diff,
round(avg(min_6:: INT),0) as avg_min_6_diff,
round(avg(min_7:: INT),0) as avg_min_7_diff,
round(avg(min_8:: INT),0) as avg_min_8_diff,
round(avg(min_9:: INT),0) as avg_min_9_diff,
round(avg(min_10:: INT),0) as avg_min_10_diff,
round(avg(min_11:: INT),0) as avg_min_11_diff,
round(avg(min_12:: INT),0) as avg_min_12_diff,
round(avg(min_13:: INT),0) as avg_min_13_diff,
round(avg(min_14:: INT),0) as avg_min_14_diff,
round(avg(min_15:: INT),0) as avg_min_15_diff,
round(avg(min_16:: INT),0) as avg_min_16_diff,
round(avg(min_17:: INT),0) as avg_min_17_diff,
round(avg(min_18:: INT),0) as avg_min_18_diff,
round(avg(min_19:: INT),0) as avg_min_19_diff,
round(avg(min_20:: INT),0) as avg_min_20_diff,
round(avg(min_21:: INT),0) as avg_min_21_diff,
round(avg(min_22:: INT),0) as avg_min_22_diff,
round(avg(min_23:: INT),0) as avg_min_23_diff,
round(avg(min_24:: INT),0) as avg_min_24_diff,
round(avg(min_25:: INT),0) as avg_min_25_diff,
round(avg(min_26:: INT),0) as avg_min_26_diff,
round(avg(min_27:: INT),0) as avg_min_27_diff,
round(avg(min_28:: INT),0) as avg_min_28_diff,
round(avg(min_29:: INT),0) as avg_min_29_diff,
round(avg(min_30:: INT),0) as avg_min_30_diff,
round(avg(min_31:: INT),0) as avg_min_31_diff,
round(avg(min_32:: INT),0) as avg_min_32_diff,
round(avg(min_33:: INT),0) as avg_min_33_diff,
round(avg(min_34:: INT),0) as avg_min_34_diff,
round(avg(min_35:: INT),0) as avg_min_35_diff,
round(avg(min_36:: INT),0) as avg_min_36_diff
FROM
    gold
    GROUP BY type)



select *
From avg_min_diff_notspec
where type != 'golddiff' AND type != 'goldred' AND type != 'goldblue'
order by reverse(type) asc

--zrobic dla kazdego typu osobno

    /*
avg_win_site as (select 
    CASE
        when bResult = true then 'blue'
        when bResult = false then 'red'
        end as team_win,
    count(*) as num_games,
    round(count(*)/
        sum(count(*)) over () * 100, 2) as win_percentage,
    sum(count(*)) over () as total_games
from leagueoflegends ll 
group by team_win)
*/

