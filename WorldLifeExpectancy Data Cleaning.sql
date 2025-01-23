SELECT *
FROM world_life_expectancy.world_life_expectancy
;

#let's take a look at the data

SELECT *
FROM world_life_expectancy
;

#let's look for duplicates
SELECT Country, Year, CONCAT(Country, Year)
FROM world_life_expectancy
;

SELECT Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1
;
#we have 3 duplicates
#now let's remove them
#let's use a row number partitioned on our concat to pull out our duplicates and row_id so we can use our row_id to delete the duplicate rows
SELECT *
FROM (
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
	FROM world_life_expectancy
    ) AS Row_table
WHERE Row_Num > 1
;

DELETE FROM world_life_expectancy
WHERE
	Row_ID IN (
	SELECT Row_ID
	FROM (
		SELECT Row_ID, 
		CONCAT(Country, Year),
		ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
		FROM world_life_expectancy
		) AS Row_table
	WHERE Row_Num > 1)
;
#now all of our duplicates are gone

#now let's see what our data quality looks like in our status column
SELECT *
FROM world_life_expectancy
WHERE Status = ''
;
#to correct this, we should be able to take the status from a different year for a country and fill the blank with the correct status

SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> ''
;

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;

#now that we have this list of countries that are developing, we can use this list to populate the blanks

UPDATE world_life_expectancy
SET Status = 'Developing'
WHERE Country IN (SELECT DISTINCT(Country)
				FROM world_life_expectancy
				WHERE Status = 'Developing')
                ;
#this unfortunately didn't work as SQL won't let me specify the target table 'world_life_expectancy' for update in the FROM clause
#so I need a work around
#let me try to join the table to itself in an update statement and then update the status this way

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;
#by using the join, I can join the same table and use one version (t2) to filter another version (t1) to fill the blanks
#so I began by specifying to set t1.status to developing where it is blank in t1 but not in t2 where the country is still the same
#for example, Argentina is equal to Argentina. if status is blank for Argentina in t1 but status is not blank for Argentina in t2, and status is developing in t2, then we can set the blank status to developing in t1


SELECT *
FROM world_life_expectancy
WHERE Country = 'United States of America'
;
#now let's do the same thing for developed countries

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;
#tada
#let's see if there are any nulls
SELECT *
FROM world_life_expectancy
WHERE Status IS NULL
;
#we're good

SELECT *
FROM world_life_expectancy
;

SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;
#we have two

SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

#let's take the average of the two years before and after the blank
#also, it's only 2 values, so it's not going to ruin the data

SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
t2.Country, t2.Year, t2.`Life expectancy`
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
#now we have the year after

SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
t2.Country, t2.Year, t2.`Life expectancy`, 
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

#now we have the life expectancy of the year before and after within the same table
#let's set the blank to be the average of the year before and after


UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''
;




