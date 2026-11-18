-- Историческая Dimension покупателей для Day 90.
-- Одна строка = одна историческая версия покупателя.
-- customer_sk — уникальный Surrogate Key версии.
-- customer_id — Business Key покупателя.
-- valid_to IS NULL означает текущую открытую версию.

DROP TABLE IF EXISTS dim_customers_scd_day90;

CREATE TABLE dim_customers_scd_day90 (
    customer_sk INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    customer_name TEXT NOT NULL,
    city TEXT NOT NULL,
    valid_from DATE NOT NULL,
    valid_to DATE,
    CHECK (valid_to > valid_from)
);

INSERT INTO dim_customers_scd_day90
    (customer_sk, customer_id, customer_name, city, valid_from, valid_to)
VALUES
    (101, 10, 'Anna',  'Berlin',  '2026-01-01', NULL),
    (201, 20, 'Boris', 'Berlin',  '2026-01-01', '2026-04-01'),
    (202, 20, 'Boris', 'Hamburg', '2026-04-01', NULL),
    (301, 30, 'Vera',  'Munich',  '2026-01-15', NULL);

-- Новый снимок данных покупателей из Source System.
-- Одна строка = актуальное состояние одного покупателя.
-- customer_id — уникальный Business Key.
-- Дата загрузки для упражнения: 2026-05-01.

DROP TABLE IF EXISTS stg_customers_day90;

CREATE TABLE stg_customers_day90 (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    city TEXT NOT NULL
);

INSERT INTO stg_customers_day90
    (customer_id, customer_name, city)
VALUES
    (10, 'Anna',  'Berlin'),
    (20, 'Boris', 'Frankfurt'),
    (40, 'Olga',  'Cologne');

-- Закрытая историческая версия покупателя 50.
-- Активной версии для этого Business Key нет.
INSERT INTO dim_customers_scd_day90 (
    customer_sk,
    customer_id,
    customer_name,
    city,
    valid_from,
    valid_to
)
VALUES (
    501, 50, 'Max', 'Berlin',
    DATE '2026-01-01',
    DATE '2026-03-01'
);

-- Покупатель 50 вновь присутствует в Source Snapshot.
-- Одна строка = актуальное состояние покупателя.

INSERT INTO stg_customers_day90 (
    customer_id,
    customer_name,
    city
)
VALUES (50, 'Max', 'Munich');