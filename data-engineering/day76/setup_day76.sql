
-- Day 76 — SQL Practice Dataset

DROP TABLE IF EXISTS practice_orders_day76;
DROP TABLE IF EXISTS practice_customers_day76;

CREATE TABLE practice_customers_day76 (
    customer_id INT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    city TEXT,
    registered_at DATE NOT NULL
);

CREATE TABLE practice_orders_day76 (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL
        REFERENCES practice_customers_day76(customer_id),
    order_date DATE NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    status TEXT NOT NULL,
    channel TEXT NOT NULL
);

INSERT INTO practice_customers_day76
    (customer_id, customer_name, city, registered_at)
VALUES
    (1, 'Alex', 'Berlin', '2026-08-12'),
    (2, 'Maria', 'Hamburg', '2026-09-03'),
    (3, 'John', 'Berlin', '2026-09-15'),
    (4, 'Anna', 'Munich', '2026-08-28'),
    (5, 'David', 'Hamburg', '2026-10-01'),
    (6, 'Sofia', 'Berlin', '2026-07-19'),
    (7, 'Max', 'Cologne', '2026-10-10'),
    (8, 'Emma', 'Munich', '2026-09-21'),
    (9, 'Daniel', NULL, '2026-10-25');

INSERT INTO practice_orders_day76
    (order_id, customer_id, order_date, amount, status, channel)
VALUES
    (1001, 1, '2026-10-01', 120.00, 'completed', 'web'),
    (1002, 1, '2026-10-05', 45.00, 'cancelled', 'app'),
    (1003, 1, '2026-10-20', 210.00, 'completed', 'app'),
    (1004, 2, '2026-10-04', 85.00, 'completed', 'web'),
    (1005, 2, '2026-10-09', 130.00, 'pending', 'app'),
    (1006, 2, '2026-11-01', 65.00, 'completed', 'web'),
    (1007, 3, '2026-10-03', 300.00, 'cancelled', 'web'),
    (1008, 3, '2026-10-27', 165.00, 'completed', 'app'),
    (1009, 4, '2026-10-11', 220.00, 'completed', 'web'),
    (1010, 4, '2026-10-12', 220.00, 'completed', 'app'),
    (1011, 4, '2026-11-02', 40.00, 'pending', 'app'),
    (1012, 5, '2026-10-14', 95.00, 'cancelled', 'web'),
    (1013, 5, '2026-10-23', 75.00, 'completed', 'web'),
    (1014, 6, '2026-10-17', 500.00, 'completed', 'app'),
    (1015, 6, '2026-10-31', 60.00, 'pending', 'web'),
    (1016, 8, '2026-10-18', 110.00, 'completed', 'web'),
    (1017, 8, '2026-10-24', 110.00, 'completed', 'app'),
    (1018, 8, '2026-11-03', 35.00, 'cancelled', 'web'),
    (1019, 9, '2026-11-01', 140.00, 'completed', 'app'),
    (1020, 2, '2026-11-03', 260.00, 'completed', 'app');
