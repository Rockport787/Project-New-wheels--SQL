/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
use vehdb;
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
SELECT state,count(customer_name) distribution_cust 
FROM customer_t 
GROUP BY state ;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.*/

SELECT
    quarter_number,
    AVG(CASE 
            WHEN customer_feedback = 'Very Bad' THEN 1
            WHEN customer_feedback = 'Bad' THEN 2
            WHEN customer_feedback = 'Okay' THEN 3
            WHEN customer_feedback = 'Good' THEN 4
            WHEN customer_feedback = 'Very Good' THEN 5
            ELSE NULL
        END) AS average_rating
FROM
    order_t
GROUP BY
    quarter_number
ORDER BY
    quarter_number;
     
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. 
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  And find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
     */ 
     use vehdb;
WITH FeedbackCounts AS (
    SELECT
        quarter_number,
        customer_feedback,
        COUNT(*) AS feedback_count
    FROM
        order_t
    GROUP BY
        quarter_number,
        customer_feedback
),
TotalFeedbackCounts AS (
    SELECT
        quarter_number,
        SUM(feedback_count) AS total_feedback_count
    FROM
        FeedbackCounts
    GROUP BY
        quarter_number
)
SELECT
    fc.quarter_number,
    fc.customer_feedback,
    fc.feedback_count,
    tfc.total_feedback_count,
    (fc.feedback_count / tfc.total_feedback_count * 100) AS percentage
FROM
    FeedbackCounts fc
JOIN
    TotalFeedbackCounts tfc ON fc.quarter_number = tfc.quarter_number
ORDER BY
    fc.quarter_number, fc.customer_feedback;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

select p.vehicle_maker,count(o.customer_id) customer_count from product_t p inner join order_t o
on p.product_id = o.product_id
group by p.vehicle_maker order by customer_count desc limit 5;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?*/


SELECT
    c.state,
    p.vehicle_maker AS most_preferred_vehicle_make,
    COUNT(*) AS total_orders
FROM
    order_t o
JOIN
    customer_t c ON o.customer_id = c.customer_id
JOIN
    product_t p ON o.product_id = p.product_id
GROUP BY
    c.state,
	p.vehicle_maker
HAVING
    COUNT(*) = 
    (SELECT
            MAX(order_count)
        FROM
            (SELECT
                COUNT(*) AS order_count
            FROM
                order_t l
            JOIN
                customer_t m ON l.customer_id = m.customer_id
            JOIN
                product_t n ON l.product_id = n.product_id
            WHERE
                m.state = c.state
            GROUP BY
                n.vehicle_maker) AS inner_query
    )
ORDER BY
    c.state;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

SELECT quarter_number, COUNT(*) AS number_of_orders
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      
*/
     WITH RevenueByQuarter AS (
    SELECT
        quarter_number,
        SUM(quantity * vehicle_price) AS revenue
    FROM
        order_t
    GROUP BY
        quarter_number
),
QuarterlyChange AS (
    SELECT
        q1.quarter_number AS current_quarter,
        q1.revenue AS current_revenue,
        q2.quarter_number AS previous_quarter,
        q2.revenue AS previous_revenue,
        CASE
            WHEN q2.revenue = 0 THEN NULL
            ELSE (q1.revenue - q2.revenue) / q2.revenue * 100
        END AS qoq_percentage_change
    FROM
        RevenueByQuarter q1
    LEFT JOIN
        RevenueByQuarter q2 ON q1.quarter_number = q2.quarter_number + 1
)
SELECT current_quarter, current_revenue, previous_quarter, previous_revenue, qoq_percentage_change
FROM QuarterlyChange
ORDER BY current_quarter;

      

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

WITH RevenueByQuarter AS (
    SELECT quarter_number,
        SUM(quantity * vehicle_price) AS revenue
    FROM order_t
    GROUP BY quarter_number
),
OrdersByQuarter AS (
    SELECT
        quarter_number,
        COUNT(*) AS order_count
    FROM
        order_t
    GROUP BY
        quarter_number
)
SELECT r.quarter_number,r.revenue,o.order_count
FROM RevenueByQuarter r JOIN OrdersByQuarter o 
ON r.quarter_number = o.quarter_number
ORDER BY r.quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

SELECT c.credit_card_type,AVG(o.discount) AS average_discount
FROM order_t o join customer_t c 
on o.customer_id=c.customer_id
GROUP BY credit_card_type
order by average_discount desc;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/
SELECT quarter_number,AVG(DATEDIFF(ship_date, order_date)) AS avg_ship_time_in_days
FROM order_t 
GROUP BY quarter_number
order by quarter_number;


-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



