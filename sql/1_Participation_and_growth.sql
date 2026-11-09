--•	Participation and growth
--How has the number of participating athletes changed over the 120 years?
With nr_of_participant AS (
SELECT
  Year,
  Season,
  COUNT(DISTINCT Id) AS number_of_participant

FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
GROUP BY Year,Season
 
)
SELECT
*
FROM nr_of_participant;

--Which Games had the highest and lowest participation, and why (e.g., boycotts, wars)?
With nr_of_participants AS (
SELECT
  Year,
  Season,
  COUNT(DISTINCT ID) AS number_of_participants

FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
GROUP BY Year,Season
)

SELECT 
    Season,
    Year,
    number_of_participants AS participation,
    IF(
    RANK() OVER (PARTITION BY Season ORDER BY number_of_participants DESC) = 1,
    'Highest', 'Lowest'
    ) AS type
FROM nr_of_participants
QUALIFY 
    RANK() OVER (PARTITION BY Season ORDER BY number_of_participants DESC) = 1
OR  
    RANK() OVER (PARTITION BY Season ORDER BY number_of_participants ASC) = 1
ORDER BY Season;


--How has the number of sports and events expanded over time?

SELECT
    Season,
    Year,
    Sex,
  COUNT(DISTINCT Sport) AS number_of_sports,
  COUNT(DISTINCT Event) AS number_of_events
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
GROUP BY Season,Year,Sex
ORDER BY Season,Year,Sex;

--Year by year growth in events
/*WITH growth_in_events AS (
SELECT
    Season,
    Year,
    Sex,
  COUNT(DISTINCT Event) AS number_of_events
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
GROUP BY Season,Year,Sex
ORDER BY Season,Year,Sex)
 SELECT
    Season,
    Year,
    Sex,
    number_of_events ,
    LAG(number_of_events) OVER w AS previous_nr_of_events,
    number_of_events - LAG(number_of_events) OVER w AS change,
    ROUND(
      SAFE_DIVIDE( number_of_events - LAG(number_of_events) OVER w,
      LAG(number_of_events)OVER w)*100,1) AS prc_change FROM growth_in_events
WINDOW w AS (PARTITION BY Season, Sex ORDER BY Year)
ORDER BY Season, Sex, Year*/
WITH growth_in_events AS (
SELECT
    Season,
    Year,
    COUNT(DISTINCT Event) AS number_of_events
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
GROUP BY Season,Year
ORDER BY Season,Year)
 SELECT
    Season,
    Year,
    number_of_events ,
    LAG(number_of_events) OVER w AS previous_nr_of_events,
    number_of_events - LAG(number_of_events) OVER w AS change,
    ROUND(
      SAFE_DIVIDE( number_of_events - LAG(number_of_events) OVER w,
      LAG(number_of_events)OVER w)*100,1) AS prc_change FROM growth_in_events
WINDOW w AS (PARTITION BY Season ORDER BY Year)
ORDER BY Season, Year;

--Lets See the correlation between athlets and events 

WITH per_edition AS (
  SELECT
    Season,
    Year,
    COUNT(DISTINCT ID) AS athletes,
    COUNT(DISTINCT Event) AS events,
    COUNT(DISTINCT Sport) AS sports
  FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
  WHERE Year >= 1960
  GROUP BY Season, Year
)

SELECT
  Season,
  ROUND(CORR(athletes, events), 2) AS corr_athletes_events,
  ROUND(CORR(athletes, sports), 2) AS corr_athletes_sports
FROM per_edition
GROUP BY Season;


