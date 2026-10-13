DROP TABLE IF EXISTS orders_day54;

CREATE TABLE orders_day54 (
    order_id TEXT PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    created_at DATE NOT NULL
);

INSERT INTO orders_day54 (
    order_id,
    customer_id,
    amount,
    created_at
)
VALUES
    ('A1', 1, 100, '2026-10-01'),
    ('A2', 1, 250, '2026-10-03'),
    ('A3', 1, 150, '2026-10-05'),
    ('A4', 1, 250, '2026-10-08'),

    ('B1', 2, 300, '2026-10-02'),
    ('B2', 2, 200, '2026-10-04'),
    ('B3', 2, 500, '2026-10-07'),
    ('B4', 2, 100, '2026-10-10'),

    ('C1', 3, 90,  '2026-10-01'),
    ('C2', 3, 120, '2026-10-06'),
    ('C3', 3, 120, '2026-10-09'),

    ('D1', 4, 800, '2026-10-02'),
    ('D2', 4, 400, '2026-10-05'),
    ('D3', 4, 600, '2026-10-08'),
    ('D4', 4, 200, '2026-10-11');

SELECT *
FROM orders_day54
ORDER BY customer_id, created_at;