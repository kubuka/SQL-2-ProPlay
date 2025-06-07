with grupped_teams as (SELECT 
    blueteamtag as tag,
    bresult as result,
    season,
    year
From matchinfo
UNION ALL
SELECT
    redteamtag as tag,
    rresult as result,
    season,
    YEAR
From matchinfo),

match_stats as (SELECT 
    year,
    season,
    tag,
    result,
    count(*) over(PARTITION BY year,season,tag) as games_played,
    sum(result::int) over(PARTITION by year,season,tag) as wins
from grupped_teams
where tag IS NOT NULL)

SELECT 
    year,
    season,
    tag,
    games_played
From match_stats
where games_played = wins
group by year,season,tag,games_played
ORDER by games_played desc

