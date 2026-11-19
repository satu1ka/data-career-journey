-- DAY 91 — Sales Analytics Practice
-- Таблица содержит позиции заказов интернет-магазина.
-- Grain: одна строка = одна товарная позиция заказа.
-- line_id — Primary Key, уникальный идентификатор позиции.
-- order_id — идентификатор заказа; может повторяться.
-- Один заказ может содержать несколько товаров.
-- status — статус всего заказа.
-- Выручка по позиции рассчитывается как quantity * unit_price.

DROP TABLE IF EXISTS sales_day91;

CREATE TABLE sales_day91 (
    line_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    city TEXT NOT NULL,
    category TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    status TEXT NOT NULL
        CHECK (status IN ('completed', 'cancelled'))
);

INSERT INTO sales_day91 VALUES
(1, 1001, 10, '2026-11-11', 'Berlin',  'Electronics', 1, 300, 'completed'),
(2, 1001, 10, '2026-11-11', 'Berlin',  'Books',       2, 25,  'completed'),
(3, 1002, 20, '2026-11-11', 'Hamburg', 'Home',        1, 80,  'completed'),
(4, 1003, 30, '2026-11-11', 'Munich',  'Books',       1, 40,  'cancelled'),
(5, 1004, 10, '2026-11-12', 'Berlin',  'Books',       2, 30,  'completed'),
(6, 1004, 10, '2026-11-12', 'Berlin',  'Electronics', 1, 200, 'completed'),
(7, 1005, 30, '2026-11-12', 'Munich',  'Home',        1, 120, 'completed'),
(8, 1005, 30, '2026-11-12', 'Munich',  'Books',       2, 20,  'completed'),
(9, 1006, 40, '2026-11-12', 'Berlin',  'Electronics', 1, 150, 'cancelled'),
(10,1007, 20, '2026-11-12', 'Hamburg', 'Electronics', 1, 500, 'completed'),
(11,1008, 50, '2026-11-13', 'Hamburg', 'Books',       1, 35,  'completed'),
(12,1008, 50, '2026-11-13', 'Hamburg', 'Home',        2, 50,  'completed'),
(13,1009, 30, '2026-11-13', 'Munich',  'Electronics', 1, 250, 'completed'),
(14,1009, 30, '2026-11-13', 'Munich',  'Books',       1, 25,  'completed'),
(15,1010, 40, '2026-11-13', 'Berlin',  'Home',        2, 60,  'completed'),
(16,1011, 60, '2026-11-13', 'Munich',  'Books',       3, 15,  'completed'),
(17,1012, 20, '2026-11-13', 'Hamburg', 'Home',        1, 100, 'completed'),
(18,1013, 40, '2026-11-11', 'Berlin',  'Books',       1, 30,  'completed'),
(19,1014, 50, '2026-11-12', 'Hamburg', 'Books',       2, 35,  'cancelled'),
(20,1015, 60, '2026-11-11', 'Munich',  'Electronics', 1, 200, 'completed');