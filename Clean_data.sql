##Step 1: #Data Cleaning
##Remove #Null Values: Start by ensuring there are no null values in critical fields, such as listing_id, date, and price.

#Listing Table (Cleaned)


CREATE OR REPLACE TABLE `your_project.your_dataset.listing_cleaned` AS
SELECT 
    id AS listing_id,
    room_type,
    host_response_time,
    review_scores_value
FROM 
    `your_project.your_dataset.listing`
WHERE 
    id IS NOT NULL
    AND room_type IS NOT NULL
    AND host_response_time IS NOT NULL
    AND review_scores_value IS NOT NULL;
-------------------------------
# Calendar Table (Cleaned)

CREATE OR REPLACE TABLE `your_project.your_dataset.calendar_cleaned` AS
SELECT 
    listing_id,
    date,
    available,
    CAST(price AS FLOAT64) AS price
FROM 
    `your_project.your_dataset.calendar`
WHERE 
    listing_id IS NOT NULL
    AND date IS NOT NULL
    AND price IS NOT NULL;
-------------------------------
#Convert Data Types: Ensure that fields like price are in a numeric format (e.g., FLOAT) for calculations, and that date is in DATE format.

#Already included in the cleaning queries above with CAST(price AS FLOAT64) for price and using the date field as DATE.
---------------------------------
#Step 2: Creating Calculated Fields
#Occupied Room Indicator: Create a calculated field to indicate whether a room was occupied (1 for occupied, 0 for available).

#Occupied Room Indicator Calculation in the Combined Table


CASE WHEN available = FALSE THEN 1 ELSE 0 END AS occupied_room_indicator
Revenue Calculation: Calculate the revenue based on the price field, only when a room is occupied.
---------------------------------
#Revenue Calculation

price * (CASE WHEN available = FALSE THEN 1 ELSE 0 END) AS revenue

#Step 3: Joining the Tables
#Now that the data is cleaned and you have necessary calculated fields, you can join the listing_cleaned and calendar_cleaned tables to create a single table for analysis.

CREATE OR REPLACE TABLE `your_project.your_dataset.listing_calendar_combined` AS
SELECT
    l.listing_id,
    l.room_type,
    l.host_response_time,
    l.review_scores_value,
    c.date,
    c.available,
    c.price,
    -- Calculate Occupied Room Indicator
    CASE WHEN c.available = FALSE THEN 1 ELSE 0 END AS occupied_room_indicator,
    -- Calculate Revenue
    c.price * (CASE WHEN c.available = FALSE THEN 1 ELSE 0 END) AS revenue
FROM
    `your_project.your_dataset.listing_cleaned` AS l
JOIN
    `your_project.your_dataset.calendar_cleaned` AS c
ON
    l.listing_id = c.listing_id;

#Step 4: Additional Queries for Analysis (Optional)
#After joining the tables, you may want to run some additional queries to create aggregated data for analysis:
---------------------------
#Calculate Daily Occupancy Rate:

SELECT
    date,
    SUM(occupied_room_indicator) / COUNT(available) AS daily_occupancy_rate
FROM
    `your_project.your_dataset.listing_calendar_combined`
GROUP BY
    date
ORDER BY
    date;
-----------------------------   
#Calculate Average Price by Room Type:


SELECT
    room_type,
    AVG(price) AS average_price
FROM
    `your_project.your_dataset.listing_calendar_combined`
GROUP BY
    room_type
ORDER BY
    average_price DESC;
-----------------------------  
#Calculate Average Review Score by Host Response Time:


SELECT
    host_response_time,
    AVG(review_scores_value) AS average_review_score
FROM
    `your_project.your_dataset.listing_calendar_combined`
GROUP BY
    host_response_time
ORDER BY
    average_review_score DESC;
