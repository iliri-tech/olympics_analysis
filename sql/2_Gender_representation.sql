--##	Gender representation 
--Participation for each gender during the years:

WITH growth_in_events AS (
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
ORDER BY Season, Sex, Year;

--How has the ratio of male to female athletes changed over time?

SELECT 
    Season ,
    Year,
    ROUND(SAFE_DIVIDE(COUNTIF(Sex='F'),COUNTIF(Sex='M')),2) AS ratio
    FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
    GROUP BY Season,Year
    ORDER BY Season,Year;



