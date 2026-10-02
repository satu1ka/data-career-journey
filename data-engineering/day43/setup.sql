DROP TABLE IF EXISTS order_items_day40;
DROP TABLE IF EXISTS orders_day40;
DROP TABLE IF EXISTS products_day40;
DROP TABLE IF EXISTS customers_day40;

CREATE TABLE customers_day40 (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE products_day40 (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price NUMERIC(10, 2)
);

CREATE TABLE orders_day40 (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id INTEGER REFERENCES customers_day40(customer_id),
    status VARCHAR(20)
);

CREATE TABLE order_items_day40 (
    order_id VARCHAR(10) REFERENCES orders_day40(order_id),
    product_id INTEGER REFERENCES products_day40(product_id),
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id)
);

INSERT INTO customers_day40 VALUES
    (1, 'Anna', 'Berlin'),
    (2, 'Mark', 'London'),
    (3, 'John', 'Paris'),
    (4, 'Kate', 'Berlin');

INSERT INTO products_day40 VALUES
    (101, 'Laptop', 'Electronics', 1200.00),
    (102, 'Mouse', 'Electronics', 50.00),
    (103, 'Keyboard', 'Electronics', 100.00),
    (104, 'Desk', 'Furniture', 400.00);

INSERT INTO orders_day40 VALUES
    ('A1', 1, 'completed'),
    ('A2', 1, 'completed'),
    ('A3', 2, 'pending'),
    ('A4', 4, 'completed');

INSERT INTO order_items_day40 VALUES
    ('A1', 101, 1),
    ('A1', 102, 2),
    ('A2', 103, 1),
    ('A2', 102, 1),
    ('A3', 104, 1),
    ('A4', 102, 3),
    ('A4', 103, 2);