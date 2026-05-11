-- Connect to database (MySQL only)
USE hospital_db;

-- OBJECTIVE 1: ENCOUNTERS OVERVIEW

-- a. How many total encounters occurred each year?
SELECT 
    YEAR(START) AS Year, COUNT(DISTINCT id) AS Total_Encounters
FROM
    encounters
GROUP BY Year
ORDER BY Year;

-- b. For each year, what percentage of all encounters belonged to each encounter class
-- (ambulatory, outpatient, wellness, urgent care, emergency, and inpatient)?
SELECT 
    YEAR(START) AS Year,
    ENCOUNTERCLASS,
    COUNT(DISTINCT id) AS Total_Encounters,
    COUNT(DISTINCT id) / (SELECT 
            COUNT(*)
        FROM
            encounters
        WHERE
            YEAR(START) = Year) * 100 AS encounter_class_percent
FROM
    encounters
GROUP BY Year , ENCOUNTERCLASS
ORDER BY Year;

-- c. What percentage of encounters were over 24 hours versus under 24 hours?
with t_dur as (select CASE 
when timediff(STOP,START)>'24:00:00' then "Over 24 hours"
else "Under 24 hrs" end AS duration from encounters)
select duration , count(*)/(select count(*) from encounters)*100 as percent , count(*) AS ENCOUNTERS from t_dur group by duration
 ;

-- OBJECTIVE 2: COST & COVERAGE INSIGHTS

-- a. How many encounters had zero payer coverage, and what percentage of total encounters does this represent?
SELECT 
    ROUND(COUNT(DISTINCT id) / (SELECT 
                    COUNT(*)
                FROM
                    encounters) * 100,
            1) AS zero_payer_coverage_percentage
FROM
    encounters
WHERE
    PAYER_COVERAGE = 0;

-- b. What are the top 10 most frequent procedures performed and the average base cost for each?
SELECT 
    DESCRIPTION,
    COUNT(*) AS procedure_frequency,
    ROUND(AVG(BASE_COST), 1) AS average_base_cost
FROM
    procedures
GROUP BY DESCRIPTION
ORDER BY procedure_frequency DESC
LIMIT 10;

-- c. What are the top 10 procedures with the highest average base cost and the number of times they were performed?
SELECT 
    DESCRIPTION,
    ROUND(AVG(BASE_COST), 1) AS average_base_cost ,  COUNT(*) AS procedure_frequency
FROM
    procedures
GROUP BY DESCRIPTION
ORDER BY average_base_cost DESC
LIMIT 10;

-- d. What is the average total claim cost for encounters, broken down by payer?

SELECT 
    PAYER,
    ROUND(AVG(TOTAL_CLAIM_COST), 1) AS average_total_claim_cost
FROM
    encounters
GROUP BY PAYER;

-- OBJECTIVE 3: PATIENT BEHAVIOR ANALYSIS

-- a. How many unique patients were admitted each quarter over time?
SELECT 
    YEAR(START) as Year,
    QUARTER(START) as Quarter,
    COUNT(DISTINCT id) AS number_of_patients
FROM
    encounters
GROUP BY YEAR(START) , QUARTER(START);

-- b. Which patients had the most readmissions?

SELECT 
   e.PATIENT, CONCAT( p.FIRST ," ", p.LAST) as Name, count(*) as num
FROM
    encounters e join patients p on e.PATIENT= p.Id
GROUP BY e.PATIENT order by num desc limit 10 ; 
