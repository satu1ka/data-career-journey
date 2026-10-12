-- -- Quest 2 — первый код
-- SELECT
--     order_id,
--     product_id,
--     quantity,
--     SUM(quantity) OVER (PARTITION BY order_id) AS order_total_quantity
-- FROM order_items_day40;

-- -- Quest 3 — PARTITION BY без изменения grain
-- SELECT
--     order_id,
--     customer_id,
--     status,
--     COUNT(order_id) OVER (PARTITION BY customer_id) AS customer_orders_count
-- FROM orders_day40;

-- -- Quest 4 — AVG как window function
-- SELECT
--     product_name,
--     category,
--     price,
--     AVG(price) OVER (PARTITION BY category) AS category_avg_price
-- FROM products_day40;

-- Quest 7 — ranking ties
-- ROW_NUMBER
-- → 1, 2, 3, 4
-- → каждая строка уникальна

-- RANK
-- → 1, 2, 2, 4
-- → одинаковые значения делят место, потом есть gap

-- DENSE_RANK
-- → 1, 2, 2, 3
-- → одинаковые значения делят место, gap нет

-- -- Quest 8 — первый ranking SQL
-- SELECT 
--     product_name,
--     category,
--     price,
--     DENSE_RANK() OVER (
--         PARTITION BY category
--         ORDER BY price DESC
--     ) AS price_rank
-- FROM products_day40;

-- -- Quest 9 — код
-- WITH top_two AS (
--     SELECT
--         product_name,
--         category,
--         price,
--         ROW_NUMBER() OVER (
--             PARTITION BY category
--             ORDER BY price DESC, product_id
--         ) AS price_rank
--     FROM products_day40
-- )

-- SELECT *
-- FROM top_two
-- WHERE price_rank <= 2;

-- -- Quest 10 — window ORDER BY vs обычный ORDER BY
-- SELECT
--     product_name,
--     category,
--     price,
--     ROW_NUMBER() OVER (
--         PARTITION BY category
--         ORDER BY price DESC
--     ) AS price_rank
-- FROM products_day40
-- ORDER BY product_name;

-- -- Quest 12 — window metric + обычный calculation
-- SELECT
--     product_name,
--     category,
--     price,
--     AVG(price) OVER (
--         PARTITION BY category
--     ) AS category_avg_price,
--     price 
--     - 
--     AVG(price) OVER (
--         PARTITION BY category
--     ) AS difference_from_avg
-- FROM products_day40;

-- -- Quest 14 — текущий vs предыдущий order
-- SELECT
--     order_id,
--     customer_id,
--     amount,
--     LAG(amount) OVER(
--         PARTITION BY customer_id
--         ORDER BY created_at
--     ) AS previous_amount,
--     amount
--     -
--     LAG(amount) OVER(
--         PARTITION BY customer_id
--         ORDER BY created_at
--     ) AS difference_from_previous
-- FROM table;

-- Set:
-- SUM / AVG / COUNT OVER(...)
-- ROW_NUMBER()
-- RANK()
-- DENSE_RANK()
-- LAG()
-- LEAD()

-- -- Quest 17 — JOIN + window metric
-- SELECT 
--     oi.order_id,
--     oi.product_id,
--     oi.quantity,
--     p.price * oi.quantity AS line_revenue,
--     SUM(p.price * oi.quantity) OVER (
--         PARTITION BY oi.order_id
--     ) AS order_revenue
-- FROM order_items_day40 AS oi
-- JOIN products_day40 AS p
--     ON oi.product_id = p.product_id;

-- -- Quest 18 — теперь сравнение строки с total заказа
-- SELECT 
--     oi.order_id,
--     oi.product_id,
--     oi.quantity,
--     p.price * oi.quantity AS line_revenue,
--     SUM(p.price * oi.quantity) OVER (
--         PARTITION BY oi.order_id
--     ) AS order_revenue,
--     CAST(p.price * oi.quantity AS NUMERIC)
--     /
--     SUM(p.price * oi.quantity) OVER (
--         PARTITION BY oi.order_id
--     ) AS share_of_order
-- FROM order_items_day40 AS oi
-- JOIN products_day40 AS p
--     ON oi.product_id = p.product_id;

