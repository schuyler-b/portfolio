#Let's start with our cleaned data
SELECT * FROM us_project.us_household_income;

SELECT * FROM us_project.us_household_income_statistics;

#I'm interested in taking a deeper look into the specific geography of each state, 
#specifically in reference to the area of land and water and how that compares between states.
#How might these geographic characteristics affect household income within each state?
SELECT State_Name, County, City, ALand, AWater
FROM us_project.us_household_income
;
#The area of land and water is broken down by city, but I want to look at the state level, so I need to do some aggregation
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_project.us_household_income
GROUP BY State_Name
;
#This can be further sorted by state with the most water...
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10
;
#... or state with the most land
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10
;

#I'm going to go ahead and join this data on id of us_project.us_household_income and id of us_project.us_household_income_statistics
SELECT *
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
	on u.id = us.id
;

#I noticed that all the statistics data came in but not all of the income data made it into SQL from Excel
SELECT COUNT(id)
FROM us_project.us_household_income
;

SELECT COUNT(id)
FROM us_project.us_household_income_statistics
;
#let's take a deeper look here

SELECT *
FROM us_project.us_household_income u
RIGHT JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE u.id IS NULL
;
#I did a RIGHT JOIN to return all the rows from the right table (statistics)
#I filtered using WHERE u.id IS NULL to show which rows were included in the statistics table but not in the income table
#Depending on the data and the data source (customer, client, internal data), this data might be used or ignored. I chose to ignore this data by doing an inner join

SELECT *
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
;
#I noticed some missing data with income data, so I need to filter that out. I used WHERE Mean <> 0 to do this.
SELECT *
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
;
#let's look a bit deeper
SELECT u.State_Name, County, Type, `Primary`, Mean, Median
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
;
#next, let's look specifically at states
SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
    GROUP BY u.State_Name
;
#I want to look at lowest avg household income
SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
    GROUP BY u.State_Name
    ORDER BY 2
    LIMIT 5
;
#what about highest income?
SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
    GROUP BY u.State_Name
    ORDER BY 2 DESC
    LIMIT 5
;
#what about lowest median income?
SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
    GROUP BY u.State_Name
    ORDER BY 3
    LIMIT 5
;
#what about highest median income?
SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
    GROUP BY u.State_Name
    ORDER BY 3 DESC
    LIMIT 5
;

SELECT Type, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
    GROUP BY Type
    ORDER BY 2 DESC
    LIMIT 10
;
#let's look at the count of each type
SELECT Type, COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
    GROUP BY Type
    ORDER BY 3 DESC
    LIMIT 20
;
#it's hard to trust the municipality data due to very low count
#also, CPD and city might be the same because their averages are so similar 
#now lets order by median income

SELECT Type, COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
    GROUP BY Type
    ORDER BY 4 DESC
    LIMIT 20
;
#community is super low. What states are those in?

SELECT * 
FROM us_household_income
WHERE Type = 'community'
;
#it's Peurto Rico

#to give our data better validity, let's filter out the types with low counts
SELECT Type, COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
    GROUP BY Type
    HAVING COUNT(Type) > 100
    ORDER BY 4 DESC
;
#what are highest salaries like at the city level?


SELECT u.State_Name, City, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    GROUP BY u.State_Name, City
    ORDER BY ROUND(AVG(Mean),1) DESC
;
#it appears income caps out at 300000