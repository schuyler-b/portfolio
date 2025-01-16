
SELECT * FROM us_project.us_household_income;

SELECT * FROM us_project.us_household_income_statistics;

SELECT State_Name, County, City, ALand, AWater
FROM us_project.us_household_income
;

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10
;


SELECT u.State_Name, County, Type, `Primary`, Mean, Median
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
;


SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
    GROUP BY u.State_Name
    ORDER BY 3
;

SELECT Type, COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    WHERE Mean <> 0
    GROUP BY Type
    HAVING COUNT(Type) > 100
    ORDER BY 4 DESC
;



SELECT *
FROM us_household_income
WHERE Type = 'Community';

SELECT u.State_Name, City, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	on u.id = us.id
    GROUP BY u.State_Name, City
    ORDER BY ROUND(AVG(Mean),1) DESC
;