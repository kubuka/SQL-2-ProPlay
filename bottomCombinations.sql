WITH bottom  as (
    SELECT  blueadcchamp as champ1,
        bluesupportchamp as champ2,
        case WHEN bresult = TRUE THEN 1 else 0 end as win
From matchinfo
    UNION ALL
    SELECT  redadcchamp as champ1,
        redsupportchamp as champ2,
        case WHEN rresult = TRUE THEN 1 else 0 end as win
    FROM matchinfo
)

SELECT  champ1,
        champ2,
        count(*) as total,
        sum(win) as wins,
        ROUND((sum(win)::NUMERIC/count(*))*100,2) as winrate
FROM bottom
GROUP BY champ1,
        champ2
HAVING count(*) > 20
ORDER BY winrate DESC
        



