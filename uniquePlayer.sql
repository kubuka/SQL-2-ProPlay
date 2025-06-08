SELECT 
    year ||' ' || season AS YearSeason,
    Player,
    Role,
    COUNT(DISTINCT Champion) AS champions_played
From player_champion_role_data
GROUP BY YearSeason, Player, Role
order by champions_played desc
limit 10;