-- Quest 1
SELECT 
    customer_id,
    SUM(amount) AS total_revenue,
    SUM(amount) FILTER (
        WHERE status = 'completed'
    ) AS completed_revenue,
    COALESCE(SUM(amount) FILTER (
        WHERE status = 'pending'
    ), 0) AS pending_revenue,
    SUM(amount) FILTER (
        WHERE status = 'completed'
    )
    /
    SUM(amount) AS completed_share
FROM orders_day56
GROUP BY customer_id;