-- -- Quest 19 — mixed practice: top product per order
-- WITH order_lines_with_revenue AS(
--     SELECT 
--         oi.order_id,
--         oi.product_id,
--         p.product_name,
--         p.price * oi.quantity AS line_revenue
--     FROM order_items_day40 AS oi
--     JOIN products_day40 AS p
--         ON oi.product_id = p.product_id
-- ),
-- ranked_order_lines AS(
--     SELECT
--         *,
--         ROW_NUMBER() OVER(
--             PARTITION BY order_id
--             ORDER BY line_revenue DESC, product_id
--         ) AS revenue_rank
--     FROM order_lines_with_revenue
-- ) 

-- SELECT
--     order_id,
--     product_id,
--     product_name,
--     line_revenue
-- FROM ranked_order_lines
-- WHERE revenue_rank = 1;

-- -- Quest 20 — JOIN + business filter + window
-- SELECT
--     o.order_id,
--     o.customer_id,
--     oi.product_id,
--     p.price * oi.quantity AS line_revenue,
--     SUM(p.price * oi.quantity) OVER(
--         PARTITION BY o.customer_id
--     ) AS customer_total_revenue
-- FROM orders_day40 AS o
-- JOIN order_items_day40 AS oi
--     ON o.order_id = oi.order_id
--     AND o.status = 'completed'
-- JOIN products_day40 AS p
--     ON p.product_id = oi.product_id

-- -- Quest 21 — window + EXISTS/NOT EXISTS
-- SELECT
--     o.order_id,
--     o.customer_id,
--     oi.product_id,
--     p.price * oi.quantity AS line_revenue,
--     SUM(p.price * oi.quantity) OVER(
--         PARTITION BY o.customer_id
--     ) AS customer_total_revenue
-- FROM orders_day40 AS o
-- JOIN order_items_day40 AS oi
--     ON o.order_id = oi.order_id
--     AND o.status = 'completed'
-- JOIN products_day40 AS p
--     ON p.product_id = oi.product_id
-- WHERE NOT EXISTS (
--     SELECT 1 
--     FROM orders_day40 AS po 
--     WHERE po.customer_id = o.customer_id
--     AND po.status = 'pending'
-- );

-- EXISTS
-- → существует хотя бы одна подходящая строка?

-- NOT EXISTS
-- → не существует ни одной подходящей строки?

-- correlated EXISTS
-- → существует ли подходящая строка именно для текущей внешней строки?

-- Quest 22
WITH eligible_completed_orders AS(
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_id
    FROM customers_day40 AS c
    JOIN orders_day40 AS o
        ON c.customer_id = o.customer_id
        AND o.status = 'completed'
    WHERE NOT EXISTS (
        SELECT 1
        FROM orders_day40 AS po
        WHERE po.customer_id = o.customer_id
        AND po.status = 'pending'
    )
),

order_lines_with_revenue AS(
    SELECT 
        eco.customer_id,
        eco.customer_name,
        eco.order_id,
        oi.product_id,
        p.price * oi.quantity AS line_revenue
    FROM eligible_completed_orders AS eco
    JOIN order_items_day40 AS oi
        ON eco.order_id = oi.order_id
    JOIN products_day40 AS p
        ON p.product_id = oi.product_id
),

completed_orders_revenue AS(
    SELECT 
        customer_id,
        customer_name,
        order_id,
        SUM(line_revenue) AS order_revenue
    FROM order_lines_with_revenue
    GROUP BY 
        order_id,
        customer_id,
        customer_name
),

ranked_orders AS(
    SELECT 
        *,
        ROW_NUMBER() OVER(
            PARTITION BY customer_id
            ORDER BY order_revenue DESC, order_id
        ) AS revenue_rank,
        SUM(order_revenue) OVER(
            PARTITION BY customer_id
        ) AS customer_completed_revenue
    FROM completed_orders_revenue
)

SELECT 
    customer_id,
    customer_name,
    order_id,
    order_revenue,
    customer_completed_revenue
FROM ranked_orders
WHERE revenue_rank = 1;

