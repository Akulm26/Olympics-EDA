
-- ######### CREATE DATABASE ##############

-- create database Olympics;

-- ############ LOAD DATA ###############
-- ###load csv data (local file)
-- LOAD DATA LOCAL INFILE "/Users/akulsuhailmalhotra/Desktop/SQL Databases/Olympics /athlete_events.csv"
-- INTO TABLE athlete_events
-- COLUMNS TERMINATED BY ','
-- OPTIONALLY ENCLOSED BY '"'
-- ESCAPED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES;

-- ###check data
-- select * from Olympics.athlete_events

-- ################ DATA CLEANING (0 TO NULL) ####################

-- ###adding new columns for player height, weight and age. 
-- alter table Olympics.athlete_events 
-- add height_corrected INT,
-- add weight_corrected INT, 
-- add age_corrected INT;

-- ###update the table with new columns
-- SET SQL_SAFE_UPDATES = 0

-- UPDATE Olympics.athlete_events set height_corrected = nullif(height, 0), 
-- weight_corrected = nullif(weight, 0),
-- age_corrected = nullif(age, 0);

-- SET SQL_SAFE_UPDATES = 1

-- ###drop old columns 
-- alter TABLE athlete_events drop column Age;
-- alter table athlete_events drop column Height, drop column Weight;

-- ###check data
-- select * from athlete_events

-- ###rename columns 
-- ALTER TABLE athlete_events rename column height_corrected to Height, 
-- rename column weight_corrected to Weight, 
-- rename column age_corrected to Age;

-- ###check data
-- select * from athlete_events

-- ###changing column positions
-- ALTER TABLE athlete_events MODIFY COLUMN Height INT AFTER Sex;
-- ALTER TABLE athlete_events MODIFY COLUMN Weight INT AFTER Height;
-- ALTER TABLE athlete_events MODIFY COLUMN Age INT after Sex;


SELECT * FROM athlete_events; 



-- select * from athlete_events where Age IS NULL


-- ################## EDA #####################
-- ###order by year
-- select * from athlete_events order by Year;

-- #################### Let us check the other table - called noc_regions ##################
SELECT * FROM noc_regions; -- the table contains 3 letter NOC code, region i.e. country name and some notes. 
select* from noc_regions order by region;

-- ###DISTINCT YEAR
SELECT DISTINCT(Year) FROM athlete_events ORDER BY 1;

-- ###FIRST AND LATEST OLYMPIC EVENTS HELD IN WHICH YEAR?
SELECT MIN(Year) AS first_games, MAX(Year) as latest_games FROM athlete_events; -- 1896 and 2016 respectively

-- ###COUNT DISTINCT YEAR (this will tell the number of olympic events by year till 2016)
select count(distinct(year)) from athlete_events; -- there have been a total of 35 Olympic events starting from 1896 till 2016

-- HOW MANY OLYMPIC GAMES HAVE BEEN HELD?
SELECT COUNT(DISTINCT(Games)) FROM athlete_events; -- A total of 51 games have been held so far (including summer and winter games)

-- LIST DOWN ALL OLYMPIC GAMES HELD SO FAR
select distinct Year , Season,  City from athlete_events order by Year asc; 
-- using distinct on all the columns to make sure it produces all combinations of year, season and city to check all olympic games held so far

-- CHECK NO. OF PLAYERS PARTICIPATED IN OLYMPICS TILL DATE:
SELECT COUNT(DISTINCT(name)) FROM athlete_events;

-- CHECK NO. OF PLAYERS WHO WON A MEDAL:
SELECT COUNT(DISTINCT(name)) FROM athlete_events
WHERE medal LIKE 'G%' OR MEDAL LIKE 'S%' OR MEDAL LIKE 'B%';

-- CHECK AVERAGE AGE OF MALE AND FEMALE ATHELTES WHO WON A MEDAL:
SELECT Sex, AVG(Age) AS avg_age
FROM athlete_events WHERE
medal LIKE 'G%' OR MEDAL LIKE 'S%' OR MEDAL LIKE 'B%'
GROUP BY sex;

-- CHECK TOP 5 SPORTS IN WHICH FEMALES HAVE WON THE MOST MEDALS:
SELECT sport, COUNT(medal) AS medal_count 
FROM athlete_events
WHERE sex = 'F'
GROUP BY sport
ORDER BY medal_count DESC
LIMIT 5;

-- CHECK TOP 5 SPORTS IN WHICH MALES HAVE WON THE MOST MEDALS:
SELECT sport, COUNT(medal) AS medal_count 
FROM athlete_events
WHERE sex = 'M'
GROUP BY sport
ORDER BY medal_count DESC
LIMIT 5;

-- MENTION THE TOTAL NUMBER OF NATIONS WHO PARTICIPATED IN EACH OLYMPIC GAMES
SELECT Games, COUNT(DISTINCT(NOC)) AS distinct_noc_count FROM athlete_events GROUP BY 1 ORDER BY 1 ASC;

-- WHICH YEAR SAW THE HIGHEST AND LOWEST NUMBER OF PARTICIPATING COUNTRIES IN OLYMPIC GAMES?

