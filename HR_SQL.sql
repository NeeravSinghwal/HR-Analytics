create database hr_analytics;
use hr_analytics;
SET SQL_SAFE_UPDATES = 0;

-- Total Employees
SELECT 
    COUNT(*) AS 'Total_Emp'
FROM
    hr;

-- Average Salary
SELECT 
    ROUND(AVG(MonthlyIncome), 1) AS 'Avg_Salary'
FROM
    hr;

-- Average Age
SELECT 
    ROUND(AVG(Age), 1) AS 'Avg_Age'
FROM
    hr;

-- Total Attrition
SELECT 
    COUNT(Attrition) AS 'Total_Attrition'
FROM
    hr
WHERE
    Attrition = 'Yes';

-- Attrition Rate (%)
alter table hr add column Attrition_num int;
ALTER TABLE hr MODIFY COLUMN Attrition_num INT AFTER Attrition;

UPDATE hr 
SET 
    Attrition_num = CASE
        WHEN Attrition = 'No' THEN 0
        WHEN Attrition = 'Yes' THEN 1
    END
WHERE
    Attrition IN ('No' , 'Yes');

SELECT 
    ROUND((COUNT(CASE
                WHEN Attrition = 'Yes' THEN 1
            END) / NULLIF(COUNT(*), 0)) * 100,
            1) AS 'Attrition_Rate(%)'
FROM
    hr;

-- Average Job Satisfaction
SELECT 
    ROUND(AVG(JobSatisfaction), 1) AS 'Avg_JobSatisfaction'
FROM
    hr;

# Analytical Insights:
-- Top Earners by Job Role – Identifies compensation trends across roles.
SELECT EmpID, Department, MonthlyIncome
FROM (
    SELECT EmpID, Department, MonthlyIncome,
           RANK() OVER (PARTITION BY Department ORDER BY MonthlyIncome DESC) AS income_rank
    FROM hr
    WHERE Department IS NOT NULL AND MonthlyIncome IS NOT NULL
) ranked
WHERE income_rank = 1
ORDER BY Department, EmpID;

-- Attrition Rate by Overtime Status – Highlights correlations between overtime and employee turnover.
SELECT Overtime, 
       ROUND((COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) / COUNT(*)) * 100, 1) AS 'Attrition_Rate(%)'
FROM hr
WHERE Overtime IN ('Yes', 'No')
GROUP BY Overtime;

-- Environment Satisfaction by Department – Assesses workplace satisfaction across business units.
select Department, avg('EnvironmentSatisfaction') from hr group by Department;
SELECT Department, 
       ROUND(AVG(EnvironmentSatisfaction), 1) AS Avg_Environment_Satisfaction
FROM hr
WHERE Department IS NOT NULL AND EnvironmentSatisfaction IS NOT NULL
GROUP BY Department;

-- Average Tenure by Job Role – Provides insight into employee retention by function.
SELECT 
    JobRole, ROUND(AVG(YearsAtCompany), 1) AS Avg_Tenure_Years
FROM
    hr
WHERE
    JobRole IS NOT NULL
        AND YearsAtCompany IS NOT NULL
GROUP BY JobRole
ORDER BY AVG(YearsAtCompany) ASC;