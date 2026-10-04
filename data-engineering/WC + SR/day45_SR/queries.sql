-- И вот тут важная штука: grain SQL сам не “высчитывает” как отдельную операцию. Мы его определяем по тому, что представляет одна строка результата после JOIN'ов.
-- Возьмём наш пример.
-- До JOIN:
-- orders_day40
-- 1 row = 1 order

-- Допустим:
-- order_id | customer_id
-- A1       | 1
-- A2       | 1

-- А order_items_day40:
-- order_id | product_id | quantity
-- A1       | 101        | 1
-- A1       | 102        | 2
-- A2       | 103        | 1

-- Здесь grain уже другой:
-- 1 row = 1 specific product inside 1 order

-- Теперь делаем:
-- FROM orders_day40 AS o
-- JOIN order_items_day40 AS oi
--     ON o.order_id = oi.order_id

-- Что произойдёт с A1?
-- В orders он был один раз:
-- A1 | customer 1

-- Но в order_items для A1 есть две подходящие строки:
-- A1 | product 101
-- A1 | product 102

-- Поэтому после JOIN SQL выдаст две строки:
-- order_id | customer_id | product_id | quantity
-- A1       | 1           | 101        | 1
-- A1       | 1           | 102        | 2
-- A2       | 1           | 103        | 1

-- Вот теперь смотри на одну строку:
-- A1 | 1 | 101 | 1

-- Она уже не означает просто:
-- заказ A1

-- Потому что A1 встречается несколько раз.
-- Она означает:
-- product 101 внутри order A1

-- Отсюда grain:
-- 1 row = 1 product inside 1 order

-- И затем мы присоединяем products:
-- JOIN products_day40 AS p
--     ON oi.product_id = p.product_id

-- Например:
-- 101 → Laptop → 1200
-- 102 → Mouse  → 50
-- 103 → Keyboard → 100

-- Получается:
-- order_id | customer_id | product_id | product_name | price | quantity
-- A1       | 1           | 101        | Laptop       | 1200  | 1
-- A1       | 1           | 102        | Mouse        | 50    | 2
-- A2       | 1           | 103        | Keyboard     | 100   | 1

-- Количество строк не увеличилось, потому что каждому product_id соответствует один продукт в products.
-- Поэтому grain остаётся:
-- 1 row = 1 product inside 1 order

-- А уже потом:
-- GROUP BY o.customer_id

-- берёт множество таких product-line строк:
-- customer 1
-- ├── A1 → Laptop
-- ├── A1 → Mouse
-- └── A2 → Keyboard

-- и схлопывает их в:
-- customer_id | total_revenue
-- 1           | ...

-- Теперь:
-- 1 row = 1 customer

-- Самый полезный способ определять grain — не смотреть только на SELECT, а спрашивать:
-- “Что означает одна строка прямо на этом этапе?”

-- И ещё один ориентир:
-- orders
-- PK: order_id
-- → 1 row = 1 order

-- order_items
-- PK: (order_id, product_id)
-- → 1 row = 1 product inside 1 order

-- orders JOIN order_items
-- → детализация опускается до более мелкой стороны
-- → 1 row = 1 product inside 1 order

-- То есть в нашем случае grain фактически задаётся самой детальной таблицей в JOIN-цепочке, пока следующий JOIN не начинает размножать строки ещё сильнее.
-- Именно поэтому COUNT(*) после такого JOIN уже считает product lines, а не orders. Это тот же самый механизм, который мы всю неделю ловили в задачах с COUNT(DISTINCT o.order_id).

SELECT
    c.customer_id,
    COUNT(*) AS metric_1,
    COUNT(o.order_id) AS metric_2
FROM customers_day40 AS c
LEFT JOIN orders_day40 AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- было тяжковато по грейнам и сложно иногда читать, что конкретно ГПТшка хочет от меня из таблиц, но думаю, что тут больше вопрос опыта.