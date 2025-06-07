with victim_list as (select 
    address,
    Time,
    ROW_NUMBER() OVER (PARTITION BY address ORDER BY Time asc) as kill_number,
    LOWER(trim(substring(Victim,POSITION(' ' in Victim)))) as victim_trunc
From kills
where 
    time IS NOT NULL)

SELECT 
    /*victim_list.victim_trunc,
    ll.blueTop,
    ll.blueJungle,
    ll.blueMiddle,
    ll.blueADC,
    ll.blueSupport,
    ll.redTop,
    ll.redJungle,
    ll.redMiddle,
    ll.redADC,
    ll.redSupport,*/
    count(*) as TotalKills,
    ROUND((count(*)/sum(count(*)) OVER())*100,2) as total_percent,
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
where victim_list.kill_number = 1
GROUP BY VictimPosition
ORDER by total_percent DESC

