DROP TABLE IF EXISTS orders_day39;
DROP TABLE IF EXISTS customers_day39;

CREATE TABLE customers_day39 (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE orders_day39 (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id INTEGER REFERENCES customers_day39(customer_id),
    amount NUMERIC(10, 2),
    status VARCHAR(20)
);

INSERT INTO customers_day39 (
    customer_id,
    customer_name,
    city
)
VALUES
    (1, 'Anna', 'Berlin'),
    (2, 'Mark', 'London'),
    (3, 'John', 'Paris'),
    (4, 'Kate', 'Berlin');

INSERT INTO orders_day39 (
    order_id,
    customer_id,
    amount,
    status
)
VALUES
    ('A1', 1, 120.00, 'completed'),
    ('A2', 1, 300.00, 'completed'),
    ('A3', 2, 80.00, 'pending'),
    ('A4', 4, 450.00, 'completed'),
    ('A5', 2, 200.00, 'completed');