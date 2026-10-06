DROP TABLE IF EXISTS sales_day46;
DROP TABLE IF EXISTS dates_day46;
DROP TABLE IF EXISTS stores_day46;

CREATE TABLE dates_day46 (
    date DATE PRIMARY KEY
);

CREATE TABLE stores_day46 (
    store VARCHAR(50) PRIMARY KEY
);

CREATE TABLE sales_day46 (
    date DATE,
    store VARCHAR(50),
    revenue NUMERIC(10, 2),
    PRIMARY KEY (date, store),
    FOREIGN KEY (date) REFERENCES dates_day46(date),
    FOREIGN KEY (store) REFERENCES stores_day46(store)
);

INSERT INTO dates_day46 (date)
VALUES
    ('2026-10-01'),
    ('2026-10-02');

INSERT INTO stores_day46 (store)
VALUES
    ('Store_A'),
    ('Store_B');

INSERT INTO sales_day46 (date, store, revenue)
VALUES
    ('2026-10-01', 'Store_A', 100),
    ('2026-10-02', 'Store_B', 250);