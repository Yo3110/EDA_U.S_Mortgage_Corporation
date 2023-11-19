

--Q1. Calculate the average loan amount for male & female applicants

SELECT GENDER, ROUND(AVG(LOAN_AMOUNT), 2) AS AVG_LOAN_AMOUNT
FROM Mortgage_dataset
GROUP BY GENDER;



--Q2. Find the top 5 states with the highest average Applicant Income.

SELECT TOP 5 State, ROUND(avg(Applicant_Income),2) AS Avg_Income
FROM Mortgage_dataset
GROUP BY State
ORDER BY Avg_Income DESC;


--Q3. Find the applicants who have a loan amount greater than the average loan amount in their respective state

SELECT * FROM Mortgage_dataset
WHERE Loan_Amount > (
    SELECT AVG(Loan_Amount)
    FROM Mortgage_dataset AS sub
    WHERE sub.State = Mortgage_dataset.State);


-- Q4. Find the count of married and unmarried applicants with a good credit history in each property area

SELECT Property_Area, Married, COUNT(*) AS Count
FROM Mortgage_dataset
WHERE Credit_History = 1
GROUP BY Property_Area, Married;


--Q5.Find the top 3 counties with the highest average loan amount where the loan term is 360 months

SELECT TOP 3 County_ID, AVG(Loan_Amount) AS Avg_Loan_Amount
FROM Mortgage_dataset
WHERE Loan_Amount_Term = 360
GROUP BY County_ID
ORDER BY Avg_Loan_Amount DESC;


--Q6. Calculate the loan approval rate (percentage) for each city, and also show the running total of the approval rate:

exec sp_rename 'mortgage_dataset.loaunder review_status', 'Loan_Status';

WITH ApprovalRates AS (
    SELECT City,
           (COUNT(CASE WHEN Loan_Status = 'approved' THEN 1 ELSE NULL END) * 100.0 / COUNT(*)) AS Approval_Rate
    FROM Mortgage_dataset
    GROUP BY City
)
SELECT City, Approval_Rate,
       SUM(Approval_Rate) OVER (ORDER BY City) AS Running_Total
FROM ApprovalRates;


--Q7. Find the states with the highest and lowest number of self-employed applicants, 
--    to show the self-employment rate as a percentage of the total applicants in each state

WITH StateSelfEmployedCounts AS (
    SELECT State, COUNT(*) AS Num_Self_Employed
    FROM Mortgage_dataset
    WHERE Self_Employed = 'Yes'
    GROUP BY State
)
SELECT State, Num_Self_Employed,
       Num_Self_Employed * 100.0 / SUM(Num_Self_Employed) OVER (PARTITION BY StateSelfEmployedCounts.State) AS SelfEmploymentRate
FROM StateSelfEmployedCounts;

--Q8.Find the count of married and unmarried applicants with a good credit history in each property area, 
--   and also calculate the percentage within each group:

WITH GoodCreditCounts AS (
    SELECT Property_Area, Married, COUNT(*) AS Count
    FROM Mortgage_dataset
    WHERE Credit_History = 1
    GROUP BY Property_Area, Married
)
SELECT *,
       (Count * 100.0 / SUM(Count) OVER (PARTITION BY Property_Area)) AS Percentage
FROM GoodCreditCounts;

-- Q9. Find the education level with the highest average coapplicant income, 
--     and also calculate the cumulative coapplicant income by education level

WITH CoapplicantIncomeByEducation AS (
    SELECT Education,
           AVG(Coapplicant_Income) AS Avg_Coapplicant_Income
    FROM Mortgage_dataset
    GROUP BY Education
)
SELECT Education, Avg_Coapplicant_Income,
       SUM(Avg_Coapplicant_Income) OVER (ORDER BY Avg_Coapplicant_Income DESC) AS Cumulative_Coapplicant_Income
FROM CoapplicantIncomeByEducation
WHERE Avg_Coapplicant_Income = (SELECT MAX(Avg_Coapplicant_Income) FROM CoapplicantIncomeByEducation);


-- Q10. Find the average loan amount for each gender, and also calculate the median and standard deviation

SELECT Gender,
       AVG(Loan_Amount) OVER () AS Avg_Loan_Amount,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Loan_Amount) OVER () AS Median_Loan_Amount,
       STDEV(Loan_Amount) OVER () AS StdDev_Loan_Amount
FROM Mortgage_dataset;



SELECT * FROM Mortgage_dataset

