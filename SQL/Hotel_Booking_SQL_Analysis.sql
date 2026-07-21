-- ==========================================================
-- Query 5: Monthly Revenue Ranking by Hotel
--
-- Business Question:
-- Which months generate the highest estimated revenue for
-- each hotel type? Rank the months based on total revenue
-- using a window function.
--
-- SQL Concepts Used:
-- DENSE_RANK(), OVER(), PARTITION BY, GROUP BY, SUM(), ROUND()
-- ==========================================================

SELECT 
    hotel,
    arrival_date_month,
    ROUND(SUM(adr * (stays_in_weekend_nights + stays_in_week_nights)), 2) AS total_revenue,
    DENSE_RANK() OVER (
        PARTITION BY hotel
        ORDER BY SUM(adr * (stays_in_weekend_nights + stays_in_week_nights)) DESC
    ) AS revenue_rank
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel, arrival_date_month;