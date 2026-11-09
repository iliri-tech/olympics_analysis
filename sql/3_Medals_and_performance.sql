--## Medals and performance ##

--Which countries have won the most medals (total, gold, silver, bronze)?
SELECT 
  noc.Region AS Team,
  COUNTIF(ath.Medal='Gold') AS gold_medals,
  COUNTIF(ath.Medal='Silver') AS Silver_medals,
  COUNTIF(ath.Medal='Bronze') AS Bronze_medals,
  COUNTIF(ath.Medal!='No Medal') AS total
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned` AS ath JOIN `olympic-games-data-analysis.olympicsAnalysis.noc_regions` AS noc ON ath.NOC=noc.NOC
GROUP BY Team
ORDER BY total DESC
LIMIT 10;


--Which athletes are the most decorated in Olympic history?

SELECT 
    ath.Name,
    noc.region,
    ath.Sex,
    COUNTIF(ath.Medal='Gold') AS gold_medals,
    COUNTIF(ath.Medal='Silver') AS Silver_medals,
    COUNTIF(ath.Medal='Bronze') AS Bronze_medals,
    COUNTIF(ath.Medal!='No Medal') AS total
FROM `olympic-games-data-analysis.olympicsAnalysis.athlete_events_cleaned` AS ath JOIN `olympic-games-data-analysis.olympicsAnalysis.noc_regions` AS noc ON ath.NOC=noc.NOC
WHERE ath.Medal!='No Medal'
GROUP BY ath.Name,noc.region,ath.Sex
ORDER BY total DESC, gold_medals DESC, Silver_medals DESC, bronze_medals DESC
LIMIT 10;


