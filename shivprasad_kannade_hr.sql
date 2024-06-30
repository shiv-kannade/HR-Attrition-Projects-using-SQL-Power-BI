

USE HR_PROJECT ;

SELECT * FROM HR1 ;


----->1)  Compare an employee's performance rating with the average rating of their peers in the same department.

 SELECT 
    e.[emp no],
    e.Department,
    e.[Performance Rating],
    d.AvgDeptRating,
    CASE 
        WHEN e.[Performance Rating] > d.AvgDeptRating THEN 'Above Average'
        WHEN e.[Performance Rating] = d.AvgDeptRating THEN 'Average'
        ELSE 'Below Average'
    END AS PerformanceComparison
FROM 
    hr1 e
INNER JOIN (
    SELECT Department,
        AVG([Performance Rating]) AS AvgDeptRating
    FROM   hr1
    GROUP BY  Department
)  d 
ON e.Department = d.Department;




 ------> 2) Analyze the trend of employee attrition over time


 --->solution-1

 SELECT * FROM HR1
 WHERE [OVER TIME ] = 'YES'  AND Attrition = 'YES' ;


 ----->solution-2

 SELECT  [Years At Company], COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attritions
FROM  Hr1
GROUP BY [Years At Company]
ORDER BY  [Years At Company];


  
---->3) Predict the likelihood of an employee leaving based on their age, job role, and performance rating


 SELECT [JOB ROLE] ,  COUNT([emp no]) AS NO_OF_EMP  ,round(avg(age),0) as avg_age ,[Performance Rating]
 FROM HR1 
 WHERE Attrition = 'YES' 
 GROUP BY [Job Role] , [performance rating];


  ----->4) Compare the attrition rate between different departments.

 SELECT 
 Department, 
 ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*),0 ) AS Attrition_Rate
FROM hr1
GROUP BY  Department;


----->5)  Create Notification Alerts: Set up notification alerts in the database system to trigger when 
-----> specific conditions are met (e.g., sudden increase in attrition rate, take a threshold of >=10%)


CREATE TABLE AttritionAlerts (
    AlertID INT IDENTITY(1,1) PRIMARY KEY,
    AlertMessage NVARCHAR(255),
    AlertDate DATETIME DEFAULT GETDATE()
);


CREATE TRIGGER CheckAttritionRate
ON hr1
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @TotalEmployees INT;
    DECLARE @AttritionCount INT;
    DECLARE @AttritionRate FLOAT;
    DECLARE @Threshold FLOAT = 0.10;

    -- Calculate total number of employees
    SELECT @TotalEmployees = COUNT(*) FROM hr1;

    -- Calculate number of employees who have left
    SELECT @AttritionCount = COUNT(*) FROM hr1 WHERE Attrition = 'yes';

    -- Calculate attrition rate
    SET @AttritionRate = @AttritionCount / @TotalEmployees;

    -- Check if attrition rate exceeds the threshold
    IF @AttritionRate >= @Threshold
    BEGIN
        -- Insert an alert into the AttritionAlerts table
        INSERT INTO AttritionAlerts (AlertMessage)
        VALUES (CONCAT('Alert: Attrition rate has reached ', @AttritionRate * 100, '%'));
    END
END;




  ----> 6)  Pivot data to compare the average hourly rate across different education fields.

SELECT [EDUCATION FIELD] , ROUND(AVG([HOURLY RATE]) ,2) AS AVG_HOURLY_RATE FROM HR1
GROUP BY [EDUCATION FIELD] 
ORDER BY AVG_HOURLY_RATE DESC ;


