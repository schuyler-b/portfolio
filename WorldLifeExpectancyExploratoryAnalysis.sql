SELECT *
FROM world_life_expectancy
;
#let's look at the lowest and highest life expectancy of each country within this 15-year period
SELECT Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`)
FROM world_life_expectancy
GROUP BY Country
ORDER BY Country DESC
;
#there are some countries that have 0 in both min and max, so let's filter those out

SELECT Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`)
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
;
#which countries have made the biggest improvement from their lowest to their highest point? The lowest?
SELECT Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years ASC
;

#Countries like Haiti, Zimbabwe, Eritrea, and Uganda have made the biggest improvement. 
#Countries like Guyana, Seychelles, Kuwait, and Philippines have made minimal improvement.

#What is the average life expectancy for each year?
#let's make sure to filter out those zeros as they could be lowering our averages

SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
AND `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year
;

#world life expectancy has improved about 5 years over a 15-year period

SELECT *
FROM world_life_expectancy
;

#does GDP lead to higher life expectancy?
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP ASC
;
#there were a few rows that had zeros in both life expectancy and GDP, so I filtered those out
#Keep in mind the average life expectancy over this period of time is about 68. These countries with low GDP have very low life expectancy
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP DESC
;
#These countries have high GDP and high life expectancy
#this would be good data to integrate with a data visualization tool to see the correlation better
#We can use a case statement to put high and low GDP countries in two groups and see the average life expectancy
SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life Expectancy` ELSE NULL END) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN `Life Expectancy` ELSE NULL END) Low_GDP_Life_Expectancy
FROM world_life_expectancy
;
#We can see we have 1326 high GDP countries which average a 74-year life expectancy and 1612 low GDP countries which average a 65-year life expectancy.

#let's look at life expectancy based on status
SELECT Status, ROUND(AVG(`Life Expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;
#this shows two status types and an average of each, but I would like to know how many developing and developed countries there are

SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life Expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;
#This shows we only have 32 developed countries and many more developing countries, which is skewing the results in favor for the developed countries if there are high averages.
SELECT *
FROM world_life_expectancy
;

SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND BMI > 0
ORDER BY BMI DESC
;
#some of these BMI results are wildly high. This is a bit strange because even though these countries having high BMI, they also have high life expectancy overall.

SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND BMI > 0
ORDER BY BMI ASC
;
#These countries with low BMI on average have low life expectancy.

#now let's look at adult mortality. How many people are dying each ear in a country and is that a lot for that country?
#to do this, let's do a rolling total. We need to use sum and a window function to accomplish this.

SELECT Country,
Year,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
;
#We can see the rolling totals fo adult mortality for each country now