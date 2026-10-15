DROP TABLE IF EXISTS orders_day56;

CREATE TABLE orders_day56 (
    order_id TEXT PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    status TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL
);

INSERT INTO orders_day56 (
    order_id,
    customer_id,
    status,
    amount
)
VALUES
    ('A1', 1, 'completed', 100),
    ('A2', 1, 'pending', 50),
    ('A3', 1, 'completed', 200),
    ('A4', 1, 'cancelled', 40),

    ('B1', 2, 'completed', 300),
    ('B2', 2, 'pending', 70),
    ('B3', 2, 'pending', 30),

    ('C1', 3, 'cancelled', 90),
    ('C2', 3, 'completed', 150),
    ('C3', 3, 'completed', 250),
    ('C4', 3, 'pending', 60),

    ('D1', 4, 'completed', 500),
    ('D2', 4, 'completed', 200),
    ('D3', 4, 'cancelled', 100);

SELECT *
FROM orders_day56
ORDER BY customer_id, order_id;