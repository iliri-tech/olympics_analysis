--•	H3: Tradition and medals. Countries with a long history of winning medals in a specific sport (e.g., medals in at least 5 previous editions) are more likely to win medals in that sport again than countries with no prior medal history.

WITH country_sport_year AS (
  SELECT
    Sport, Year, NOC,
    MAX(IF(Medal != 'No Medal', 1, 0)) AS won_medal
  FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
  WHERE Year != 1906 AND Sport != 'Art Competitions'
  GROUP BY Sport, Year, NOC
),
with_history AS (
  SELECT
    *,
    IFNULL(SUM(won_medal) OVER w, 0) AS prior_medal_editions,
    COUNT(*) OVER w AS prior_entries
  FROM country_sport_year
  WINDOW w AS (
    PARTITION BY Sport, NOC ORDER BY Year
    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
  )
)

SELECT
  CASE
    WHEN prior_entries = 0 THEN '1. First time in this sport'
    WHEN prior_medal_editions = 0 THEN '2. Entered before, no medals'
    WHEN prior_medal_editions < 5 THEN '3. 1-4 prior medal editions'
    ELSE '4. 5+ prior medal editions'
  END AS history_group,
  COUNT(*) AS country_sport_editions,
  SUM(won_medal) AS medals_won,
  ROUND(SUM(won_medal) / COUNT(*) * 100, 1) AS medal_rate_pct
FROM with_history
GROUP BY history_group
ORDER BY history_group;