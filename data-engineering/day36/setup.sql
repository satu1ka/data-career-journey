CREATE TABLE orders_day36 (
    order_id VARCHAR(10),
    product VARCHAR(50),
    category VARCHAR(50),
    price NUMERIC(10, 2),
    quantity INTEGER,
    status VARCHAR(20),
    store VARCHAR(20),
    created_at TIMESTAMP,
    shipped_at TIMESTAMP,
    promo_code VARCHAR(20)
);

INSERT INTO orders_day36 (
    order_id,
    product,
    category,
    price,
    quantity,
    status,
    store,
    created_at,
    shipped_at,
    promo_code
)
VALUES
    ('A1', 'Laptop', 'Electronics', 1200.00, 1, 'completed', 'Store_A',
     '2026-09-20 10:15:00', '2026-09-21 09:00:00', 'TECH10'),

    ('A2', 'Mouse', 'Electronics', 50.00, 2, 'completed', 'Store_A',
     '2026-09-20 14:30:00', '2026-09-21 11:20:00', NULL),

    ('A3', 'Desk', 'Furniture', 400.00, 1, 'pending', 'Store_B',
     '2026-09-21 09:20:00', NULL, NULL),

    ('A4', 'Keyboard', 'Electronics', 100.00, 3, 'completed', 'Store_B',
     '2026-09-21 16:45:00', '2026-09-22 10:10:00', 'SALE20'),

    ('A5', 'Chair', 'Furniture', 250.00, 2, 'cancelled', 'Store_A',
     '2026-09-22 11:10:00', NULL, NULL),

    ('A6', 'Monitor', 'Electronics', 350.00, 2, 'completed', 'Store_A',
     '2026-09-22 18:25:00', '2026-09-23 15:00:00', NULL);