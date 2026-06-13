/* =================================================================================
   PROJECT: Data-Driven Support Operations: Analyzing Ticket Friction, 
            Channels, and Data Integrity
   DIALECT: Google BigQuery Standard SQL
   AUTHOR: Portfolio Project
   ================================================================================= */

-- ---------------------------------------------------------------------------------
-- QUESTION 1: Which ticket categories and issue subjects are associated with 
--             the lowest customer satisfaction ratings?
-- ---------------------------------------------------------------------------------
SELECT
    `Ticket Type`,
    `Ticket Subject`,
    COUNT(*) AS ticket_count,
    ROUND(AVG(`Customer Satisfaction Rating`), 1) AS avg_rating
FROM `data-analytics-practice-61.DA_Practice.cs_tickets_da`
GROUP BY `Ticket Type`, `Ticket Subject`
ORDER BY avg_rating ASC;


-- ---------------------------------------------------------------------------------
-- QUESTION 2: Which support channels perform best based on customer satisfaction?
-- ---------------------------------------------------------------------------------
SELECT
    `Ticket Channel`,
    COUNT(*) AS ticket_count,
    ROUND(AVG(`Customer Satisfaction Rating`), 2) AS avg_rating
FROM `data-analytics-practice-61.DA_Practice.cs_tickets_da`
GROUP BY `Ticket Channel`
HAVING COUNT(*) > 50
ORDER BY avg_rating DESC;


-- ---------------------------------------------------------------------------------
-- QUESTION 3: Are customer satisfaction scores related to resolution time?
--
-- DATA QUALITY AUDIT & INTEGRITY CONSTRAINTS:
-- During exploratory analysis, an issue was identified where 'Time to Resolution' 
-- occurred chronologically BEFORE 'First Response Time'.
-- 
-- The below query was utilized to audit the volume of corrupted data entry records.
-- Result: 6,712 rows (83.1% of the dataset) failed the integrity check. 
-- Only 1,365 records are structurally sound.
-- ---------------------------------------------------------------------------------

-- Audit Query: Identifying Impossible Timestamps
SELECT 
    `Customer Name`,
    `First Response Time`,
    `Time to Resolution`
FROM `data-analytics-practice-61.DA_Practice.cs_tickets_da`
WHERE `Time to Resolution` < `First Response Time`;

/* MITIGATION STRATEGY & STATISTICAL JUSTIFICATION:
To protect the integrity of the operational KPIs, the 83.1% of corrupted rows were isolated. 
The analysis proceeded using the 1,365 healthy records. This subset represents a 
statistically viable sample size (N > 1,000) capable of revealing baseline operational 
bottlenecks without skewing performance metrics with negative durations (Margin of Error ~2.6%).
*/

-- Step A: Checking Average Resolution Time and Average Rating across valid rows
-- Note: Grouping by ROUNDed hours ensures metrics aggregate into clean, readable intervals.
WITH resolution_duration AS (
    SELECT
        `First Response Time`,
        `Time to Resolution`,
        ROUND(TIMESTAMP_DIFF(`Time to Resolution`, `First Response Time`, MINUTE) / 60.0, 1) AS resolution_hours,
        `Customer Satisfaction Rating`
    FROM `data-analytics-practice-61.DA_Practice.cs_tickets_da`
    WHERE `Time to Resolution` > `First Response Time`
)
SELECT
    resolution_hours,
    COUNT(*) AS ticket_count,
    ROUND(AVG(`Customer Satisfaction Rating`), 2) AS avg_rating
FROM resolution_duration
GROUP BY resolution_hours
ORDER BY resolution_hours DESC;


-- Step B: Measuring Pearson Correlation Coefficient between Resolution Time and CSAT
WITH resolution_duration AS (
    SELECT
        TIMESTAMP_DIFF(`Time to Resolution`, `First Response Time`, MINUTE) / 60.0 AS resolution_hours,
        `Customer Satisfaction Rating`
    FROM `data-analytics-practice-61.DA_Practice.cs_tickets_da`
    WHERE `Time to Resolution` > `First Response Time`
      AND `Customer Satisfaction Rating` IS NOT NULL
)
SELECT
    CORR(resolution_hours, `Customer Satisfaction Rating`) AS correlation_coefficient
FROM resolution_duration;

/* FINDING: 
The correlation coefficient returned is -0.005. 
This indicates almost zero linear relationship between resolution duration and 
customer satisfaction ratings, demonstrating that resolution speed is not the 
primary driver of customer happiness in this ecosystem.
*/


-- ---------------------------------------------------------------------------------
-- QUESTION 4: Which products generate the most support tickets and lowest average rating?
-- ---------------------------------------------------------------------------------
SELECT
    `Product Purchased`,
    COUNT(*) AS product_total_tickets,
    ROUND(AVG(`Customer Satisfaction Rating`), 1) AS avg_satisfaction_rating
FROM `data-analytics-practice-61.DA_Practice.cs_tickets_da`
GROUP BY `Product Purchased`
ORDER BY product_total_tickets DESC;


-- ---------------------------------------------------------------------------------
-- QUESTION 5: Which priorities require the longest resolution times?
-- ---------------------------------------------------------------------------------
SELECT
    `Ticket Priority`,
    COUNT(*) AS total_tickets,
    ROUND(AVG(TIMESTAMP_DIFF(`Time to Resolution`, `First Response Time`, MINUTE) / 60.0), 2) AS avg_resolution_time_hours
FROM `data-analytics-practice-61.DA_Practice.cs_tickets_da`
WHERE `Time to Resolution` > `First Response Time`
GROUP BY `Ticket Priority`
ORDER BY avg_resolution_time_hours DESC;
