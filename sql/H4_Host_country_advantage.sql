--	H4: Host country advantage. Host countries win significantly more medals in the year they host the Games than in the editions immediately before and after

WITH sport_medals AS (
  SELECT
    Season, Year, NOC, Sport,
    COUNT(DISTINCT IF(Medal != 'No Medal', CONCAT(Event, '|', Medal), NULL)) AS medals
  FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
  WHERE Year != 1906 AND Sport != 'Art Competitions'
  GROUP BY Season, Year, NOC, Sport
),
country_year AS(
  SELECT 
  Season, Year, NOC, SUM(medals) AS total_medals
  FROM sport_medals
  GROUP BY Season, Year, NOC
),
with_neighbors AS (
  SELECT
    *,
    LAG(Year)          OVER w AS year_before,
    LAG(total_medals)  OVER w AS medals_before,
    LEAD(Year)         OVER w AS year_after,
    LEAD(total_medals) OVER w AS medals_after
  FROM country_year
  WINDOW w AS (PARTITION BY Season, NOC ORDER BY Year)
)
,host_results AS (
SELECT
  h.Season,
  h.Year,
  h.host_noc,
  n.year_before,
  n.medals_before,
  n.total_medals AS host_year_medals,
  n.year_after,
  n.medals_after,
  n.total_medals - n.medals_before AS change_vs_before,
  ROUND(SAFE_DIVIDE(n.total_medals - n.medals_before, n.medals_before) * 100, 1) AS pct_vs_before
FROM `olympic-games-data-analysis.olympicsAnalysis.host_countries` AS h
JOIN with_neighbors AS n
  ON h.Season = n.Season AND h.Year = n.Year AND h.host_noc = n.NOC
ORDER BY h.Season, h.Year)

SELECT
  Season,
  COUNTIF(medals_before IS NOT NULL) AS compared_with_before,
  COUNTIF(change_vs_before > 0) AS better_than_before,
  COUNTIF(medals_before IS NOT NULL AND medals_after IS NOT NULL) AS compared_both_sides,
  COUNTIF(medals_before IS NOT NULL AND medals_after IS NOT NULL
          AND host_year_medals > medals_before
          AND host_year_medals > medals_after) AS peak_in_host_year,
  APPROX_QUANTILES(change_vs_before, 2)[OFFSET(1)] AS median_change
FROM host_results
GROUP BY Season;

--Controling if this change is near the change year by year for normal countries that are not host.

WITH sport_medals AS (
  SELECT
    Season, Year, NOC, Sport,
    COUNT(DISTINCT IF(Medal != 'No Medal', CONCAT(Event, '|', Medal), NULL)) AS medals
  FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
  WHERE Year != 1906 AND Sport != 'Art Competitions'
  GROUP BY Season, Year, NOC, Sport
),
country_year AS (
  SELECT Season, Year, NOC, SUM(medals) AS total_medals
  FROM sport_medals
  GROUP BY Season, Year, NOC
),
with_neighbors AS (
  SELECT
    *,
    LAG(total_medals) OVER (PARTITION BY Season, NOC ORDER BY Year) AS medals_before
  FROM country_year
),
changes AS (
  SELECT
    n.Season,
    h.host_noc IS NOT NULL AS is_host,
    n.total_medals - n.medals_before AS change_vs_before
  FROM with_neighbors AS n
  LEFT JOIN `olympic-games-data-analysis.olympicsAnalysis.host_countries` AS h
    ON n.Season = h.Season AND n.Year = h.Year AND n.NOC = h.host_noc
  WHERE n.medals_before >= 10
)

SELECT
  Season,
  IF(is_host, 'Host country', 'Other countries') AS group_name,
  COUNT(*) AS cases,
  APPROX_QUANTILES(change_vs_before, 2)[OFFSET(1)] AS median_change,
  ROUND(AVG(change_vs_before), 1) AS avg_change,
  ROUND(COUNTIF(change_vs_before > 0) / COUNT(*) * 100, 1) AS pct_improved
FROM changes
GROUP BY Season, group_name
ORDER BY Season, group_name;

/*To check whether the host gain is just normal variation, I compared hosts with all other countries that had at least 10 medals in the previous edition. At the Summer Games, hosts gained a median of 14 medals, while other countries lost 2, and 90.9% of hosts improved compared with 37.9% of other countries. The Winter Games show the same pattern (median +6 for hosts and -2 for others), but with only 7 host cases the result is less reliable. Countries with high earlier totals tend to drop in the next edition, which makes the gap slightly larger, but the difference is too big to be explained only by this. The data does not show why hosts win more medals.*/
