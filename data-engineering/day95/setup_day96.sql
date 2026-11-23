-- DAY 95 — Source Orders.
-- Grain: одна строка = один заказ из Source System.
-- order_id — Primary Key.
-- order_date — дата совершения заказа.
-- ingested_at — время поступления записи в Source/Staging.
-- Эти две даты могут отличаться.

DROP TABLE IF EXISTS source_orders_day95;

CREATE TABLE source_orders_day95 (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    revenue NUMERIC(12,2) NOT NULL CHECK (revenue > 0),
    ingested_at TIMESTAMPTZ NOT NULL
);

INSERT INTO source_orders_day95 VALUES
(1001, 10, '2026-11-18', 120, '2026-11-20 08:30:00+00'),
(1002, 20, '2026-11-19',  80, '2026-11-20 09:20:00+00'),
(1003, 30, '2026-11-20', 200, '2026-11-20 10:00:00+00'),
(1004, 10, '2026-11-20',  50, '2026-11-20 10:01:00+00'),
(1005, 40, '2026-11-21', 110, '2026-11-21 07:30:00+00'),
(1006, 50, '2026-11-18',  95, '2026-11-21 08:20:00+00'),
(1007, 20, '2026-11-21', 160, '2026-11-21 09:00:00+00'),
(1008, 30, '2026-11-21',  70, '2026-11-21 09:00:00+00'),
(1009, 10, '2026-11-21',  40, '2026-11-21 09:15:00+00'),
(1010, 60, '2026-11-22', 220, '2026-11-22 12:00:00+00');


-- DAY 95 — Target Fact Orders.
-- Grain: одна строка = один загруженный заказ.
-- order_id — Primary Key.
-- Первые три заказа уже были обработаны Pipeline.

DROP TABLE IF EXISTS fact_orders_day95;

CREATE TABLE fact_orders_day95 (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    revenue NUMERIC(12,2) NOT NULL,
    ingested_at TIMESTAMPTZ NOT NULL
);

INSERT INTO fact_orders_day95 VALUES
(1001, 10, '2026-11-18', 120, '2026-11-20 08:30:00+00'),
(1002, 20, '2026-11-19',  80, '2026-11-20 09:20:00+00'),
(1003, 30, '2026-11-20', 200, '2026-11-20 10:00:00+00');


-- DAY 95 — Pipeline State.
-- Grain: одна строка = состояние одного Pipeline.
-- pipeline_name — Primary Key.
-- last_successful_ingested_at — последняя успешно
-- обработанная временная граница.

DROP TABLE IF EXISTS pipeline_state_day95;

CREATE TABLE pipeline_state_day95 (
    pipeline_name TEXT PRIMARY KEY,
    last_successful_ingested_at TIMESTAMPTZ NOT NULL
);

INSERT INTO pipeline_state_day95 VALUES
('orders_incremental', '2026-11-20 10:00:00+00');