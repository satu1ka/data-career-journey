-- DAY 89 — тестовая SCD Type 2 Dimension
-- Одна строка = одна историческая версия покупателя.
-- customer_sk — уникальный ключ версии.
-- customer_id — бизнес-ключ покупателя.
-- Данные намеренно содержат пересекающиеся интервалы.

DROP TABLE IF EXISTS dim_customers_scd_day89_test;

CREATE TABLE dim_customers_scd_day89_test (
    customer_sk INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    city TEXT NOT NULL,
    valid_from DATE NOT NULL,
    valid_to DATE,
    CHECK (valid_to > valid_from)
);

INSERT INTO dim_customers_scd_day89_test
    (customer_sk, customer_id, city, valid_from, valid_to)
VALUES
    (101, 10, 'Berlin',  '2026-01-01', '2026-03-01'),
    (102, 10, 'Hamburg', '2026-03-01', '2026-04-01'),
    (103, 10, 'Munich',  '2026-04-01', NULL),
    (104, 10, 'Bremen',  '2026-03-20', '2026-04-15');

-- customer_id = 20
-- Две исторические версии одного покупателя.
-- Между ними намеренно оставлен разрыв.

INSERT INTO dim_customers_scd_day89_test (
    customer_sk,
    customer_id,
    city,
    valid_from,
    valid_to
)
VALUES
    (201, 20, 'Berlin',  DATE '2026-01-01', DATE '2026-03-01'),
    (202, 20, 'Munich',  DATE '2026-03-10', NULL);