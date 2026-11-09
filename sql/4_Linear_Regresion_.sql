--4.Linear Regresion 

WITH per_edition AS (
  SELECT
    Season,
    Year,
    COUNT(DISTINCT ID) AS athletes,
    COUNT(DISTINCT Event) AS events
  FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
  WHERE Year >= 1960
  GROUP BY Season, Year
)

SELECT
  Season,
  COUNT(*) AS editions,
  ROUND(CORR(events, athletes), 2) AS r,
  ROUND(POW(CORR(events, athletes), 2), 2) AS r_squared,
  ROUND(COVAR_POP(events, athletes) / VAR_POP(events), 1) AS slope,
  ROUND(AVG(athletes) - COVAR_POP(events, athletes) / VAR_POP(events) * AVG(events), 0) AS intercept
FROM per_edition
GROUP BY Season;