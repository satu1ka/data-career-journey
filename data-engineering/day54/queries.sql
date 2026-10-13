-- orders_day54

-- order_id | customer_id | amount | created_at
-- ---------|-------------|--------|------------
-- A1       | 1           | 100    | 2026-10-01
-- A2       | 1           | 250    | 2026-10-03
-- A3       | 2           | 300    | 2026-10-02
-- A4       | 1           | 150    | 2026-10-05
-- A5       | 2           | 200    | 2026-10-06

-- -- Quest 2 — ranking + фильтр
-- WITH max_amount AS (
--     SELECT
--         customer_id,
--         order_id,
--         amount,
--         ROW_NUMBER() OVER (
--             PARTITION BY customer_id
--             ORDER BY amount DESC, order_id
--         ) AS amount_rank
--     FROM orders_day54
-- )

-- SELECT
--     customer_id,
--     order_id,
--     amount
-- FROM max_amount
-- WHERE amount_rank = 1

-- -- Quest 3 — немного сложнее
-- SELECT
--     customer_id,
--     order_id,
--     amount,
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--     ) AS customer_total,
--     amount 
--     /
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--     ) AS share_of_customer_total
-- FROM orders_day54

-- -- Quest 4 — закрепление LAG()
-- SELECT
--     customer_id,
--     order_id,
--     amount,
--     LAG(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--     ) AS previous_amount,
--     amount 
--     -
--     LAG(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--     ) AS difference_from_previous
-- FROM orders_day54

-- -- Quest 5 — ranking + running total вместе
-- SELECT
--     customer_id,
--     order_id,
--     amount,
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--     ) AS running_total,
--     ROW_NUMBER() OVER(
--         PARTITION BY customer_id
--         ORDER BY amount DESC, order_id
--     ) AS amount_rank
-- FROM orders_day54;

-- -- Quest 6
-- SELECT
--     customer_id,
--     order_id,
--     amount,
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--     ) AS customer_total,
--     AVG(amount) OVER (
--         PARTITION BY customer_id
--     ) AS customer_avg,
--     COUNT(order_id) OVER (
--         PARTITION BY customer_id
--     ) AS customer_orders_count
-- FROM orders_day54;

-- -- Quest 7 — ranking trio
-- SELECT
--     customer_id,
--     order_id,
--     amount,
--     ROW_NUMBER() OVER (
--         PARTITION BY customer_id
--         ORDER BY amount DESC, order_id
--     ) AS row_num,
--     RANK() OVER (
--         PARTITION BY customer_id
--         ORDER BY amount DESC
--     ) AS rank_num,
--     DENSE_RANK() OVER (
--         PARTITION BY customer_id
--         ORDER BY amount DESC
--     ) AS dense_rank_num
-- FROM orders_day54;

-- ROW_NUMBER
-- → 1, 2, 3, 4
-- → каждая строка уникальна

-- RANK
-- → 1, 2, 2, 4
-- → одинаковые значения делят место, потом есть gap

-- DENSE_RANK
-- → 1, 2, 2, 3
-- → одинаковые значения делят место, gap нет

-- -- Quest 8 — LAG() + изменение между заказами
-- SELECT
--     customer_id,
--     order_id,
--     amount,
--     LAG(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--     ) AS previous_amount,
--     amount
--     -
--     LAG(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--     ) AS amount_change
-- FROM orders_day54;

-- -- Quest 9 — LEAD() + взгляд вперёд
-- SELECT
--     customer_id,
--     order_id,
--     amount,
--     LEAD(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--     ) AS next_amount,
--     LEAD(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--     )
--     -
--     amount AS change_to_next
-- FROM orders_day54;

-- -- Quest 10 — Top-2 orders per customer
-- WITH rankings AS (
--     SELECT
--         customer_id,
--         order_id,
--         amount,
--         ROW_NUMBER() OVER (
--             PARTITION BY customer_id
--             ORDER BY amount DESC, order_id
--         ) AS amount_rank
--     FROM orders_day54
-- )

-- SELECT *
-- FROM rankings
-- WHERE amount_rank <= 2;

-- -- Quest 11 — Top-2 price levels with ties
-- WITH rankings AS (
--     SELECT
--         customer_id,
--         order_id,
--         amount,
--         DENSE_RANK() OVER (
--             PARTITION BY customer_id
--             ORDER BY amount DESC
--         ) AS amount_rank
--     FROM orders_day54
-- )

-- SELECT 
--     customer_id,
--     order_id,
--     amount,
--     amount_rank
-- FROM rankings
-- WHERE amount_rank <= 2;

