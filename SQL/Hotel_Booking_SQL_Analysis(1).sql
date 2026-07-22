-- =========================================================
-- HOTEL BOOKING SQL ANALYSIS PROJECT
-- Author: Syed Nooruddin
-- Dataset: hotel_bookings.csv
-- =========================================================

-- Query 1: Overall Booking & Cancellation Summary
SELECT
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS total_cancellations,
    ROUND(SUM(is_canceled) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(
        SUM(
            CASE
                WHEN is_canceled = 1
                THEN adr * (stays_in_weekend_nights + stays_in_week_nights)
                ELSE 0
            END
        ), 2
    ) AS total_estimated_revenue_lost
FROM hotel_bookings;

-- Query 2: Hotel-wise Performance Analysis
SELECT
    hotel,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS cancellations,
    ROUND(SUM(is_canceled) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(AVG(adr), 2) AS avg_daily_rate
FROM hotel_bookings
GROUP BY hotel;

-- Query 3: Lead Time vs Cancellation Analysis (Fixed GROUP BY compatibility)
WITH lead_time_data AS (
    SELECT
        CASE
            WHEN lead_time <= 7 THEN '0-7 Days (Last Minute)'
            WHEN lead_time BETWEEN 8 AND 30 THEN '8-30 Days'
            WHEN lead_time BETWEEN 31 AND 90 THEN '31-90 Days'
            ELSE '90+ Days (Far Advance)'
        END AS lead_time_bucket,
        is_canceled
    FROM hotel_bookings
)
SELECT
    lead_time_bucket,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS cancellations,
    ROUND(SUM(is_canceled) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct
FROM lead_time_data
GROUP BY lead_time_bucket
ORDER BY cancellation_rate_pct DESC;

-- Query 4: Market Segment Analysis
SELECT
    market_segment,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS cancellations,
    ROUND(SUM(is_canceled) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct
FROM hotel_bookings
GROUP BY market_segment
ORDER BY cancellations DESC;

-- Query 5: Monthly Revenue Ranking (Window Function)
SELECT
    hotel,
    arrival_date_month,
    ROUND(SUM(adr * (stays_in_weekend_nights + stays_in_week_nights)), 2) AS total_revenue,
    DENSE_RANK() OVER(
        PARTITION BY hotel
        ORDER BY SUM(adr * (stays_in_weekend_nights + stays_in_week_nights)) DESC
    ) AS revenue_rank
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel, arrival_date_month;

-- Query 6: Meal Preference Analysis
SELECT
    meal,
    COUNT(*) AS total_bookings,
    ROUND(AVG(adr), 2) AS avg_adr
FROM hotel_bookings
GROUP BY meal
ORDER BY total_bookings DESC;

-- Query 7: Customer Type Performance
SELECT
    customer_type,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS cancellations,
    ROUND(AVG(adr), 2) AS avg_adr
FROM hotel_bookings
GROUP BY customer_type
ORDER BY total_bookings DESC;

-- Query 8: Top Countries by Bookings
SELECT
    country,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS cancellations
FROM hotel_bookings
GROUP BY country
ORDER BY total_bookings DESC
LIMIT 10;

-- Query 9: Reserved Room Type Performance
SELECT
    reserved_room_type,
    COUNT(*) AS total_bookings,
    ROUND(AVG(adr), 2) AS avg_adr,
    ROUND(SUM(is_canceled) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct
FROM hotel_bookings
GROUP BY reserved_room_type
ORDER BY total_bookings DESC;

-- Query 10: Monthly Booking Trend (Fixed ORDER BY GROUPing)
SELECT
    arrival_date_year,
    arrival_date_month,
    COUNT(*) AS total_bookings,
    ROUND(SUM(
        CASE
            WHEN is_canceled = 0
            THEN adr * (stays_in_weekend_nights + stays_in_week_nights)
            ELSE 0
        END
    ), 2) AS total_revenue
FROM hotel_bookings
GROUP BY 
    arrival_date_year, 
    arrival_date_month
ORDER BY 
    arrival_date_year, 
    MIN(arrival_date_week_number);