-- lowest # of participating countries
select Games, count(distinct(NOC)) as distinct_noc_count from athlete_events group by 1 order by 1 limit 1;
-- highest # of participating countries
select Games, count(distinct(NOC)) as distinct_noc_count from athlete_events group by 1 order by 1 desc limit 1; 

-- WHICH NATION HAS PARTICIPATED IN ALL OF THE OLYMPIC GAMES?
select Team, NOC, count(distinct(Games)) from athlete_events group by 1, 2 having count(distinct(Games)) = 51;

-- IDENTIFY THE SPORT WHICH WAS PLAYED IN ALL SUMMER OLYMPICS
select count(distinct(Games)) from athlete_events where Season = 'Summer'; -- total of 29 summer olympics
select Sport, count(distinct(Games)) from athlete_events where Season = 'Summer' group by 1 having count(distinct(Games)) = 29;

-- WHICH SPORT WAS JUST PLAYED ONLY ONCE IN THE OLYMPICS
SELECT sub.Sport, COUNT(sub.Sport) from 
(SELECT DISTINCT(Sport), Year FROM athlete_events) sub
GROUP BY sub.Sport HAVING COUNT(sub.Sport) = 1;

-- FIND DETAILS OF OLDEST ATHLETES TO WIN A GOLD MEDAL;
SELECT * FROM athlete_events WHERE Medal LIKE 'G%' ORDER BY Age DESC LIMIT 2;

-- FIND TOTAL NUMBER OF SPORTS PLAYED IN EACH OLYMPIC GAMES
SELECT DISTINCT(Games), COUNT(DISTINCT(Sport)) as no_of_sports FROM athlete_events GROUP BY 1 ORDER BY 2 DESC;

-- FIND THE TOP 5 ATHLETES WHO HAVE WON THE MOST GOLD MEDALS
SELECT distinct(sub.Name), count(sub.Medal) AS max_gold_medals from 
(select Name, Medal from athlete_events where medal like 'G%')sub group by 1 order by 2 desc limit 5;

-- FETCH THE TOP 5 ATHLETES WHO HAVE WON THE MAX NO. OF MEDALS
select distinct(sub.Name), count(sub.Medal) AS max_no_of_medals from 
(select Name, Medal from athlete_events)sub group by 1 order by 2 desc limit 5;

-- FETCH THE TOP 5 MOST SUCCESSFUL COUNTRIES IN OLYMPICS. SUCCESS IS DEFINED BY NUMBER OF MEDALS WON
select region, sum(case when medal like 'G%' or medal like 'S%' or medal like 'B%' then 1 else 0
end) as no_of_medals from athlete_events as o join noc_regions as r on o.NOC = r.NOC
group by region order by no_of_medals desc limit 5;

-- IDENTIFY WHICH COUNTRY WON THE MOST GOLD/SILVER AND BRONZE MEDAL IN EACH OLYMPIC GAME

with temp(Games, region, total_gold, total_silver, total_bronze) as
(select Games, region, 
sum(case when Medal like 'G%' then 1 else 0 end) as total_gold, 
sum(case when Medal like 'S%' then 1 else 0 end) as total_silver, 
sum(case when Medal like 'B%' then 1 else 0 end) as total_bronze 
from athlete_events a
join noc_regions as n on a.NOC = n.NOC
group by 1, 2)

select distinct Games, 
concat(first_value(region) over (partition by Games order by total_gold desc),
 ' - ', first_value(total_gold) over (partition by Games order by total_gold desc)) as max_gold, 
 concat(first_value(region) over (partition by Games order by total_silver desc),
 ' - ', first_value(total_silver) over (partition by Games order by total_silver desc)) as max_silver,
  concat(first_value(region) over (partition by Games order by total_bronze desc),
 ' - ', first_value(total_bronze) over (partition by Games order by total_bronze desc)) as max_silver 
 from temp order by Games;
 
 -- ###### FIRST_VALUE() tutorial can be found here: https://www.sqlservertutorial.net/sql-server-window-functions/sql-server-first_value-function/
 
-- FIND THE RATIO OF MALE TO FEMALE ATHLETES WHO PARTICIPATED IN ALL OLYMPIC GAMES

select concat(sub.total_males, ' / ', sub.total_females) as calculation, 
sub.total_males/sub.total_females as males_over_females_ratio from
(select count(distinct games) as count_games, 
sum(case when Sex = 'M' then 1 else 0 end) as total_males, 
sum(case when Sex = 'F' then 1 else 0 end) as total_females from athlete_events) sub;
-- this means there are almost 3 males for every female who participated in all olympic games held until 2016

-- IN WHICH SPORT UNITED STATES WON THE HIGHEST NUMBER OF MEDALS?
select sub.Sport, count(sub.Medal) as total_medals_USA from
(select Team, Sport, Medal from athlete_events 
where Team = 'United States' and (Medal like 'G%' or Medal like 'S%' or Medal like 'B%')) sub
group by Sport order by total_medals_USA desc limit 1 ;

-- WHAT IS THE CONTRIBUTION OF US MALE AND FEMALE ATHLETES IN ACHIEVING THE HIGHEST MEDALS IN ATHLETICS?
select Sex, count(medal) as medal_count from athlete_events where 
Team = 'United States' and Sport = 'Athletics' 
and (Medal like 'G%' or Medal like 'S%' or Medal like 'B%') group by 1;
