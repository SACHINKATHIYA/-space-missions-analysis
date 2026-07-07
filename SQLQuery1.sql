-- query 1 tottal Success rate 
SELECT 
 COUNT(*) AS total_missions,
SUM(CASE WHEN outcome = 'Success' THEN 1 ELSE 0 END) AS successful_missions,
  ROUND(100.0 * SUM(CASE WHEN outcome = 'Success' THEN 1 ELSE 0 END) / COUNT(*), 2) AS success_rate_pct
 FROM space_missions_cleaned;
-- query 2 Success rate by country
SELECT 
country,
COUNT(*) AS total_missions,
SUM(CASE WHEN outcome = 'Success' THEN 1 ELSE 0 END) AS successful_missions,
ROUND(100.0 * SUM(CASE WHEN outcome = 'Success' THEN 1 ELSE 0 END) / COUNT(*), 2) AS success_rate_pct
FROM space_missions_cleaned
GROUP BY country
ORDER BY total_missions DESC;
-- Query 3: Missions and success rate by decade
SELECT 
    decade,
    COUNT(*) AS total_missions,
    SUM(CASE WHEN outcome = 'Success' THEN 1 ELSE 0 END) AS successful_missions,
    ROUND(100.0 * SUM(CASE WHEN outcome = 'Success' THEN 1 ELSE 0 END) / COUNT(*), 2) AS success_rate_pct
FROM space_missions_cleaned
GROUP BY decade
ORDER BY decade;
-- Query 4: Cost per kg payload - reusable vs non-reusable rockets
SELECT 
    CASE WHEN rocket_reusable = 1 THEN 'Reusable' ELSE 'Expendable' END AS rocket_category,
    COUNT(*) AS total_missions,
    ROUND(AVG(cost_per_kg_payload), 2) AS avg_cost_per_kg,
    ROUND(AVG(estimated_cost_million_usd), 2) AS avg_mission_cost_million_usd
FROM space_missions_cleaned
WHERE cost_per_kg_payload IS NOT NULL
GROUP BY rocket_reusable;
-- Query 5: Risk classification by rocket operator
SELECT 
    rocket_operator,
    COUNT(*) AS total_missions,
    ROUND(100.0 * SUM(CASE WHEN outcome = 'Success' THEN 1 ELSE 0 END) / COUNT(*), 2) AS success_rate_pct,
    CASE 
        WHEN 100.0 * SUM(CASE WHEN outcome = 'Success' THEN 1 ELSE 0 END) / COUNT(*) >= 95 THEN 'A - Low Risk'
        WHEN 100.0 * SUM(CASE WHEN outcome = 'Success' THEN 1 ELSE 0 END) / COUNT(*) >= 85 THEN 'B - Medium Risk'
        ELSE 'C - High Risk'
    END AS risk_category
FROM space_missions_cleaned
GROUP BY rocket_operator
HAVING COUNT(*) >= 10  -- only include operators with at least 10 missions, otherwise the % is unreliable
ORDER BY success_rate_pct DESC;
-- Query 6: Mission type breakdown
SELECT 
    mission_type,
    COUNT(*) AS total_missions,
    ROUND(100.0 * SUM(CASE WHEN outcome = 'Success' THEN 1 ELSE 0 END) / COUNT(*), 2) AS success_rate_pct,
    ROUND(AVG(estimated_cost_million_usd), 2) AS avg_cost_million_usd
FROM space_missions_cleaned
GROUP BY mission_type
ORDER BY total_missions DESC;

-- Query 7: Human spaceflight missions by decade
SELECT 
    decade,
    COUNT(*) AS crewed_missions,
    SUM(crew_size) AS total_astronauts_flown,
    ROUND(100.0 * SUM(CASE WHEN outcome = 'Success' THEN 1 ELSE 0 END) / COUNT(*), 2) AS success_rate_pct
FROM space_missions_cleaned
WHERE mission_type = 'Human Spaceflight'
GROUP BY decade
ORDER BY decade;

-- Query 8: Government vs Private launches over time
SELECT 
    decade,
    CASE 
        WHEN rocket_operator IN ('SpaceX', 'Rocket Lab', 'Blue Origin', 'ULA', 'Arianespace', 'LandSpace') THEN 'Private'
        ELSE 'Government'
    END AS operator_type,
    COUNT(*) AS total_missions
FROM space_missions_cleaned
GROUP BY decade, 
    CASE 
        WHEN rocket_operator IN ('SpaceX', 'Rocket Lab', 'Blue Origin', 'ULA', 'Arianespace', 'LandSpace') THEN 'Private'
        ELSE 'Government'
    END
ORDER BY decade, operator_type;

-- Query 9: Cumulative launches per country over decades (running total)
SELECT 
    country,
    decade,
    COUNT(*) AS missions_this_decade,
    SUM(COUNT(*)) OVER (PARTITION BY country ORDER BY decade) AS cumulative_missions
FROM space_missions_cleaned
WHERE country IN ('United States', 'Soviet Union', 'Russia', 'China')
GROUP BY country, decade
ORDER BY country, decade;

-- Query 10: Top 10 launch sites by volume and success rate

SELECT TOP 10
    launch_site,
    launch_site_country,
    COUNT(*) AS total_launches,
    ROUND(100.0 * SUM(CASE WHEN outcome = 'Success' THEN 1 ELSE 0 END) / COUNT(*), 2) AS success_rate_pct
FROM space_missions_cleaned
GROUP BY launch_site, launch_site_country
ORDER BY total_launches DESC;