with player_gold_data as (SELECT
    ll.address AS Address,
    ll.year,
    ll.Season,
    ll.blueTopChamp as champ,
    ll.blueTop AS Player,
    ll.goldblueTop AS GoldEarned
FROM
    leagueoflegends ll
WHERE
    ll.blueTop IS NOT NULL
    AND ll.goldblueTop IS NOT NULL
UNION ALL
SELECT
    ll.address AS Address,
        ll.year,
    ll.Season,
    ll.blueJungleChamp as champ,
    ll.blueJungle AS Player,
    ll.goldblueJungle AS GoldEarned
FROM
    leagueoflegends ll
WHERE
    ll.blueJungle IS NOT NULL
    AND ll.goldblueJungle IS NOT NULL
UNION ALL
SELECT
ll.address AS Address,
    ll.year,
    ll.Season,
    ll.blueMiddleChamp as champ,
    ll.blueMiddle AS Player,
    ll.goldblueMiddle AS GoldEarned
FROM
    leagueoflegends ll
WHERE
    ll.blueMiddle IS NOT NULL
    AND ll.goldblueMiddle IS NOT NULL
UNION ALL
SELECT
ll.address AS Address,
    ll.year,
    ll.Season,
    ll.blueADCChamp as champ,
    ll.blueADC AS Player,
    ll.goldblueADC AS GoldEarned
FROM
    leagueoflegends ll
WHERE
    ll.blueADC IS NOT NULL
    AND ll.goldblueADC IS NOT NULL
UNION ALL
SELECT
ll.address AS Address,
    ll.year,
    ll.Season,
    ll.blueSupportChamp as champ,
    ll.blueSupport AS Player,
    ll.goldblueSupport AS GoldEarned
FROM
    leagueoflegends ll
WHERE
    ll.blueSupport IS NOT NULL
    AND ll.goldblueSupport IS NOT NULL
UNION ALL
SELECT
ll.address AS Address,
    ll.year,
    ll.Season,
    ll.redTopChamp as champ,
    ll.redTop AS Player,
    ll.goldredTop AS GoldEarned
FROM
    leagueoflegends ll
WHERE
    ll.redTop IS NOT NULL
    AND ll.goldredTop IS NOT NULL
UNION ALL
SELECT
ll.address AS Address,
    ll.year,
    ll.Season,
    ll.redJungleChamp as champ,
    ll.redJungle AS Player,
    ll.goldredJungle AS GoldEarned
FROM
    leagueoflegends ll
WHERE
    ll.redJungle IS NOT NULL
    AND ll.goldredJungle IS NOT NULL
UNION ALL
SELECT
ll.address AS Address,
    ll.year,
    ll.Season,
    ll.redMiddleChamp as champ,
    ll.redMiddle AS Player,
    ll.goldredMiddle AS GoldEarned
FROM
    leagueoflegends ll
WHERE

    ll.redMiddle IS NOT NULL
    AND ll.goldredMiddle IS NOT NULL
UNION ALL
SELECT
ll.address AS Address,
    ll.year,
    ll.Season,
    ll.redADCChamp as champ,
    ll.redADC AS Player,
    ll.goldredADC AS GoldEarned
FROM
    leagueoflegends ll
WHERE
    ll.redADC IS NOT NULL
    AND ll.goldredADC IS NOT NULL
UNION ALL
SELECT
ll.address AS Address,
    ll.year,
    ll.Season,
    ll.redSupportChamp as champ,
    ll.redSupport AS Player,
    ll.goldredSupport AS GoldEarned
FROM
    leagueoflegends ll
WHERE
    ll.redSupport IS NOT NULL
    AND ll.goldredSupport IS NOT NULL),

gold_per_minute as (SELECT 
    Address,
    player_gold_data.year,
    player_gold_data.Season,
    player_gold_data.champ,
    player,
    --UNNEST(string_to_array((replace((substring(GoldEarned,2,LENGTH(GoldEarned)-2)),' ','')),',')) :: INT as gold,
    gold_sequence.value::INT as gold,
    ROW_NUMBER() over (PARTITION BY player, address order by ORDINALITY) as minute
from player_gold_data, LATERAL UNNEST(string_to_array((replace((substring(GoldEarned,2,LENGTH(GoldEarned)-2)),' ','')),',')) WITH ORDINALITY as gold_sequence(value,ORDINALITY)
)

select player,year,season, minute,champ,
    CASE    
        WHEN minute != 1 THEN gold - (LAG(gold,1,0) OVER (PARTITION BY player, address ORDER BY minute)) ELSE 0 END
         as previous_gold
From gold_per_minute
order by previous_gold DESC
LIMIT 100;