/* 
Personal Expense & Spending Behavior Analysis
   This SQL file contains all the queries I used to analyze
   my personal expense data for one full month.

   The goal of this analysis is to understand:
   - Where most of the money is spent
   - Daily and weekly spending patterns
   - Differences between weekday and weekend expenses
*/


CREATE DATABASE IF NOT EXISTS personal_expense_analysis;
USE personal_expense_analysis;




DROP TABLE IF EXISTS expenses;

CREATE TABLE expenses (
    date DATE NOT NULL,
    day VARCHAR(10) NOT NULL,
    day_type VARCHAR(10),
    category VARCHAR(20) NOT NULL, 
    description VARCHAR(50),  
    amount DECIMAL(10,2) NOT NULL,
    payment_mode VARCHAR(10)     
);





-- Check how many records were imported
SELECT COUNT(*) AS total_records
FROM expenses;

-- Check for any missing or invalid amount values
SELECT *
FROM expenses
WHERE amount IS NULL OR amount <= 0;




-- 1. Total spending for the month
-- This gives a high-level view of overall expenses
SELECT 
    SUM(amount) AS total_monthly_spending
FROM expenses;


-- 2. Category-wise spending
-- Helps identify which categories consume the most money
SELECT 
    category,
    SUM(amount) AS total_spent
FROM expenses
GROUP BY category
ORDER BY total_spent DESC;


-- 3. Food expense breakdown
-- Splits food spending into lunch, dinner, and snacks
SELECT 
    description,
    SUM(amount) AS total_food_spend
FROM expenses
WHERE category = 'Food'
GROUP BY description
ORDER BY total_food_spend DESC;


-- 4. Weekday vs weekend spending
-- Used to analyze behavioral differences in spending
SELECT 
    day_type,
    SUM(amount) AS total_spent
FROM expenses
GROUP BY day_type;




-- 5. Daily expense summary
-- Shows how much was spent on each day
SELECT 
    date,
    SUM(amount) AS daily_expense
FROM expenses
GROUP BY date
ORDER BY date;


-- 6. Average daily spending
-- Useful to understand normal daily expense behavior
SELECT 
    ROUND(AVG(daily_total), 2) AS avg_daily_spend
FROM (
    SELECT 
        date,
        SUM(amount) AS daily_total
    FROM expenses
    GROUP BY date
) t;


-- 7. Top 5 highest spending days
-- Helps identify days with unusual or high expenses
SELECT 
    date,
    SUM(amount) AS daily_expense
FROM expenses
GROUP BY date
ORDER BY daily_expense DESC
LIMIT 5;


-- 8. Lowest 5 spending days
-- Shows days with minimal spending
SELECT 
    date,
    SUM(amount) AS daily_expense
FROM expenses
GROUP BY date
ORDER BY daily_expense ASC
LIMIT 5;




-- Spending by payment mode
-- Shows preference for UPI, Cash, or Card
SELECT 
    payment_mode,
    SUM(amount) AS total_spent
FROM expenses
GROUP BY payment_mode
ORDER BY total_spent DESC;




-- Spending on non-essential categories
-- Useful for identifying possible cost-cutting areas
SELECT 
    category,
    SUM(amount) AS non_essential_spend
FROM expenses
WHERE category IN ('Entertainment', 'Shopping', 'Others')
GROUP BY category
ORDER BY non_essential_spend DESC;



--  Weekly spending trend
-- Aggregates expenses on a weekly basis
SELECT 
    WEEK(date) AS week_number,
    SUM(amount) AS weekly_spend
FROM expenses
GROUP BY WEEK(date)
ORDER BY week_number;


-- total of expenses day by day
-- Shows how expenses accumulate over time
SELECT 
    date,
    SUM(SUM(amount)) OVER (ORDER BY date) AS cumulative_spending
FROM expenses
GROUP BY date
ORDER BY date;


-- Identifies days where total spending was higher
-- than the average daily expense
SELECT 
    date,
    SUM(amount) AS daily_spend
FROM expenses
GROUP BY date
HAVING SUM(amount) > (
    SELECT AVG(daily_total)
    FROM (
        SELECT 
            date,
            SUM(amount) AS daily_total
        FROM expenses
        GROUP BY date
    ) t
)
ORDER BY daily_spend DESC;


