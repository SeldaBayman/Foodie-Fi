SELECT *FROM plans;
SELECT * FROM subscriptions;

--Case Study Questions
--This case study is split into an initial data understanding question before diving straight into data analysis questions before finishing with 1 single extension challenge.

--A. Customer Journey
--Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
--Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

SELECT COUNT (DISTINCT s.customer_id),
       p.plan_id,
	   p.plan_name,
	   SUM( price) total_price      
FROM subScriptions s
LEFT JOIN plans p ON p.plan_id= s.plan_id
GROUP BY 2,3
ORDER BY 1,4
LIMIT 100;

--B. Data Analysis Questions
--1-How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) FROM subscriptions;

--2-What is the monthly distribution of trial plan start_date values for our dataset - 
--use the start of the month as the group by value

SELECT DATE_TRUNC ('month', start_date) monthly,
       COUNT (*) AS trial_count
FROM  subscriptions 
WHERE plan_id=0
GROUP BY DATE_TRUNC ('month', start_date) 
ORDER BY monthly;

--3-What plan, start_date values occur after the year 2020 for our dataset? 
--Show the breakdown by count of events for each plan_name

SELECT p.plan_name,
       COUNT(*) plan_start_count
FROM plans  p JOIN subscriptions s 
ON p.plan_id = s.plan_id
WHERE s.start_date > '2020-12-31'
GROUP BY 1
ORDER BY 2 desc;

--4-What is the customer count, and percentage of customers, who have churned rounded to 1 decimal place?

WITH last_subscriptions AS (
    SELECT 
        customer_id,
        MAX(start_date) AS last_start_date
    FROM subscriptions
    GROUP BY customer_id
),
churned_customers AS (
    SELECT 
        customer_id
    FROM last_subscriptions
    WHERE last_start_date < (CURRENT_DATE - INTERVAL '3 months')
),
total_customers AS (
    SELECT COUNT(DISTINCT customer_id) AS total
    FROM subscriptions
)
SELECT 
    COUNT(DISTINCT c.customer_id) AS churned_count,
    ROUND(COUNT(DISTINCT c.customer_id) * 100.0 / tc.total, 1) AS churned_percentage
FROM churned_customers c
JOIN total_customers tc ON true;

--5-How many customers have churned straight after their initial free trial - 
--what percentage is this rounded to the nearest whole number?

WITH last_subscriptions AS (
    SELECT 
        customer_id,
        MAX(start_date) AS last_start_date
    FROM subscriptions
    GROUP BY customer_id
),
churned_customers AS (
    SELECT 
        customer_id
    FROM last_subscriptions
    WHERE last_start_date < (CURRENT_DATE - INTERVAL '3 months')
),
total_customers AS (
    SELECT COUNT(DISTINCT customer_id) AS total
    FROM subscriptions
)
SELECT 
    COUNT(DISTINCT c.customer_id) AS churned_count,
    ROUND(COUNT(DISTINCT c.customer_id) * 100.0 / tc.total, 1) AS churned_percentage
FROM churned_customers c
JOIN total_customers tc ON true;


--6-What is the number and percentage of customer plans after their initial free trial?

WITH trial_customers AS (
    SELECT 
        customer_id,
        MIN(start_date) AS trial_start_date
    FROM subscriptions
    WHERE plan_id = 0
    GROUP BY customer_id
),
subsequent_subscriptions AS (
    SELECT 
        customer_id
    FROM subscriptions s
    JOIN trial_customers t ON s.customer_id = t.customer_id
    WHERE s.start_date > t.trial_start_date
),
churned_after_trial AS (
    SELECT 
        t.customer_id
    FROM trial_customers t
    LEFT JOIN subsequent_subscriptions s ON t.customer_id = s.customer_id
    WHERE s.customer_id IS NULL
),
total_trial_customers AS (
    SELECT COUNT(DISTINCT customer_id) AS total
    FROM trial_customers
)
SELECT 
    COUNT(DISTINCT c.customer_id) AS churned_count,
    ROUND(COUNT(DISTINCT c.customer_id) * 100.0 / tt.total) AS churned_percentage
FROM churned_after_trial c
JOIN total_trial_customers tt ON true;

--7-What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
--8-How many customers have upgraded to an annual plan in 2020?
--9-How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
--10-Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
--11-How many customers downgraded from a pro monthly to a basic monthly plan in 2020?