-- -- Quest 12 — сравнение с average
-- SELECT 
--     customer_id,
--     order_id,
--     amount,
--     AVG(amount) OVER (
--         PARTITION BY customer_id
--     ) AS customer_avg,
--     amount
--     -
--     AVG(amount) OVER (
--         PARTITION BY customer_id
--     ) AS difference_from_avg
-- FROM orders_day54;

-- -- Quest 13 — кто выше среднего
-- WITH customers_average AS (
--     SELECT 
--         customer_id,
--         order_id,
--         amount,
--         AVG(amount) OVER (
--             PARTITION BY customer_id
--         ) AS customer_avg
--     FROM orders_day54
-- )

-- SELECT
--     customer_id,
--     order_id,
--     amount,
--     customer_avg
-- FROM customers_average
-- WHERE amount > customer_avg;

-- -- Quest 14 — running total + threshold
-- WITH running AS (
--     SELECT
--         customer_id,
--         order_id,
--         created_at,
--         amount,
--         SUM(amount) OVER (
--             PARTITION BY customer_id
--             ORDER BY created_at
--         ) AS running_total
-- FROM orders_day54
-- ),
-- over_500 AS (
--     SELECT
--         customer_id,
--         order_id,
--         created_at,
--         amount,
--         running_total,
--         ROW_NUMBER() OVER (
--             PARTITION BY customer_id
--             ORDER BY created_at 
--         ) AS ranks
--     FROM running
--     WHERE running_total >= 500
-- )

-- SELECT 
--     customer_id,
--     order_id,
--     created_at,
--     running_total
-- FROM over_500
-- WHERE ranks = 1;

-- -- Quest 15 — previous order + customer average
-- SELECT 
--     customer_id,
--     order_id,
--     amount,
--     LAG(amount) OVER(
--         PARTITION BY customer_id
--         ORDER BY created_at
--     ) AS previous_amount,
--     AVG(amount) OVER(
--         PARTITION BY customer_id
--     ) AS customer_avg
-- FROM orders_day54;

-- -- Quest 16 — current vs previous vs average
-- SELECT 
--     customer_id,
--     order_id,
--     amount,
--     LAG(amount) OVER(
--         PARTITION BY customer_id
--         ORDER BY created_at
--     ) AS previous_amount,
--     AVG(amount) OVER(
--         PARTITION BY customer_id
--     ) AS customer_avg,
--     amount
--     -
--     LAG(amount) OVER(
--         PARTITION BY customer_id
--         ORDER BY created_at
--     ) AS change_from_previous,
--     amount 
--     -
--     AVG(amount) OVER(
--         PARTITION BY customer_id
--     ) AS difference_from_avg
-- FROM orders_day54;

-- -- Quest 17
-- SELECT
--     customer_id,
--     order_id,
--     amount,
--     SUM(amount) OVER (
--         PARTITION BY customer_id
--     ) AS customer_total,
--     ROW_NUMBER() OVER (
--         PARTITION BY customer_id
--         ORDER BY amount DESC, order_id
--     ) AS amount_rank,
--     LAG(amount) OVER (
--         PARTITION BY customer_id
--         ORDER BY created_at
--     ) AS previous_amount
-- FROM orders_day54;

-- -- Quest 18 — выше среднего + ranking
-- WITH avg_rank AS (
--     SELECT
--         customer_id,
--         order_id,
--         amount,
--         AVG(amount) OVER (
--             PARTITION BY customer_id
--         ) AS customer_avg,
--         ROW_NUMBER() OVER (
--             PARTITION BY customer_id
--             ORDER BY amount DESC, order_id
--         ) AS amount_rank
--     FROM orders_day54
-- )

-- SELECT
--     customer_id,
--     order_id,
--     amount,
--     customer_avg,
--     amount_rank
-- FROM avg_rank
-- WHERE amount > customer_avg;

-- Quest 19
WITH avg_rank AS (
    SELECT
        customer_id,
        order_id,
        created_at,
        amount,
        AVG(amount) OVER (
            PARTITION BY customer_id
        ) AS customer_avg
    FROM orders_day54
),
higher_than_avg AS (
    SELECT
        customer_id,
        order_id,
        created_at,
        amount,
        customer_avg,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY created_at, order_id
        ) AS row_num
    FROM avg_rank
    WHERE amount > customer_avg
)

SELECT
    customer_id,
    order_id,
    created_at,
    amount,
    customer_avg
FROM higher_then_avg
WHERE row_num = 1;