-- DAY 93 — Историческая Dimension покупателей.
-- Grain: одна строка = одна историческая версия покупателя.
-- customer_sk — Primary Key исторической версии.
-- customer_id — Business Key покупателя.
-- Интервалы полуоткрытые: [valid_from, valid_to).
-- NULL в valid_to означает открытую историческую версию.
-- Тестовые данные намеренно содержат проблему качества истории.

DROP TABLE IF EXISTS dim_customers_day93;

CREATE TABLE dim_customers_day93 (
    customer_sk INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    city TEXT NOT NULL,
    valid_from DATE NOT NULL,
    valid_to DATE,
    CHECK (valid_to > valid_from)
);

INSERT INTO dim_customers_day93 VALUES
(101, 10, 'Berlin',    '2026-01-01', '2026-03-01'),
(102, 10, 'Hamburg',   '2026-03-01', NULL),

(201, 20, 'Munich',    '2026-01-01', '2026-04-01'),
(202, 20, 'Frankfurt', '2026-04-01', NULL),

(301, 30, 'Cologne',   '2026-01-01', NULL),

(401, 40, 'Berlin',    '2026-01-01', '2026-03-10'),
(402, 40, 'Hamburg',   '2026-03-20', NULL);

-- DAY 93 — Fact-таблица заказов.
-- Grain: одна строка = один заказ.
-- order_id — Primary Key заказа.
-- customer_id — Business Key покупателя.
-- revenue — стоимость заказа.
-- status — completed или cancelled.
-- Данные содержат заказы, требующие проверки
-- исторического соответствия с Dimension.

DROP TABLE IF EXISTS fact_orders_day93;

CREATE TABLE fact_orders_day93 (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    revenue NUMERIC(12,2) NOT NULL CHECK (revenue > 0),
    status TEXT NOT NULL
        CHECK (status IN ('completed', 'cancelled'))
);

INSERT INTO fact_orders_day93 VALUES
(1001, 10, '2026-02-10', 120, 'completed'),
(1002, 10, '2026-03-01', 180, 'completed'),
(1003, 10, '2026-03-10',  50, 'cancelled'),

(1004, 20, '2026-03-25', 200, 'completed'),
(1005, 20, '2026-04-01', 100, 'completed'),

(1006, 30, '2026-04-10',  70, 'completed'),

(1007, 40, '2026-03-15',  90, 'completed'),
(1008, 40, '2026-03-22', 110, 'completed'),

(1009, 99, '2026-04-08',  60, 'completed'),

(1010, 20, '2026-04-12',  80, 'cancelled'),
(1011, 30, '2026-04-12', 130, 'completed'),
(1012, 10, '2026-04-25', 210, 'completed');