with gold_per_minute as (SELECT 
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