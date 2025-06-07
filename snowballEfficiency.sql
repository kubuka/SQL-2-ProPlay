with winning_team as (SELECT
    address,
    blueteamtag as tag,
    gamelength,
    bresult as result
from leagueoflegends
where bresult = true
UNION ALL
SELECT
    address,
    redteamtag as tag,
    gamelength,
    rresult as result
from leagueoflegends
where rresult = true)


SELECT winning_team.tag as tag,
    round(avg(gamelength - 15),2) as avg_minutes_till_end,
    tag_full.full as full_name
From winning_team
left JOIN
    tag_full on winning_team.tag = tag_full.tag
where winning_team.tag IS NOT NULL
GROUP BY winning_team.tag, full_name
ORDER BY avg_minutes_till_end asc
limit 10;
