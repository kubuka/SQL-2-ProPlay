CREATE VIEW player_champion_role_data AS 
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

