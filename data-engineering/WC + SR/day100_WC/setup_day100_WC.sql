
BEGIN;

CREATE TABLE wc100_orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_status TEXT NOT NULL
        CHECK (order_status IN ('PAID', 'PENDING'))
);

CREATE TABLE wc100_order_items (
    order_id INTEGER NOT NULL
        REFERENCES wc100_orders(order_id),
    item_no INTEGER NOT NULL,
    line_amount NUMERIC(12,2) NOT NULL
        CHECK (line_amount > 0),
    PRIMARY KEY (order_id, item_no)
);

CREATE TABLE wc100_payment_events (
    payment_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL
        REFERENCES wc100_orders(order_id),
    payment_amount NUMERIC(12,2) NOT NULL
        CHECK (payment_amount > 0),
    payment_status TEXT NOT NULL
        CHECK (payment_status IN (
            'CAPTURED', 'PENDING', 'FAILED'
        ))
);

INSERT INTO wc100_orders VALUES
(1101, 10, 'PAID'),
(1102, 20, 'PAID'),
(1103, 30, 'PAID'),
(1104, 40, 'PAID'),
(1105, 50, 'PENDING'),
(1106, 60, 'PAID');

INSERT INTO wc100_order_items VALUES
(1101, 1, 70.00),
(1101, 2, 30.00),
(1102, 1, 60.00),
(1103, 1, 40.00),
(1103, 2, 60.00),
(1104, 1, 80.00),
(1105, 1, 50.00);

INSERT INTO wc100_payment_events VALUES
(2001, 1101, 100.00, 'CAPTURED'),
(2002, 1101, 500.00, 'FAILED'),
(2003, 1102, 40.00, 'CAPTURED'),
(2004, 1102, 20.00, 'CAPTURED'),
(2005, 1103, 100.00, 'CAPTURED'),
(2006, 1103, 100.00, 'CAPTURED'),
(2007, 1104, 60.00, 'CAPTURED'),
(2008, 1105, 50.00, 'PENDING'),
(2009, 1106, 10.00, 'CAPTURED');

COMMIT;
