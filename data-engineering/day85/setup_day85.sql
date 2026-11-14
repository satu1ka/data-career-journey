-- It was created yesterday, but this just showcase, for easier understanding

-- CREATE TABLE dim_customers_day84 (
--     customer_id   INTEGER PRIMARY KEY,
--     customer_name TEXT NOT NULL,
--     city          TEXT NOT NULL
-- );

-- CREATE TABLE dim_products_day84 (
--     product_id    INTEGER PRIMARY KEY,
--     product_name  TEXT NOT NULL,
--     category      TEXT NOT NULL,
--     catalog_price NUMERIC(10, 2) NOT NULL CHECK (catalog_price > 0)
-- );

-- CREATE TABLE fact_sales_day84 (
--     order_id            INTEGER NOT NULL,
--     item_id             INTEGER NOT NULL,
--     product_id          INTEGER NOT NULL REFERENCES dim_products_day84(product_id),
--     quantity            INTEGER NOT NULL CHECK (quantity > 0),
--     unit_price_at_order NUMERIC(10, 2) NOT NULL CHECK (unit_price_at_order > 0),
--     customer_id         INTEGER NOT NULL REFERENCES dim_customers_day84(customer_id),
--     order_date          DATE NOT NULL,
--     order_status        TEXT NOT NULL CHECK (order_status IN ('completed', 'pending', 'cancelled')),
--     line_amount         NUMERIC(12,2) NOT NULL CHECK (line_amount = quantity * unit_price_at_order),
--     PRIMARY KEY (order_id, item_id)
-- );