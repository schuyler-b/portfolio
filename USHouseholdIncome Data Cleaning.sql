#let's take a look at our raw data

SELECT * FROM us_project.us_household_income;

SELECT * FROM us_project.us_household_income_statistics;
#I need to update the auto generated id title to one that is more functional and more easily typed

ALTER TABLE us_project.us_household_income_statistics
RENAME COLUMN ï»¿id TO `id`;
#let's see if all the data made it in from excel
SELECT COUNT(id)
FROM us_project.us_household_income
;

SELECT COUNT(id)
FROM us_project.us_household_income_statistics
;
#missing about 230 rows from income table. we can deal with this later
#let's scan through the data and see if there are any issues
SELECT * FROM us_project.us_household_income;

SELECT * FROM us_project.us_household_income_statistics;
#I noticed some inconsistencies with captilization of the state name
#There are a few instances of no data in the statistics column, which could be a data transfer or quality issue
#it could also just be that the specific city just didn't report their data
#either way, I want to remove these so my aggregates are not affected

#let's make sure we don't have any duplicates

SELECT id, COUNT(id)
FROM us_project.us_household_income
GROUP BY id
HAVING COUNT(id) > 1;

#we have several duplicates, so let's get rid of those
#I have to use a subquery to isolate and filter on these duplicates
#note to self...subquieries have to be renamed (duplicates in this instance)
DELETE FROM us_household_income
WHERE row_id IN (
	SELECT row_id
	FROM (
		SELECT row_id,
		id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
		FROM us_project.us_household_income) duplicates
	WHERE row_num > 1)
;
#did it work?
SELECT id, COUNT(id)
FROM us_project.us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1
;
#good. no duplicates
#let's look at those misspelled state names
SELECT DISTINCT State_Name
FROM us_project.us_household_income
GROUP BY 1
;
#I want to standardize everything, so let's start with Georgia
UPDATE us_project.us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia'
;
#and fix Alabama
UPDATE us_project.us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama'
;
#now I want to check state abbreviation
SELECT DISTINCT State_ab
FROM us_project.us_household_income
GROUP BY 1
;
#all good
#I noticed in the data there was a row where place is blank
SELECT *
FROM us_project.us_household_income
WHERE County = 'Autauga County'
ORDER BY 1
;
#I think it is just an error so we can populate the blank place with Autaugaville
UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont'
;
#fixed
#now let's sort on type
SELECT Type, COUNT(Type)
FROM us_project.us_household_income
GROUP BY Type
#ORDER BY
;

#boroughs and borough should be the same. Let's fix that
UPDATE us_project.us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs'
;
#I'm not sure CPD and CDP are the same, so with better domain knowledge, I am going to leave it
#let's look at some of the area measurements
SELECT ALand, AWater
FROM us_project.us_household_income
WHERE AWater IN(0, '', NULL)
;
#let's do a distinct count
SELECT DISTINCT(AWater)
FROM us_project.us_household_income
WHERE AWater IN(0, '', NULL)
;
#it's only 0's instead of also having null and blanks which is good
#let's go a step deeper to look at data quality
SELECT ALand, AWater
FROM us_project.us_household_income
WHERE AWater IN(0, '', NULL)
AND ALand IN(0, '', NULL)
;

SELECT ALand, AWater
FROM us_project.us_household_income
WHERE (ALand = 0 or ALand IS NULL OR ALand = '')
;

#this shows there are some counties with just water but no land