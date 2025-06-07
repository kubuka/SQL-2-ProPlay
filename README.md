# LeagueOfLegends-ProPlay-Analysis 🏆📊
This project is all about diving deep into pro League of Legends match data from 2014-2018. I'm talking advanced stuff here – figuring out winning strategies, how the meta shifted over the years, and what really made a difference for those top-tier players. I used SQL with PostgreSQL to crunch a huge dataset, focusing on the nitty-gritty details of pro performance and how it impacted game outcomes. Think of it as me leveling up my SQL skills while uncovering some cool insights into the world of esports!

# 📝Scripts Overview
1. [Most Effective Bot Lane Combination](#most-effective-bot-lane-combination)
2. [Position Most Frequently Dying for First Blood](#position-most-frequently-dying-for-first-blood)
3. [Frequency of Perfect Games](#frequency-of-perfect-games)
4. [Player with Most Gold Per Minute]
5. [Player with Most Unique Champions on a Role in a Season]
6. [Most "Deadly" Minutes in a Match]
7. [Most "Deadly" Places in a Match]
8. [Average Gold Earned Per Minute by Role]
9. [Typical Ban Order - Analysis of Most Probable Ban Sequence]
10. [Teams Best at Snowball]
11. [Teams Winning Throughout a Season]

## Most Effective Bot Lane Combination

This script (bot_lane_combo.sql) digs into professional matches to find out which champion duos in the bot lane (ADC and Support) had the highest win rates. It pulls data from both blue and red teams, combines them, and then calculates the win rate for each unique pair. To keep things statistically significant, it only considers combinations that appeared in more than 20 games.

### SQL
```sql
WITH bottom as (
    SELECT  
        blueadcchamp as champ1,
        bluesupportchamp as champ2,
        case WHEN bresult = TRUE THEN 1 else 0 end as win
    From matchinfo
    UNION ALL
    SELECT 
        redadcchamp as champ1,
        redsupportchamp as champ2,
        case WHEN rresult = TRUE THEN 1 else 0 end as win
    FROM matchinfo
)

SELECT  
    champ1,
    champ2,
    count(*) as total,
    sum(win) as wins,
    ROUND((sum(win)::NUMERIC/count(*))*100,2) as winrate
FROM bottom
GROUP BY champ1, champ2
HAVING count(*) > 20
ORDER BY winrate DESC;
```
| champ1   | champ2      | total | wins | winrate |
| :------- | :---------- | :---- | :--- | :------ |
| Twitch   | Janna       | 26    | 20   | 76.92   |
| Kalista  | Blitzcrank  | 31    | 23   | 74.19   |
| Kalista  | Taric       | 21    | 14   | 66.67   |
| Sivir    | Nami        | 66    | 44   | 66.67   |
| Ashe     | Trundle     | 38    | 25   | 65.79   |

**💡Insights:**
It looks like Twitch and Janna were a super potent duo back then, boasting an impressive 76.92% win rate! Other strong pairs include Kalista with Blitzcrank or Taric, and Sivir with Nami. This really highlights how specific champion synergies can completely dominate the bot lane in pro play. It's cool to see which combos truly shined over these years!

## Position Most Frequently Dying for First Blood
This script (first_blood_victim.sql) zeroes in on the infamous "first blood" to see which position was most often the initial casualty in pro games. It processes kill data to identify the very first death in each match and then maps the victim back to their in-game role, giving us a clear picture of who's taking the biggest risks (or getting caught out the most!) early on.

### SQL
```sql
WITH victim_list as (
    SELECT
        address,
        Time,
        ROW_NUMBER() OVER (PARTITION BY address ORDER BY Time asc) as kill_number,
        LOWER(trim(substring(Victim,POSITION(' ' in Victim)))) as victim_trunc
    From kills
    WHERE
        time IS NOT NULL
)

SELECT
    count(*) as TotalKills,
    ROUND((count(*)::NUMERIC/sum(count(*)) OVER())*100,2) as total_percent,
    CASE
        WHEN victim_list.victim_trunc = LOWER(trim(ll.redTop)) THEN 'Top'
        WHEN victim_list.victim_trunc = LOWER(trim(ll.redJungle)) THEN 'Jungle'
        WHEN victim_list.victim_trunc = LOWER(trim(ll.redMiddle)) THEN 'Middle'
        WHEN victim_list.victim_trunc = LOWER(trim(ll.redADC)) THEN 'ADC'
        WHEN victim_list.victim_trunc = LOWER(trim(ll.redSupport)) THEN 'Support'
        WHEN victim_list.victim_trunc = LOWER(trim(ll.blueTop)) THEN 'Top'
        WHEN victim_list.victim_trunc = LOWER(trim(ll.blueJungle)) THEN 'Jungle'
        WHEN victim_list.victim_trunc = LOWER(trim(ll.blueMiddle)) THEN 'Middle'
        WHEN victim_list.victim_trunc = LOWER(trim(ll.blueADC)) THEN 'ADC'
        WHEN victim_list.victim_trunc = LOWER(trim(ll.blueSupport)) THEN 'Support'
        ELSE 'Unknown'
    END AS VictimPosition
FROM victim_list
JOIN leagueoflegends ll on victim_list.address = ll.address
WHERE
    victim_list.kill_number = 1
GROUP BY VictimPosition
ORDER by total_percent DESC;
```
***ZDJECIE!!!!***



***💡Insights:***
Turns out, Top lane players were the most common victims of first blood by a good margin (28.07%)! This makes sense, as the top lane can be a more isolated and aggressive early-game environment, making it a prime target for enemy junglers or risky solo plays. Mid and Jungle also saw a fair share of early deaths, showing that early game skirmishes often revolve around these high-impact roles.

## Frequency of Perfect Games
This script (perfect_games.sql) checks how often pro League of Legends matches ended in a "perfect game." That means one team won without giving up any kills, towers, or inhibitors. It’s super rare, but a real sign of total domination!

### SQL
```sql
WITH prefect_list as (
    SELECT
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
                    WHEN rtowers = '[]' AND rinhibs = '[]' AND rkills = '[]' then 1 ELSE 0 END)
            WHEN rresult = TRUE THEN (
                CASE
                    WHEN btowers = '[]' AND binhibs = '[]' AND bkills = '[]' then 1 ELSE 0 END)
        END AS perfect_game
    From leagueoflegends
)

SELECT
    sum(perfect_game) as total_perfect_games,
    ROUND((sum(perfect_game)::NUMERIC/count(*))*100,2) as perfect_game_percentage
FROM prefect_list;
```
| total_perfect_games | perfect_game_percentage |
| :------------------ | :---------------------- |
| 37                  | 0.49                    |

💡Insights:
Perfect games are incredibly rare in pro play, happening in less than 0.5% of matches (just 37 games out of the entire dataset!). This really shows how high-level League of Legends games are almost always a back-and-forth struggle, and achieving a perfect win against other pros is a monumental feat!

## Player with Most Gold Per Minute
This script (gold_per_minute.sql) aims to identify which pro players had the most explosive gold income in a single minute during a match. It aggregates gold data for every player across all matches and then calculates the largest single-minute gold spike to highlight players who could rapidly snowball their advantage.

### SQL
```sql
WITH player_gold_data as (
    SELECT
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
        ll.redSupport AS Player,
        ll.goldredSupport AS GoldEarned
    FROM
        leagueoflegends ll
    WHERE
        ll.redSupport IS NOT NULL
        AND ll.goldredSupport IS NOT NULL
),

gold_per_minute as (
    SELECT
        Address,
        player_gold_data.year,
        player_gold_data.Season,
        player_gold_data.champ,
        player,
        gold_sequence.value::INT as gold,
        ROW_NUMBER() over (PARTITION BY player, address order by ORDINALITY) as minute
    FROM
        player_gold_data,
        LATERAL UNNEST(string_to_array((replace((substring(GoldEarned,2,LENGTH(GoldEarned)-2)),' ','')),',')) WITH ORDINALITY as gold_sequence(value,ORDINALITY)
)

SELECT
    player,
    year,
    season,
    minute,
    champ,
    CASE
        WHEN minute != 1 THEN gold - (LAG(gold,1,0) OVER (PARTITION BY player, address ORDER BY minute)) ELSE 0 END
    AS previous_gold
FROM
    gold_per_minute
ORDER BY previous_gold DESC
LIMIT 100;
```
| player  | year | season | minute | champ     | previous_gold |
| :------ | :--- | :----- | :----- | :-------- | :------------ |
| Smeb    | 2015 | Spring | 29     | Hecarim   | 2668          |
| Froggen | 2015 | Summer | 46     | Azir      | 2505          |
| PraY    | 2016 | Spring | 48     | Sivir     | 2381          |
| Lost    | 2017 | Summer | 26     | Varus     | 2377          |
| Sneaky  | 2016 | Summer | 30     | Sivir     | 2375          |
| Breeze  | 2016 | Spring | 42     | Lucian    | 2372          |
| Xico    | 2017 | Spring | 37     | Cassiopeia| 2365          |
| Freeze  | 2015 | Summer | 24     | Draven    | 2355          |
| Bang    | 2015 | Spring | 45     | Lucian    | 2330          |
| Raes    | 2017 | Summer | 26     | Xayah     | 2324          |

***💡Insights:***
It's fascinating to see players like Smeb (Hecarim) and Froggen (Azir) pulling in massive amounts of gold in a single minute, with Smeb hitting a peak of 2668 gold! This shows how some pros, particularly on specific champions, could have explosive power spikes by rapidly accumulating resources, often through clutch plays or dominating teamfights. These moments likely highlight key turning points where a player's farm quickly translated into a significant in-game lead.

## Player with Most Unique Champions on a Role in a Season
This script (unique_champions_per_player_per_role.sql) identifies which pro players showcased the widest champion pools on a single role within a given season. It aggregates data for every player, counting distinct champions played on each of their roles, giving us a look at the most versatile pros.

### SQL
``` sql
WITH player_champion_role_data AS (
    SELECT
        ll.address AS Address,
        ll.year,
        ll.season AS Season,
        ll.blueTop AS Player,
        ll.bluetopchamp AS Champion,
        'Top' AS Role
    FROM
        leagueoflegends ll
    WHERE
        ll.blueTop IS NOT NULL AND ll.blueTopChamp IS NOT NULL
    UNION ALL
    SELECT
        ll.address AS Address,
        ll.year,
        ll.season AS Season,
        ll.blueJungle AS Player,
        ll.blueJungleChamp AS Champion,
        'Jungle' AS Role
    FROM
        leagueoflegends ll
    WHERE
        ll.blueJungle IS NOT NULL AND ll.blueJungleChamp IS NOT NULL
    UNION ALL
    SELECT
        ll.address AS Address,
        ll.year,
        ll.season AS Season,
        ll.blueMiddle AS Player,
        ll.blueMiddleChamp AS Champion,
        'Middle' AS Role
    FROM
        leagueoflegends ll
    WHERE
        ll.blueMiddle IS NOT NULL AND ll.blueMiddleChamp IS NOT NULL
    UNION ALL
    SELECT
        ll.address AS Address,
        ll.year,
        ll.season AS Season,
        ll.blueADC AS Player,
        ll.blueADCChamp AS Champion,
        'ADC' AS Role
    FROM
        leagueoflegends ll
    WHERE
        ll.blueADC IS NOT NULL AND ll.blueADCChamp IS NOT NULL
    UNION ALL
    SELECT
        ll.address AS Address,
        ll.year,
        ll.season AS Season,
        ll.blueSupport AS Player,
        ll.blueSupportChamp AS Champion,
        'Support' AS Role
    FROM
        leagueoflegends ll
    WHERE
        ll.blueSupport IS NOT NULL AND ll.blueSupportChamp IS NOT NULL
    UNION ALL
    SELECT
        ll.address AS Address,
        ll.year,
        ll.season AS Season,
        ll.redTop AS Player,
        ll.redTopChamp AS Champion,
        'Top' AS Role
    FROM
        leagueoflegends ll
    WHERE
        ll.redTop IS NOT NULL AND ll.redTopChamp IS NOT NULL
    UNION ALL
    SELECT
        ll.address AS Address,
        ll.year,
        ll.season AS Season,
        ll.redJungle AS Player,
        ll.redJungleChamp AS Champion,
        'Jungle' AS Role
    FROM
        leagueoflegends ll
    WHERE
        ll.redJungle IS NOT NULL AND ll.redJungleChamp IS NOT NULL
    UNION ALL
    SELECT
        ll.address AS Address,
        ll.year,
        ll.season AS Season,
        ll.redMiddle AS Player,
        ll.redMiddleChamp AS Champion,
        'Middle' AS Role
    FROM
        leagueoflegends ll
    WHERE
        ll.redMiddle IS NOT NULL AND ll.redMiddleChamp IS NOT NULL
    UNION ALL
    SELECT
        ll.address AS Address,
        ll.year,
        ll.season AS Season,
        ll.redADC AS Player,
        ll.redADCChamp AS Champion,
        'ADC' AS Role
    FROM
        leagueoflegends ll
    WHERE
        ll.redADC IS NOT NULL AND ll.redADCChamp IS NOT NULL
    UNION ALL
    SELECT
        ll.address AS Address,
        ll.year,
        ll.season AS Season,
        ll.redSupport AS Player,
        ll.redSupportChamp AS Champion,
        'Support' AS Role
    FROM
        leagueoflegends ll
    WHERE
        ll.redSupport IS NOT NULL AND ll.redSupportChamp IS NOT NULL
)

SELECT
    year ||' ' || season AS YearSeason,
    Player,
    Role,
    COUNT(DISTINCT Champion) AS champions_played
From player_champion_role_data
GROUP BY YearSeason, Player, Role
order by champions_played desc
limit 10;
```
| yearseason  | player    | role   | champions_played |
| :---------- | :-------- | :----- | :--------------- |
| 2016 Spring | SaSin     | Middle | 25               |
| 2016 Summer | Seraph    | Top    | 21               |
| 2016 Summer | Sencux    | Middle | 20               |
| 2016 Spring | Faker     | Middle | 19               |
| 2016 Summer | Ninja     | Middle | 19               |
| 2015 Summer | Kuro      | Middle | 18               |
| 2017 Summer | Lourlo    | Top    | 18               |
| 2015 Summer | Ssumday   | Top    | 17               |
| 2016 Spring | fredy122  | Top    | 17               |
| 2015 Summer | Smeb      | Top    | 17               |

***💡Insights:***
It's pretty awesome to see players like SaSin in 2016 Spring playing a whopping 25 unique champions in the Middle lane! This highlights players with incredible champion pools, showing their adaptability and ability to play a wide variety of styles within their role, which is super valuable in competitive play. Faker also makes the top, as expected, showing his consistent versatility.

## Most "Deadly" Minutes in a Match
This script (deadly_minutes.sql) identifies the minutes in a professional League of Legends game that saw the highest number of kills. By analyzing kill timestamps, it pinpoints when the action was at its most intense, giving us a clear picture of the game's peak combat phases.

### SQL
``` sql
WITH time_pos as (
    SELECT
        round(time,0) :: int as time,
        x_pos,
        y_pos
    FROM
        kills
    WHERE
        time IS NOT NULL
)

SELECT
    time,
    count(*) as num_kills
FROM
    time_pos
GROUP BY
    time
ORDER BY
    num_kills desc;

```
***WYKRES!!!!!***


***💡Insights:***
Looking at the data, the mid-to-late game seems to be the most action-packed, with a noticeable spike in kills around the 20-27 minute mark! This period often aligns with major objective fights (Baron, Elder Dragon) and decisive teamfights, where teams are fully geared up and looking to force engagements to close out the game. It clearly highlights the most intense and pivotal phases of pro matches.

## Most "Deadly" Places in a Match
This script (deadly_places.sql) analyzes kill locations across professional games to pinpoint the areas of the map where the most action (and deaths!) occurred. By looking at the x_pos and y_pos coordinates of each kill, we can visualize the hot zones and understand which parts of the map were consistently contested or dangerous.

### SQL
```sql
WITH time_pos as (
    SELECT
        round(time,0) :: int as time,
        (x_pos :: int)/100 as x_pos,
        (y_pos :: int)/100 as y_pos
    FROM
        kills
    WHERE
        time IS NOT NULL AND x_pos != 'TooEarly' AND y_pos != 'TooEarly'
)

SELECT
    x_pos * 10 as x_pos,
    y_pos * 10 as y_pos,
    count(*) as num_kills
FROM
    time_pos
GROUP BY
    x_pos,
    y_pos
ORDER BY
    num_kills DESC
LIMIT 100;
```
***MAPKA***

***💡Insights:***
The kill map (which you'll generate from this data) is super interesting because it visually confirms what we often feel during games: mid lane, around objectives like Dragon and Baron, and jungle paths are major hotspots for combat. These are the places where teams clash most often, which makes perfect sense given their strategic importance.

## Average Gold Earned Per Minute by Role
This script (avg_gold_per_minute_by_role.sql) calculates the average gold earned by each role (Top, Jungle, Mid, ADC, Support) at every minute of professional games. This helps us understand the typical gold progression for different positions and how gold income varies throughout a match.

### SQL
```sql
WITH avg_min_diff_notspec as (
    SELECT
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
    GROUP BY type
)

SELECT
    type,
    avg_min_1_diff,
    avg_min_10_diff,
    avg_min_20_diff,
    avg_min_30_diff
FROM
    avg_min_diff_notspec
WHERE
    type NOT IN ('golddiff', 'goldred', 'goldblue')
ORDER BY
    type ASC;
```
| type            | avg_min_1_diff | avg_min_10_diff | avg_min_20_diff | avg_min_30_diff |
| :-------------- | :------------- | :-------------- | :-------------- | :-------------- |
| goldblueADC     | 495            | 2905            | 6811            | 11025           |
| goldblueJungle  | 495            | 2765            | 6092            | 9392            |
| goldblueMiddle  | 495            | 2944            | 6897            | 11017           |
| goldblueSupport | 503            | 1866            | 4271            | 6970            |
| goldblueTop     | 495            | 2736            | 6417            | 10326           |
| goldredADC      | 495            | 2889            | 6715            | 10925           |
| goldredJungle   | 495            | 2742            | 5998            | 9259            |
| goldredMiddle   | 495            | 2940            | 6851            | 10968           |
| goldredSupport  | 503            | 1860            | 4209            | 6877            |
| goldredTop      | 495            | 2716            | 6346            | 10250           |

***SKRYPT!!!***

***💡Insights:***
This data clearly shows how gold income progresses differently across roles in pro games. ADCs and Mid laners generally accumulate the most gold, especially as the game progresses (e.g., reaching over 11,000 gold by 30 minutes), reflecting their scaling carry potential. Supports consistently have the lowest gold income, highlighting their reliance on utility and vision rather than raw economy. The similar gold values between blue and red teams for each role suggest a relatively balanced competitive environment.

## Typical Ban Order - Analysis of Most Probable Ban Sequence
This script (typical_ban_order.sql) analyzes the ban phases in professional League of Legends matches to determine the most common champions banned at each stage. It aggregates ban data by year, season, team, and ban order (1st to 5th ban), revealing insights into evolving pro-play strategies and champion priority.

### SQL
```sql
WITH ban_list as (
    SELECT
        address,
        team as team,
        ban_1 as bans,
        1 as ban_order
    From bans
    UNION ALL
    SELECT
        address,
        team as team,
        ban_2 as bans,
        2 as ban_order
    From bans
    UNION ALL
    SELECT
        address,
        team as team,
        ban_3 as bans,
        3 as ban_order
    From bans
    UNION ALL
    SELECT
        address,
        team as team,
        ban_4 as bans,
        4 as ban_order
    From bans
    UNION ALL
    SELECT
        address,
        team as team,
        ban_5 as bans,
        5 as ban_order
    From bans
)

SELECT
    ll.year,
    ll.season,
    b.team,
    b.bans,
    b.ban_order,
    count(b.bans) as num_bans,
    round(count(b.bans)::NUMERIC / sum(count(b.bans)) OVER (PARTITION BY ll.year,ll.season,b.team,b.ban_order) * 100, 2) as ban_percentage
From ban_list b
LEFT JOIN
    leagueoflegends ll on b.address = ll.address
WHERE b.bans IS NOT NULL
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
    ban_percentage DESC;
```
***SKRYPT I TABELA ZE SKRYPTU***

***💡Insights:***
This data reveals dynamic ban priorities across seasons and teams. For example, Kassadin and Lee Sin were frequently targeted in the early ban phases of 2014 Spring, indicating their high threat level or meta dominance at the time. Analyzing these patterns can show how teams adapted their strategies to counter strong champions or specific opponent compositions.

## Teams Best at Snowball 
This script (snowball_efficiency.sql) aims to identify which professional teams were most effective at closing out games quickly once they gained an advantage. It calculates the average game length minus 15 minutes for winning teams, effectively measuring how fast they could end a match from a mid-game point. Teams with lower values here demonstrate superior snowballing capabilities.

### SQL
```sql
WITH winning_team as (
    SELECT
        address,
        blueteamtag as tag,
        gamelength,
        bresult as result
    FROM
        leagueoflegends
    WHERE bresult = true
    UNION ALL
    SELECT
        address,
        redteamtag as tag,
        gamelength,
        rresult as result
    FROM
        leagueoflegends
    WHERE rresult = true
)

SELECT
    winning_team.tag as tag,
    round(avg(gamelength - 15),2) as avg_minutes_till_end,
    tag_full.full as full_name
FROM
    winning_team
LEFT JOIN
    tag_full on winning_team.tag = tag_full.tag
WHERE winning_team.tag IS NOT NULL
GROUP BY
    winning_team.tag,
    full_name
ORDER BY avg_minutes_till_end asc
LIMIT 10;
```
| tag     | avg_minutes_till_end | full_name           |
| :------ | :------------------- | :------------------ |
| TY      | 12.50                | Team Yuhi           |
| COW     | 13.00                | Team Coast          |
| SSW     | 14.20                | Samsung White       |
| MC      | 15.00                | Marist Red Foxes    |
| NGU     | 15.00                | Vungtau Never Give Up |
| TLA     | 15.00                | Team Liquid Academy |
| FH      | 15.33                | Team Flash          |
| YC      | 16.00                | BeykentUni YouthCREW |
| AF      | 16.17                | Afreeca Freecs      |
| Winners | 17.00                | Winners             |

***PYTHON I WYJASNIENIE***

***💡Insights:***
Teams like Team Yuhi (TY) and Team Coast (COW) show impressive "snowball efficiency," finishing games on average just 12.5 and 13.0 minutes after the 15-minute mark, respectively. This indicates their ability to quickly convert early advantages into decisive victories, showcasing strong mid-game coordination and execution. Samsung White (SSW) also appears high on the list, reinforcing their reputation as a highly efficient and dominant team.

## Teams Winning Throughout a Season
This script (winning_teams_per_season.sql) identifies professional teams that went undefeated for an entire season (Spring or Summer). It checks if a team's total games played equals their total wins within a specific season, highlighting truly dominant performances.

### SQL
```sql
WITH grupped_teams as (
    SELECT
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
    From matchinfo
),

match_stats as (
    SELECT
        year,
        season,
        tag,
        result,
        count(*) over(PARTITION BY year,season,tag) as games_played,
        sum(result::int) over(PARTITION by year,season,tag) as wins
    From grupped_teams
    WHERE tag IS NOT NULL
)

SELECT
    year,
    season,
    tag,
    games_played
From match_stats
WHERE games_played = wins
GROUP BY year,season,tag,games_played
ORDER by games_played desc;
```
| year | season | tag | games_played |
| :--- | :----- | :-- | :----------- |
| 2018 | Spring | SUP | 5            |
| 2018 | Spring | FOX | 4            |
| 2018 | Spring | GRX | 4            |
| 2018 | Spring | LGC | 4            |
| 2018 | Spring | ORD | 4            |
| 2015 | Spring | EG  | 3            |
| 2016 | Spring | CST | 3            |
| 2016 | Spring | GMB | 3            |
| 2016 | Summer | FH  | 3            |
| 2016 | Summer | REN | 3            |

***💡Insights:***
It's super interesting to see teams like SUP in 2018 Spring manage to go undefeated for 5 games! While these streaks might not represent full seasons (as the dataset might not contain all games for all teams), it highlights instances of absolute dominance within a given set of matches. Finding teams that consistently win, even for shorter periods, shows their high level of play and strategic strength during those specific seasons.

## 📊 Project Summary
This project delved into professional League of Legends match data from 2014-2018, leveraging SQL with PostgreSQL to extract meaningful insights. We explored various aspects of pro play, including:

- **Champion Synergies**: Identifying highly effective bot lane champion combinations with impressive win rates (e.g., Twitch and Janna at 76.92%).

- **Early Game Dynamics**: Analyzing first blood occurrences, revealing that Top lane players were most frequently the initial casualties (28.07%).

- **Game Dominance**: Quantifying the rarity of "perfect games," which occurred in less than 0.5% of matches, highlighting the competitive nature of pro play.

- **Player Economy**: Pinpointing moments of explosive gold income for individual players and tracking average gold progression across different roles.

- **Strategic Adaptations**: Examining ban priorities by season and team, showcasing how strategies evolved over time.

- **Game Pace & Efficiency**: Identifying teams highly proficient in snowballing advantages into quick victories.

- **Map Hotspots**: Visualizing the most "deadly" areas on the map, confirming that objectives and mid lane are key battlegrounds.

These analyses provide a comprehensive overview of strategic trends, player performance metrics, and the evolving meta in professional League of Legends over a significant period.

## 🧠 What I Learned
This project was a fantastic opportunity to deepen my SQL skills, particularly with advanced PostgreSQL features. I gained hands-on experience in:

 - **Complex Query Construction**: Writing intricate WITH clauses (CTEs), using UNION ALL for data aggregation, and applying window functions like ROW_NUMBER() and LAG() for sequential analysis.

- **Data Transformation**: Mastering string manipulation functions (substring, replace, trim, string_to_array) to clean and prepare raw data for analysis.

- **Insightful Aggregations**: Effectively using COUNT(DISTINCT), SUM, and AVG with GROUP BY and OVER (PARTITION BY) to derive meaningful statistics.

- **Data Visualization Concepts**: Understanding how SQL results can be translated into visual insights, even when the visualization itself is handled by a separate tool (like the Python script for map plotting). This reinforced the importance of data formatting for external tools.

- **Understanding Esports Analytics**: Gained a deeper appreciation for the granular data available in esports and how it can be used to dissect game strategy, player performance, and meta shifts.

Overall, this project significantly enhanced my ability to query, analyze, and interpret large datasets, providing valuable experience in drawing actionable insights from complex structured data.
