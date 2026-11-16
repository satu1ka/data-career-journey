-- Проектируем SCD Type 2 Dimension в PostgreSQL
CREATE TABLE dim_customers_scd_day88 (
    customer_sk     INTEGER PRIMARY KEY,
    customer_id     INTEGER NOT NULL,
    customer_name   TEXT NOT NULL,
    city            TEXT NOT NULL,
    valid_from      DATE NOT NULL,
    valid_to        DATE CHECK (valid_to > valid_from)
);


-- FACT_ORDERS_DAY88
-- Учебная таблица заказов для проверки Temporal JOIN.
-- Grain: одна строка = один заказ.
-- order_id — уникальный идентификатор заказа.
-- customer_id — Business Key покупателя.
-- order_date — дата покупки, по которой выбираем
-- историческую версию покупателя.

CREATE TABLE fact_orders_day88 (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    revenue NUMERIC(12, 2) NOT NULL CHECK (revenue > 0)
);

INSERT INTO fact_orders_day88 (
    order_id, customer_id, order_date, revenue
)
VALUES
    (1001, 10, '2026-02-10', 200.00),
    (1002, 10, '2026-03-01', 150.00),
    (1003, 10, '2026-03-20', 300.00),
    (1004, 10, '2026-04-01', 80.00),
    (1005, 10, '2026-04-15', 120.00);