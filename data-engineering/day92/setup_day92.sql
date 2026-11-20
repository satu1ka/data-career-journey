-- DAY 92 — SCD Type 2 Dimension.
-- Grain: одна строка = одна историческая версия покупателя.
-- customer_sk — уникальный Surrogate Key версии, создаётся PostgreSQL.
-- customer_id — Business Key, повторяется между историческими версиями.
-- valid_to IS NULL — активная версия покупателя.

DROP TABLE IF EXISTS dim_customers_scd_day92;

CREATE TABLE dim_customers_scd_day92 (
    customer_sk BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    customer_name TEXT NOT NULL,
    city TEXT NOT NULL,
    valid_from DATE NOT NULL,
    valid_to DATE,
    CHECK (valid_to > valid_from)
);

INSERT INTO dim_customers_scd_day92 (
    customer_id,
    customer_name,
    city,
    valid_from,
    valid_to
)
VALUES
    (10, 'Anna', 'Berlin', '2026-01-01', NULL),
    (20, 'Boris', 'Berlin', '2026-01-01', '2026-04-01'),
    (20, 'Boris', 'Hamburg', '2026-04-01', NULL),
    (30, 'Vera', 'Munich', '2026-01-15', NULL),
    (50, 'Max', 'Berlin', '2026-01-01', '2026-03-01');

-- Ограничение: максимум одна активная версия на customer_id.
CREATE UNIQUE INDEX uq_dim_customers_day92_active
ON dim_customers_scd_day92 (customer_id)
WHERE valid_to IS NULL;

-- DAY 92 — Source Snapshot.
-- Grain: одна строка = текущее состояние одного покупателя.
-- customer_id — Primary Key.
-- Снимок содержит данные, полученные из Source System.

DROP TABLE IF EXISTS stg_customers_day92;

CREATE TABLE stg_customers_day92 (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    city TEXT NOT NULL
);

INSERT INTO stg_customers_day92 (
    customer_id,
    customer_name,
    city
)
VALUES
    (10, 'Anna', 'Berlin'),
    (20, 'Boris', 'Frankfurt'),
    (40, 'Olga', 'Cologne'),
    (50, 'Max', 'Munich');