with prefect_list as (select 
    bresult,
    rresult,
    btowers,
    binhibs,
    bkills,
    rtowers,
    rinhibs,
    rkills,
    CASE
        WHEN bresult = TRUE THEN (
            CASE
                WHEN rtowers = '[]' AND rinhibs = '[]' AND rkills = '[]' then 1 ELSE 0 end)
        WHEN rresult = TRUE THEN (
            CASE
                WHEN btowers = '[]' AND binhibs = '[]' AND bkills = '[]' then 1 ELSE 0 end)
    END AS perfect_game
From leagueoflegends)

SELECT 
    sum(perfect_game) as total_perfect_games,
    ROUND((sum(perfect_game)::NUMERIC/count(*))*100,2) as perfect_game_percentage
FROM prefect_list

