CREATE OR REPLACE TABLE `olympic-games-data-analysis.olympicsAnalysis.host_countries` AS
SELECT * FROM UNNEST(ARRAY<STRUCT<Year INT64, Season STRING, host_noc STRING>>[
  (1896,'Summer','GRE'), (1900,'Summer','FRA'), (1904,'Summer','USA'),
  (1906,'Summer','GRE'), (1908,'Summer','GBR'), (1912,'Summer','SWE'),
  (1920,'Summer','BEL'), (1924,'Summer','FRA'), (1928,'Summer','NED'),
  (1932,'Summer','USA'), (1936,'Summer','GER'), (1948,'Summer','GBR'),
  (1952,'Summer','FIN'), (1956,'Summer','AUS'), (1960,'Summer','ITA'),
  (1964,'Summer','JPN'), (1968,'Summer','MEX'), (1972,'Summer','FRG'),
  (1976,'Summer','CAN'), (1980,'Summer','URS'), (1984,'Summer','USA'),
  (1988,'Summer','KOR'), (1992,'Summer','ESP'), (1996,'Summer','USA'),
  (2000,'Summer','AUS'), (2004,'Summer','GRE'), (2008,'Summer','CHN'),
  (2012,'Summer','GBR'), (2016,'Summer','BRA'),
  (1924,'Winter','FRA'), (1928,'Winter','SUI'), (1932,'Winter','USA'),
  (1936,'Winter','GER'), (1948,'Winter','SUI'), (1952,'Winter','NOR'),
  (1956,'Winter','ITA'), (1960,'Winter','USA'), (1964,'Winter','AUT'),
  (1968,'Winter','FRA'), (1972,'Winter','JPN'), (1976,'Winter','AUT'),
  (1980,'Winter','USA'), (1984,'Winter','YUG'), (1988,'Winter','CAN'),
  (1992,'Winter','FRA'), (1994,'Winter','NOR'), (1998,'Winter','JPN'),
  (2002,'Winter','USA'), (2006,'Winter','ITA'), (2010,'Winter','CAN'),
  (2014,'Winter','RUS')
]);

SELECT
Season,COUNT(*) AS number_of_games
FROM `olympic-games-data-analysis.olympicsAnalysis.host_countries`
GROUP BY Season