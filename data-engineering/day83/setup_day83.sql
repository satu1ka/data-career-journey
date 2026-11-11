-- Day 83 — Data Modeling: Normalization & Data Anomalies
-- PostgreSQL · Учебный setup
-- Повторный запуск пересоздаёт только таблицу Day 83.

DROP TABLE IF EXISTS orders_flat_day83;

-- orders_flat_day83 / ПЛОСКАЯ ТАБЛИЦА ЗАКАЗОВ
-- Назначение: имитирует данные, пришедшие из внешнего CSV или старой системы.
-- Одна строка = ОДНА ТОВАРНАЯ ПОЗИЦИЯ заказа, а не один заказ.
-- Ключ: (order_id, item_id). Один order_id может встречаться несколько раз.
-- Информация о покупателе повторяется в разных строках.
-- Это намеренно ненормализованная учебная модель: искать аномалии будем сами.
CREATE TABLE orders_flat_day83 (
    order_id       INTEGER NOT NULL,
    order_date     DATE NOT NULL,
    customer_id    INTEGER NOT NULL,
    customer_name  TEXT NOT NULL,
    customer_city  TEXT NOT NULL,
    item_id        INTEGER NOT NULL,
    product_name   TEXT NOT NULL,
    quantity       INTEGER NOT NULL CHECK (quantity > 0),
    unit_price     NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, item_id)
);

INSERT INTO orders_flat_day83 (
    order_id, order_date, customer_id, customer_name, customer_city,
    item_id, product_name, quantity, unit_price
)
VALUES
    (1001, DATE '2026-11-01', 10, 'Anna',  'Berlin',  1, 'Keyboard',  1, 50.00),
    (1001, DATE '2026-11-01', 10, 'Anna',  'Berlin',  2, 'Mouse',     2, 20.00),
    (1002, DATE '2026-11-02', 20, 'Boris', 'Hamburg', 3, 'Monitor',   1, 180.00),
    (1003, DATE '2026-11-03', 10, 'Anna',  'Berlin',  4, 'USB-C Cable',3, 10.00),
    (1004, DATE '2026-11-04', 30, 'Maria', 'Munich',  5, 'Desk Lamp', 1, 35.00);

-- Диагностика исходного набора (можно выполнить после setup):
-- SELECT * FROM orders_flat_day83 ORDER BY order_id, item_id;
