-- -- Quest 1 — окно + фильтрация
-- WITH avg_orders AS (
--     SELECT
--         customer_id,
--         order_id,
--         amount,
--         AVG(amount) OVER (
--             PARTITION BY customer_id
--         ) AS customer_avg
--     FROM orders_day54
-- ),
-- max_orders AS (
--     SELECT 
--         customer_id,
--         order_id,
--         amount,
--         customer_avg,
--         ROW_NUMBER() OVER (
--             PARTITION BY customer_id
--             ORDER BY amount DESC, order_id
--         ) AS amount_rank
--     FROM avg_orders
--     WHERE amount > customer_avg
-- )

-- SELECT
--     customer_id,
--     order_id,
--     amount,
--     customer_avg
-- FROM max_orders
-- WHERE amount_rank = 1;

-- CURRENT ROW
-- → текущая строка

-- 1 PRECEDING
-- → одна строка назад

-- 2 PRECEDING
-- → две строки назад

-- 1 FOLLOWING
-- → одна строка вперёд

-- UNBOUNDED PRECEDING
-- → от самого начала partition

-- UNBOUNDED FOLLOWING
-- → до самого конца partition
-- ROWS BETWEEN start AND end
-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

-- -- Quest 3
-- SELECT
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--         ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
--     ) AS two_order_sum
-- FROM orders_day54;

-- -- Quest 4 — rolling average по 3 заказам
-- SELECT
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     AVG(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
--     ) AS three_order_avg
-- FROM orders_day54;

-- -- Quest 5 — окно вперёд и назад
-- SELECT
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     AVG(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--         ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
--     ) AS neighbor_avg
-- FROM orders_day54;

-- -- Quest 6 — явный running total через frame
-- SELECT
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--         ROWS UNBOUNDED PRECEDING
--     ) AS running_total
-- FROM orders_day54;

-- -- Quest 9 — сумма от текущего заказа до конца
-- SELECT 
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at 
--         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
--     ) AS remaining_total
-- FROM orders_day54;

-- -- Quest 10 — окно вокруг текущей строки, но через SUM()
-- SELECT
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--         ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
--     ) AS three_order_sum
-- FROM orders_day54;

-- -- Quest 11 — сравнить два frame в одном запросе
-- SELECT 
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--     ) AS running_total,
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at 
--         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
--     ) AS remaining_total
-- FROM orders_day54;

-- -- Quest 12 — rolling max по последним 3 заказам
-- SELECT
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     MAX(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
--     ) AS max_last_3_orders
-- FROM orders_day54;

-- -- Quest 13 — rolling average + фильтрация
-- WITH orders_with_rolling_avg AS (
--     SELECT
--         customer_id,
--         order_id,
--         created_at,
--         amount,
--         AVG(amount) OVER (
--             PARTITION BY customer_id
--             ORDER BY created_at
--             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
--         ) AS avg_last_3_orders
--     FROM orders_day54
-- ) 

-- SELECT
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     avg_last_3_orders
-- FROM orders_with_rolling_avg
-- WHERE amount > avg_last_3_orders;

-- Quest 14 — сравнение с предыдущими заказами
-- WITH orders_with_2_previous_avg AS (
--     SELECT
--         customer_id,
--         order_id,
--         created_at,
--         amount,
--         AVG(amount) OVER (
--             PARTITION BY customer_id
--             ORDER BY created_at
--             ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING
--         ) AS previous_2_avg
--     FROM orders_day54
-- )

-- SELECT 
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     previous_2_avg
-- FROM orders_with_2_previous_avg
-- WHERE amount > previous_2_avg;

-- -- Quest 15 — rolling count
-- SELECT 
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     COUNT(order_id) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
--     ) AS last_3_orders_count
-- FROM orders_day54;

-- -- Quest 16 — mixed frame + comparison
-- WITH orders_with_2_previous_max AS (
--     SELECT
--         customer_id,
--         order_id,
--         created_at,
--         amount,
--         MAX(amount) OVER (
--             PARTITION BY customer_id
--             ORDER BY created_at
--             ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING
--         ) AS previous_2_max
--     FROM orders_day54
-- )

-- SELECT
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     previous_2_max,
--     -- ХИТРОСТЬ для булеан сравнения
--     amount > previous_2_max AS is_new_local_high  
-- FROM orders_with_2_previous_max;

-- -- Quest 17 — frame + boolean + фильтр
-- WITH orders_with_2_previous_max AS (
--     SELECT
--         customer_id,
--         order_id,
--         created_at,
--         amount,
--         MAX(amount) OVER (
--             PARTITION BY customer_id
--             ORDER BY created_at
--             ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING
--         ) AS previous_2_max
--     FROM orders_day54
-- )

-- SELECT 
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     previous_2_max
-- FROM orders_with_2_previous_max
-- WHERE amount > previous_2_max;

-- -- Quest 18 — симметричный frame
-- SELECT
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     AVG(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--         ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
--     ) AS local_avg_5
-- FROM orders_day54;

-- -- Quest 19 — mixed: два frame в одном SELECT
-- SELECT
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     AVG(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--         ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING
--     ) AS previous_2_avg,
--     AVG(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--         ROWS BETWEEN 1 FOLLOWING AND 2 FOLLOWING
--     ) AS next_2_avg
-- FROM orders_day54;

-- -- Quest 20 — последний сложный на Window Frames
-- WITH orders_with_2_next_and_previous_avg AS (
--     SELECT
--         customer_id,
--         order_id,
--         created_at,
--         amount,
--         AVG(amount) OVER (
--             PARTITION BY customer_id
--             ORDER BY created_at
--             ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING
--         ) AS previous_2_avg,
--         AVG(amount) OVER (
--             PARTITION BY customer_id
--             ORDER BY created_at
--             ROWS BETWEEN 1 FOLLOWING AND 2 FOLLOWING
--         ) AS next_2_avg
--     FROM orders_day54
-- )

-- SELECT
--     customer_id,
--     order_id,
--     created_at,
--     amount,
--     previous_2_avg,
--     next_2_avg
-- FROM orders_with_2_next_and_previous_avg
-- WHERE 
--     amount > previous_2_avg 
--     AND amount > next_2_avg;

-- Quest 21 — смешиваем frame со старым ranking
WITH orders_with_rolling_avg AS (
    SELECT 
        customer_id,
        order_id,
        created_at,
        amount,
        AVG(amount) OVER (
            PARTITION BY customer_id
            ORDER BY created_at
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_avg
    FROM orders_day54
),

ranked_orders AS (
    SELECT 
        customer_id,
        order_id,
        created_at,
        amount,
        rolling_avg,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY rolling_avg DESC, created_at, order_id
        ) AS rolling_rank
    FROM orders_with_rolling_avg
)

SELECT
    customer_id,
    order_id,
    created_at,
    amount,
    rolling_avg
FROM ranked_orders
WHERE rolling_rank = 1;