# LeagueOfLegends-ProPlay-Analysis 🏆📊
This project is all about diving deep into pro League of Legends match data from 2014-2018. I'm talking advanced stuff here – figuring out winning strategies, how the meta shifted over the years, and what really made a difference for those top-tier players. I used SQL with PostgreSQL to crunch a huge dataset, focusing on the nitty-gritty details of pro performance and how it impacted game outcomes. Think of it as me leveling up my SQL skills while uncovering some cool insights into the world of esports!

# 📝Scripts Overview
1. [Most Effective Bot Lane Combination](#most-effective-bot-lane-combination)
2. [Position Most Frequently Dying for First Blood](#position-most-frequently-dying-for-first-blood)
3. [Frequency of Perfect Games](#frequency-of-perfect-games)
4. [Player with Most Gold Per Minute](#player-with-most-gold-per-minute)
5. [Player with Most Unique Champions](#player-with-most-unique-champions)
6. [Most "Deadly" Minutes in a Match](#most-deadly-minutes-in-a-match)
7. [Most "Deadly" Places in a Match](#most-deadly-places-in-a-match)
8. [Average Gold Earned Per Minute](#average-gold-earned-per-minute)
9. [Typical Ban Order](#typical-ban-order)
10. [Teams Best at Snowball](#teams-best-at-snowball)
11. [Teams Winning Throughout a Season](#teams-winning-throughout-a-season)

12. [Summary](#summary)


## Most Effective Bot Lane Combination

This script (`bottomCombinations.sql`) digs into professional matches to find out which champion duos in the bot lane (ADC and Support) had the highest win rates. It pulls data from both blue and red teams, combines them, and then calculates the win rate for each unique pair. To keep things statistically significant, it only considers combinations that appeared in more than 20 games.

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
This script (`firstbloodRole.sql`) zeroes in on the infamous "first blood" to see which position was most often the initial casualty in pro games. It processes kill data to identify the very first death in each match and then maps the victim back to their in-game role, giving us a clear picture of who's taking the biggest risks (or getting caught out the most!) early on.

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
![kills_by_position](https://github.com/user-attachments/assets/e35706b4-184d-409e-b05a-c221f3bea38d)



***💡Insights:***
Turns out, Top lane players were the most common victims of first blood by a good margin (28.07%)! This makes sense, as the top lane can be a more isolated and aggressive early-game environment, making it a prime target for enemy junglers or risky solo plays. Mid and Jungle also saw a fair share of early deaths, showing that early game skirmishes often revolve around these high-impact roles.

## Frequency of Perfect Games
This script (`perfectGames.sql`) checks how often pro League of Legends matches ended in a "perfect game." That means one team won without giving up any kills, towers, or inhibitors. It’s super rare, but a real sign of total domination!

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
This script (`goldEarned.sql`) aims to identify which pro players had the most explosive gold income in a single minute during a match. It aggregates gold data for every player across all matches and then calculates the largest single-minute gold spike to highlight players who could rapidly snowball their advantage (`player_gold_data.sql` view used).

### SQL
```sql
with gold_per_minute as (
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
It's fascinating to see players like Smeb (Hecarim) and Froggen (Azir) pulling in massive amounts of gold in a single minute, with Smeb hitting a peak of 2668 gold! This shows how some pros, particularly on specific champions, could have explosive power spikes by rapidly accumulating resources, often through clutch plays or dominating teamfights.

## Player with Most Unique Champions
This script (`uniquePlayer.sql`) identifies which pro players showcased the widest champion pools on a single role within a given season. It aggregates data for every player, counting distinct champions played on each of their roles, giving us a look at the most versatile pros (`player_champion_role_data.sql` view used).

### SQL
``` sql
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

## Most Deadly Minutes in a Match
This script (`deadlyMinutes`.sql) identifies the minutes in a professional League of Legends game that saw the highest number of kills. By analyzing kill timestamps, it pinpoints when the action was at its most intense, giving us a clear picture of the game's peak combat phases.

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
![num_kills_vs_time](https://github.com/user-attachments/assets/58e22bcb-3262-47a4-8d1f-1c1051f51644)


***💡Insights:***
Looking at the data, the mid-to-late game seems to be the most action-packed, with a noticeable spike in kills around the 20-27 minute mark! This period often aligns with major objective fights (Baron/Dragons) and decisive teamfights, where teams are fully geared up and looking to force engagements to close out the game. It clearly highlights the most intense and pivotal phases of pro matches.

## Most Deadly Places in a Match
This script (`deadlyArea.sql`) analyzes kill locations across professional games to pinpoint the areas of the map where the most action (and deaths!) occurred. By looking at the x_pos and y_pos coordinates of each kill, we can visualize the hot zones and understand which parts of the map were consistently contested or dangerous.

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

### PYTHON
```python
from PIL import Image, ImageDraw, ImageFilter
import pandas as pd
import math

def zaznacz_punkt_na_mapie(csv_file, map_width, map_height, file_name = "mapa_z_punktem.png", dots=10):  
    

    df = pd.read_csv(csv_file)
    if len(df) < dots:
        to_draw = len(df)
    else: to_draw = df.head(dots)

    obraz = Image.open('lol_map.jpg')
    
    rysuj = ImageDraw.Draw(obraz)
    for i, row in enumerate(to_draw.itertuples()):
            x_pos = int(row.x_pos*10)
            y_pos = int(row.y_pos*10)
            y_pillow = map_height  - y_pos/2 
            r = 255
            g = int(255 * (i / dots))
            b = int(255 * (i / dots))
            
            
            dot_size = 50-i*2
            print(f"dot_size: {dot_size}")
            color = (r, g, b)
            rysuj.ellipse([x_pos/2 - dot_size // 2, y_pillow - dot_size // 2,
                x_pos/2 + dot_size // 2, y_pillow + dot_size // 2],
                fill=color, outline='white', width=1)
    
    
    obraz.save(file_name)
    print(f"saved'{file_name}'")

szerokosc = 800
wysokosc = 800
csv_file = 'deathPositions.csv'

zaznacz_punkt_na_mapie(csv_file,szerokosc, wysokosc)
```
### Visualization
To further enhance the understanding of these "deadly places," I developed a Python script (`mapka.py`) to visualize the top kill locations on a map of the game. This script reads the output of the SQL query (expected to be in a CSV file named (`deathPositions.csv`)), which contains the aggregated x_pos, y_pos, and num_kills for the most frequent kill locations.

***Color***: Creates a gradient from vibrant red (for the absolute deadliest spots) towards a lighter pink as the "deadliness" decreases, making the most impactful areas stand out.


![mapa_z_punktem](https://github.com/user-attachments/assets/0acf6c79-66be-411a-a854-76f49f815a44)

***💡Insights:***
The visualization clearly identifies key areas of intense combat:

- **Lane Dominance**: Particularly deadly zones include the bot lane on the blue side, the top lane on the blue side, and the mid lane on the red side. These areas consistently show a high frequency of kills, indicating their critical importance in map control and engagements.
- **Crucial Objective**: The Baron Nashor pit stands out as another primary hot zone, confirming its status as a pivotal objective where significant team fights occur.

## Average Gold Earned Per Minute
This script (`minute_gold.sql`) calculates the average gold earned by each role (Top, Jungle, Mid, ADC, Support) at every minute of professional games. This helps us understand the typical gold progression for different positions and how gold income varies throughout a match.

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
(those iterations were written (ofc), I was too lazy do do it my self lol)
```python
for i in range(start_minute, end_minute + 1):
        select_columns_cte.append(f"        round(avg(min_{i}:: INT),0) as avg_min_{i}_diff")
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

After retrieving the average gold data from the database, I further processed it using another Python script (`positionGoldMinute.py`). This script reads the raw data and calculates the gold difference between the Blue Team and the Red Team for each role at specific minute intervals.
```python
import pandas as pd

df = pd.read_csv('position_gold_minute.csv')
print(df.columns)
df_index = df.set_index('type')
diff_cols = df_index.columns
diff = pd.DataFrame(columns=diff_cols)

diff.loc['adcDiff'] = df_index.loc['goldblueADC', diff_cols] - df_index.loc['goldredADC', diff_cols]
diff.loc['supDiff'] = df_index.loc['goldblueSupport', diff_cols] - df_index.loc['goldredSupport', diff_cols]
diff.loc['jngDiff'] = df_index.loc['goldblueJungle', diff_cols] - df_index.loc['goldredJungle', diff_cols]
diff.loc['midDiff'] = df_index.loc['goldblueMiddle', diff_cols] - df_index.loc['goldredMiddle', diff_cols]
diff.loc['topDiff'] = df_index.loc['goldblueTop', diff_cols] - df_index.loc['goldredTop', diff_cols]

print(diff)
diff.to_csv('position_gold_minute_diff.csv', index=True)
```
And here's the gold difference between Blue Team and Red Team for each role:

| type      | avg_min_1_diff | avg_min_10_diff | avg_min_20_diff | avg_min_30_diff |
| :-------- | :------------- | :-------------- | :-------------- | :-------------- |
| adcDiff   | 0              | 16              | 96              | 100             |
| supDiff   | 0              | 6               | 62              | 93              |
| jngDiff   | 0              | 23              | 94              | 133             |
| midDiff   | 0              | 4               | 46              | 49              |
| topDiff   | 0              | 20              | 71              | 76              |

***💡Insights:***
This data clearly shows how gold income progresses differently across roles in pro games. ADCs and Mid laners generally accumulate the most gold, especially as the game progresses (e.g., reaching over 11,000 gold by 30 minutes), reflecting their scaling carry potential. You can actually see that the Blue Team usually has a bit more gold on average. The main reason for that seems to be that their win rate is just a tiny bit higher than 50%.

## Typical Ban Order
This script (`banSequence.sql`) analyzes the ban phases in professional League of Legends matches to determine the most common champions banned at each stage. It aggregates ban data by year, season, team, and ban order (1st to 5th ban), revealing insights into evolving pro-play strategies and champion priority (`ban_list.sql` view used).

### SQL
```sql
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
### Data Analysis with Python

While the SQL query aggregates ban data, a further Python script was developed to process these results and specifically highlight the most probable bans for each team per season and year. This script reads the aggregated ban data (e.g., from ban_order.csv), groups it by year, season, and team, and then identifies the top 5 (or top 3 for years before 2017, reflecting changes in the ban phase structure) unique champions with the highest ban percentage. This allows for a more focused analysis of ban patterns.

```python
import pandas as pd

df = pd.read_csv('ban_order.csv')

unique_bans_per_team = df.groupby(['year', 'season','team','bans'])['ban_percentage'].max().reset_index()
top_5_unique_bans_per_team = unique_bans_per_team.groupby(['year', 'season', 'team']).apply(
    lambda x: x.sort_values(by='ban_percentage', ascending=False).head(5)
).reset_index(drop=True)
i = 1
for (year, season,team), group in top_5_unique_bans_per_team.groupby(['year', 'season','team']):
    i+=1
    if i%2 == 0:
        print("*" * 40)
        print("\n")
    print(f"Top probable bans: {year}, season: {season}, team: {team[:-4]}")
    if year < 2017:
        for index, row in group.head(3).iterrows():
            print(f"  - {row['bans']}: {row['ban_percentage']:.2f}%")
        print("\n")
    else:
        for index, row in group.head(5).iterrows():
            print(f"  - {row['bans']}: {row['ban_percentage']:.2f}%")
        print("\n")
```
```markdown
### Top Probable Bans by Year, Season, and Team

#### 2014 Summer

**Blue Team:**
* Ryze: 18.18%
* Maokai: 16.88%
* Alistar: 15.38%

**Red Team:**
* Zilean: 23.08%
* Alistar: 21.79%
* LeeSin: 12.82%

#### 2015 Spring

**Blue Team:**
* Leblanc: 8.51%
* Lissandra: 7.22%
* Kassadin: 7.07%

**Red Team:**
* RekSai: 8.62%
* Leblanc: 8.05%
* Zed: 6.08%

### and so on...
```

***💡Insights:***
Champions like Ryze, Maokai, and Alistar were top bans in early seasons, while later, Leblanc, Camille, and Rengar gained prominence. The stark difference in Zac's ban rate for the red team in 2017 Summer (35.19%) highlights single-champion meta dominance. Analyzing these patterns shows how teams adapted strategies to counter strong champions or specific opponent compositions, with some champions maintaining relevance across multiple seasons.

## Teams Best at Snowball 
This script (`snowballEfficiency.sql`) aims to identify which professional teams were most effective at closing out games quickly once they gained an advantage. It calculates the average game length minus 15 minutes for winning teams, effectively measuring how fast they could end a match from a mid-game point. Teams with lower values here demonstrate superior snowballing capabilities.

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
I tried digging up a database or API with all the team names and their tags, but I only managed to find some of them in the esports-api. The rest of the missing teams were filled in by AI, so there's a good chance some of the less common names got a bit messed up. Sorry 😬

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

***💡Insights:***
Teams like Team Yuhi (TY) and Team Coast (COW) show impressive "snowball efficiency," finishing games on average just 12.5 and 13.0 minutes after the 15-minute mark, respectively. This indicates their ability to quickly convert early advantages into decisive victories, showcasing strong mid-game coordination and execution. Samsung White (SSW) also appears high on the list, reinforcing their reputation as a highly efficient and dominant team.

## Teams Winning Throughout a Season
This script (`winstreak.sql`) identifies professional teams that went undefeated for an entire season. It checks if a team's total games played equals their total wins within a specific season, highlighting truly dominant performances.

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

## Summary

### 📊 Project Summary
This project delved into professional League of Legends match data from 2014-2018, leveraging SQL with PostgreSQL to extract meaningful insights. We explored various aspects of pro play, including:

- **Champion Synergies**: Identifying highly effective bot lane champion combinations with impressive win rates (e.g., Twitch and Janna at 76.92%).
- **Early Game Dynamics**: Analyzing first blood occurrences, revealing that Top lane players were most frequently the initial casualties (28.07%).
- **Game Dominance**: Quantifying the rarity of "perfect games," which occurred in less than 0.5% of matches, highlighting the competitive nature of pro play.
- **Player Economy**: Pinpointing moments of explosive gold income for individual players and tracking average gold progression across different roles.
- **Strategic Adaptations**: Examining ban priorities by season and team, showcasing how strategies evolved over time.
- **Game Pace & Efficiency**: Identifying teams highly proficient in snowballing advantages into quick victories.
- **Map Hotspots**: Visualizing the most "deadly" areas on the map, confirming that objectives and mid lane are key battlegrounds.

These analyses provide a comprehensive overview of strategic trends, player performance metrics, and the evolving meta in professional League of Legends over a significant period.

### 🧠 What I Learned
This project was a fantastic opportunity to deepen my SQL skills, particularly with advanced PostgreSQL features. I gained hands-on experience in:
- ***Complex Query Construction***: I built intricate queries using `WITH` clauses (CTEs) to break down complex problems, employed `UNION ALL` for seamless data aggregation, and leveraged window functions like `ROW_NUMBER()` and `LAG()` for sequential analysis, which was crucial for tracking changes over time (like gold earned per minute).
- ***Data Transformation***: I mastered string manipulation functions such as `substring`, `replace`, `trim`, and `string_to_array`. This allowed me to clean and prepare raw data for analysis, transforming messy inputs into structured information ready for querying.
- ***Insightful Aggregations***: I effectively used `COUNT()`, `SUM`, and `AVG` in conjunction with `GROUP BY` and `OVER (PARTITION BY)` clauses to derive meaningful statistics about win rates, kill frequencies, and player performance.
- ***Database Optimization with Views***: I gained practical experience in creating and utilizing SQL views. This allowed me to abstract complex queries into simplified virtual tables, making the database more manageable.
- ***Data Visualization Concepts***: Even when the visualization was handled by a separate tool (like the Python script for map plotting), I gained a strong understanding of how SQL results can be translated into visual insights.
- ***Understanding Esports Analytics***: Gained a deeper appreciation for the granular data available in esports and how it can be used to dissect game strategy, player performance, and meta shifts.
  
Overall, this project significantly enhanced my ability to query, analyze, and interpret large datasets, providing valuable experience in drawing meaningful conclusions from complex structured data.
