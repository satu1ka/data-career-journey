-- Quest 4
-- SELECT
--     CAST('C102' AS VARCHAR),
--     CAST('15.5' AS NUMERIC),
--     CAST('7' AS INTEGER),
--     CAST('2026-10-08 14:35:20' AS TIMESTAMP),
--     CAST('true' AS BOOLEAN)

-- -- Quest 5 — маленький DE-кейс
-- SELECT
--     order_id,
--     CAST(price AS NUMERIC) AS price,
--     CAST(quantity AS INTEGER) AS quantity,
--     CAST(created_at AS TIMESTAMP) AS created_at,
--     CAST(price AS NUMERIC) * CAST(quantity AS INTEGER) AS revenue
-- FROM staging_orders;

-- ============================================================
-- COMMON SQL DATA TYPES (PostgreSQL)
-- ============================================================

-- INTEGER / INT
-- Whole numbers.
-- Example: quantity, age, count
-- 42

-- BIGINT
-- Large whole numbers.
-- Used when INTEGER range may be too small.
-- Example: very large IDs, counters

-- NUMERIC / DECIMAL
-- Exact decimal numbers.
-- Good for money, prices, financial calculations.
-- Example:
-- NUMERIC(10, 2)
-- 12345678.90
--
-- (10, 2):
-- 10 = total number of digits
-- 2  = digits after decimal point

-- REAL
-- Approximate floating-point number.
-- Less precision than DOUBLE PRECISION.
-- Usually not preferred for money.

-- DOUBLE PRECISION
-- Approximate floating-point number with higher precision.
-- Useful for measurements, scientific calculations, etc.

-- VARCHAR(n)
-- Variable-length text with maximum length n.
-- Example:
-- VARCHAR(100)

-- VARCHAR
-- Variable-length text without an explicit limit.

-- TEXT
-- Variable-length text.
-- Very common in PostgreSQL.

-- CHAR(n)
-- Fixed-length text.
-- Usually less common than VARCHAR/TEXT.

-- BOOLEAN
-- TRUE / FALSE
-- Can also be NULL.

-- DATE
-- Calendar date only.
-- Example:
-- 2026-10-08

-- TIME
-- Time of day only.
-- Example:
-- 14:35:20

-- TIMESTAMP
-- Date + time.
-- Example:
-- 2026-10-08 14:35:20

-- TIMESTAMPTZ
-- TIMESTAMP WITH TIME ZONE.
-- Useful when timestamps represent real moments in time
-- across different time zones.

-- INTERVAL
-- Duration / time interval.
-- Example:
-- '2 days'
-- '3 hours'

-- UUID
-- Universally unique identifier.
-- Example:
-- 550e8400-e29b-41d4-a716-446655440000

-- JSON
-- Stores JSON data.

-- JSONB
-- PostgreSQL binary JSON format.
-- Usually preferred over JSON when data needs to be
-- searched, indexed, or manipulated.

-- NULL
-- Not a data type.
-- Represents missing / unknown value.