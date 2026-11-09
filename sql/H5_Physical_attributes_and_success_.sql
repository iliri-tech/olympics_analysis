--•	H5: Physical attributes and success. Medalists in sports such as basketball and swimming are taller on average than non-medalists in the same sport.

WITH athletes AS (
  SELECT
    ID, Year, Sport, Sex,
    MAX(Height) AS height,
    MAX(Weight) AS weight,
    IF(COUNTIF(Medal != 'No Medal') > 0, 'Medalist', 'Non-medalist') AS status
  FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
  WHERE Sport IN ('Basketball', 'Swimming')
    AND Height IS NOT NULL
  GROUP BY ID, Year, Sport, Sex
)

SELECT
  Sport, Sex, status,
  COUNT(*) AS athletes,
  ROUND(AVG(height), 1) AS avg_height_cm,
  APPROX_QUANTILES(height, 2)[OFFSET(1)] AS median_height_cm
FROM athletes
GROUP BY Sport, Sex, status
ORDER BY Sport, Sex, status;

-- How to read: if the medalists' avg_height_cm is higher than the non-medalists' within the same sport and sex, the height part of H5 is supported. Also check 'athletes': a group with very few athletes gives an unreliable average.

-- Query 2: height and BMI differences in all sports

WITH athletes AS (
  SELECT
    ID, Year, Sport, Sex,
    MAX(Height) AS height,
    SAFE_DIVIDE(MAX(Weight), POW(MAX(Height) / 100, 2)) AS bmi,
    IF(COUNTIF(Medal != 'No Medal') > 0, 'Medalist', 'Non-medalist') AS status
  FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
  WHERE Height IS NOT NULL AND Weight IS NOT NULL
    AND Sport != 'Art Competitions'
  GROUP BY ID, Year, Sport, Sex
)

SELECT
  Sport, Sex,
  COUNTIF(status = 'Medalist') AS medalists,
  COUNTIF(status = 'Non-medalist') AS non_medalists,
  ROUND(AVG(IF(status = 'Medalist', height, NULL)) - AVG(IF(status = 'Non-medalist', height, NULL)), 1) AS height_diff_cm,
  ROUND(AVG(IF(status = 'Medalist', bmi, NULL)) - AVG(IF(status = 'Non-medalist', bmi, NULL)), 2) AS bmi_diff
FROM athletes
GROUP BY Sport, Sex
HAVING medalists >= 50 AND non_medalists >= 50
ORDER BY height_diff_cm DESC;


-- Significance and period check

-- Splits by period (before and after 1980) and computes the Welch t-statistic. An absolute value above 2 suggests a difference that chance does not explain.

WITH athletes AS (
  SELECT
    ID, Year, Sport, Sex,
    MAX(Height) AS height,
    IF(COUNTIF(Medal != 'No Medal') > 0, 'Medalist', 'Non-medalist') AS status
  FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
  WHERE Sport IN ('Basketball', 'Swimming') AND Height IS NOT NULL
  GROUP BY ID, Year, Sport, Sex
),
stats AS (
  SELECT
    Sport, Sex,
    IF(Year >= 1980, '1980 and later', 'Before 1980') AS period,
    status,
    COUNT(*) AS n,
    AVG(height) AS avg_h,
    VAR_SAMP(height) AS var_h
  FROM athletes
  GROUP BY Sport, Sex, period, status
)

SELECT
  m.Sport, m.Sex, m.period,
  m.n AS medalists, n.n AS non_medalists,
  ROUND(m.avg_h - n.avg_h, 1) AS height_diff_cm,
  ROUND((m.avg_h - n.avg_h) / SQRT(m.var_h / m.n + n.var_h / n.n), 1) AS t_stat
FROM stats AS m
JOIN stats AS n
  ON m.Sport = n.Sport AND m.Sex = n.Sex AND m.period = n.period
WHERE m.status = 'Medalist' AND n.status = 'Non-medalist'
  AND m.n >= 10 AND n.n >= 10
ORDER BY m.Sport, m.Sex, m.period;

/*H5 is partly supported. Medalists were taller than non-medalists in basketball and swimming, for both men and women. The differences were about 3 cm in swimming (men and women), 3.6 cm in men’s basketball, and only 0.8 cm in women’s basketball, which is practically negligible. Each athlete was counted once per Games and sport, and men and women were compared separately. Height is missing for about 22% of athletes, mostly in early Games, and team members are all counted as medalists, so the result describes athletes with data. The data does not show whether height causes success or whether stronger programs simply select taller athletes.*/