SELECT 
COUNT(*) AS total_row
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events`
;

SELECT
COUNT(DISTINCT ID) AS distinct_row,
COUNT(Name) AS total_row_column_Name,
COUNT(Sex) AS total_row_column_Sex,
COUNT(Age) AS total_row_column_Age,
COUNT(Height) AS total_row_column_Height,
COUNT(Weight) AS total_row_column_Weight,
COUNT(Team) AS total_row_column_Team,
COUNT(NOC) AS total_row_column_NOC,
COUNT(Games) AS total_row_column_Games,
COUNT(Year) AS total_row_column_Year,
COUNT(Season) AS total_row_column_Season,
COUNT(City) AS total_row_column_City,
COUNT(Sport) AS total_row_column_Sport,
COUNT(City) AS total_row_column_City,
COUNT(Event) AS total_row_column_Event,
COUNT(Medal) AS total_row_column_Event
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events`;

--AS WE CAN SEE THE TOTAL ROW FOR EACH COLUMN IS 271116 BECOUSE WE IMPORTED DATA FORM CSV AND NULL VALUES ARE GENERATED AS STRING (NA)

--Controlling dublicated row
SELECT ID, Games, Event, COUNT(*) AS cnt
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events`
GROUP BY ID, Games, Event
HAVING cnt > 1;

--AS WE CAN SEE THERE ARE TOO MANY DUBLICATED ROW FOR THIS TABLE .
--LETS HANDL MISSING VALUES BECOUSE Bigquery has read as string NA.

SELECT
  COUNTIF(Age = 'NA') AS missing_age,
  COUNTIF(Height = 'NA') AS missing_height,
  COUNTIF(Weight = 'NA') AS missing_weight,
  COUNTIF(Medal = 'NA') AS no_medal
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events`;

--Creating cleaned View

CREATE OR REPLACE VIEW `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned` AS
SELECT DISTINCT
  * EXCEPT(Age, Height, Weight, Medal),
  SAFE_CAST(NULLIF(Age, 'NA') AS INT64) AS Age,
  SAFE_CAST(NULLIF(Height, 'NA') AS FLOAT64) AS Height,
  SAFE_CAST(NULLIF(Weight, 'NA') AS FLOAT64) AS Weight,
  COALESCE(NULLIF(Medal, 'NA'), 'No Medal') AS Medal
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events`;


SELECT
COUNT(*) AS cnt_row
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`;


SELECT
  COUNTIF(Age IS NULL) AS missing_age,
  ROUND(((COUNTIF(Age IS NULL) )/(COUNT(*)) *100),0) as percentage_of_misingvalue,
  COUNTIF(Height IS NULL) AS missing_height,
  ROUND(((COUNTIF(Height IS NULL) )/(COUNT(*)) *100),0) as percentage_of_mising_height_value,
  COUNTIF(Weight IS NULL) AS missing_weight,
  ROUND(((COUNTIF(Weight IS NULL) )/(COUNT(*)) *100),0) as percentage_of_mising_Weight_value,
  COUNTIF(Medal IS NULL) AS no_medal,
  ROUND(((COUNTIF(Medal IS NULL) )/(COUNT(*))*100),0) as percentage_of_mising_Medal_value
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`;

--Checking numbers for NO Medal

SELECT
COUNTIF(Medal ='No Medal') AS athlets_without_medal,
ROUND(((COUNTIF(Medal ='No Medal') )/(COUNT(*))*100),0) as percentage_of_mising_Medal_value
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`;
--Lets see wich country has win most medal.
--(Fixed: the filter was Medal='No Medal', which counts participations WITHOUT a medal. It is now Medal != 'No Medal'.)

SELECT
    n.region AS country,
    COUNTIF(Medal != 'No Medal') AS cnt_of_medals
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned` AS ath JOIN `olympic-games-data-analysis.olympicsAnalysis.noc_regions` AS n
    ON ath.NOC=n.NOC
GROUP BY n.region 
ORDER BY cnt_of_medals DESC
LIMIT 10;

--Highest and Lowest participant 
WITH participants_per_year AS (
  SELECT
    Year,
    Season,
    COUNT(DISTINCT ID) AS nr_of_participants
  FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
  GROUP BY Year, Season
)

(SELECT 'Highest' AS type, Year, Season, nr_of_participants
 FROM participants_per_year
 ORDER BY nr_of_participants DESC
 LIMIT 1)
UNION ALL
(SELECT 'Lowest' AS type, Year, Season, nr_of_participants
 FROM participants_per_year
 ORDER BY nr_of_participants ASC
 LIMIT 1);

--Most decorated Athlet 
WITH decorated_athlet AS (
SELECT *
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned`
WHERE Medal !="No Medal")
,most_decorated_athlets AS (
  SELECT
  Name,
  COUNT(Medal) AS nr_of_medals
  FROM decorated_athlet
  GROUP BY Name
  ORDER BY nr_of_medals DESC
  LIMIT 1
)

SELECT 
  d.Name,d.Year,d.Season,
  COUNTIF(d.Medal='Gold') AS gold_medals,
  COUNTIF(d.Medal='Silver') AS Silver_medals,
  COUNTIF(d.Medal='Bronze') AS Bronze_medals,
  COUNT(Medal) AS total
FROM decorated_athlet AS d JOIN most_decorated_athlets AS md ON d.Name=md.Name
GROUP BY d.Name,d.Year,d.Season
ORDER BY d.Name,d.Year,d.Season ;
