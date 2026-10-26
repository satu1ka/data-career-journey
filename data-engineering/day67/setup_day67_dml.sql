-- Day 67 — PostgreSQL DML fundamentals practice
-- This file creates a SEPARATE training table for INSERT / UPDATE / DELETE.
-- Re-running resets only products_day67, without touching orders_raw,
-- orders_current, or orders_incoming.

DROP TABLE IF EXISTS products_day67;

CREATE TABLE products_day67 (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0)
);

INSERT INTO products_day67 (product_id, product_name, quantity, price)
VALUES
    (101, 'USB cable', 15, 9.90),
    (102, 'Keyboard',   8, 49.90),
    (103, 'Mouse',     20, 24.90);

-- Inspect the starting data.
SELECT * FROM products_day67 ORDER BY product_id;
