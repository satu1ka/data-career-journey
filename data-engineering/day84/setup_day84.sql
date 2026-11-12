-- Day 84 — Dimensional Modeling: Facts, Dimensions & Star Schema
-- PostgreSQL · Учебный setup
-- Повторный запуск пересоздаёт ТОЛЬКО четыре таблицы src_*_day84.
-- Не запускайте повторно setup после начала миграции: исходные таблицы будут пересозданы.
-- Все названия технологий и полей — на английском; объяснения таблиц — на русском.

-- Удаляем дочернюю таблицу раньше родительских, чтобы не нарушить FOREIGN KEY.
DROP TABLE IF EXISTS src_order_items_day84;
DROP TABLE IF EXISTS src_orders_day84;
DROP TABLE IF EXISTS src_products_day84;
DROP TABLE IF EXISTS src_customers_day84;

-- src_customers_day84 / ИСХОДНЫЙ СПРАВОЧНИК ПОКУПАТЕЛЕЙ
-- Назначение: хранит сведения о зарегистрированных покупателях в операционной системе.
-- Grain: ОДНА строка = ОДИН покупатель.
-- Primary Key: customer_id. Имя и город описывают покупателя, а не заказ.
CREATE TABLE src_customers_day84 (
    customer_id   INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    city          TEXT NOT NULL
);

-- src_products_day84 / ИСХОДНЫЙ КАТАЛОГ ТОВАРОВ
-- Назначение: справочная информация о продаваемых товарах.
-- Grain: ОДНА строка = ОДИН товар.
-- Primary Key: product_id.
-- catalog_price — ТЕКУЩАЯ цена в каталоге, НЕ обязательно цена продажи в прошлом.
CREATE TABLE src_products_day84 (
    product_id    INTEGER PRIMARY KEY,
    product_name  TEXT NOT NULL,
    category      TEXT NOT NULL,
    catalog_price NUMERIC(10, 2) NOT NULL CHECK (catalog_price > 0)
);

-- src_orders_day84 / ИСХОДНЫЕ ЗАКАЗЫ
-- Назначение: заголовок заказа, его покупатель, дата и бизнес-статус.
-- Grain: ОДНА строка = ОДИН заказ.
-- Primary Key: order_id.
-- Foreign Key: customer_id -> src_customers_day84(customer_id).
-- Один покупатель может иметь много заказов.
CREATE TABLE src_orders_day84 (
    order_id     INTEGER PRIMARY KEY,
    customer_id  INTEGER NOT NULL REFERENCES src_customers_day84(customer_id),
    order_date   DATE NOT NULL,
    order_status TEXT NOT NULL CHECK (order_status IN ('completed', 'pending', 'cancelled'))
);

-- src_order_items_day84 / ИСХОДНЫЕ ТОВАРНЫЕ ПОЗИЦИИ ЗАКАЗОВ
-- Назначение: фиксирует конкретный товар и количество в конкретном заказе.
-- Grain: ОДНА строка = ОДНА товарная позиция ВНУТРИ заказа.
-- Composite Primary Key: (order_id, item_id). item_id — номер позиции в заказе,
-- поэтому в разных заказах item_id может повторяться.
-- Foreign Keys: order_id -> src_orders_day84, product_id -> src_products_day84.
-- unit_price_at_order — ФАКТИЧЕСКАЯ цена одной единицы при оформлении заказа;
-- она может отличаться от текущей цены в каталоге товаров.
CREATE TABLE src_order_items_day84 (
    order_id            INTEGER NOT NULL REFERENCES src_orders_day84(order_id),
    item_id             INTEGER NOT NULL,
    product_id          INTEGER NOT NULL REFERENCES src_products_day84(product_id),
    quantity            INTEGER NOT NULL CHECK (quantity > 0),
    unit_price_at_order NUMERIC(10, 2) NOT NULL CHECK (unit_price_at_order > 0),
    PRIMARY KEY (order_id, item_id)
);

INSERT INTO src_customers_day84 (customer_id, customer_name, city) VALUES
    (1, 'Anna',  'Berlin'),
    (2, 'Boris', 'Hamburg'),
    (3, 'Maria', 'Munich'),
    (4, 'Eva',   'Berlin'),
    (5, 'Liam',  'Cologne');

INSERT INTO src_products_day84 (product_id, product_name, category, catalog_price) VALUES
    (201, 'Keyboard', 'Electronics', 60.00),
    (202, 'Mouse',    'Electronics', 20.00),
    (203, 'Monitor',  'Electronics', 220.00),
    (204, 'USB Cable','Accessories', 12.00),
    (205, 'Desk',     'Furniture',   350.00);

INSERT INTO src_orders_day84 (order_id, customer_id, order_date, order_status) VALUES
    (1001, 1, DATE '2026-11-01', 'completed'),
    (1002, 2, DATE '2026-11-02', 'completed'),
    (1003, 1, DATE '2026-11-02', 'cancelled'),
    (1004, 3, DATE '2026-11-03', 'completed'),
    (1005, 4, DATE '2026-11-04', 'pending'),
    (1006, 2, DATE '2026-11-05', 'completed'),
    (1007, 1, DATE '2026-11-06', 'completed');

INSERT INTO src_order_items_day84 (
    order_id, item_id, product_id, quantity, unit_price_at_order
) VALUES
    (1001, 1, 201, 1, 55.00),
    (1001, 2, 202, 2, 18.00),
    (1002, 1, 203, 1, 210.00),
    (1003, 1, 205, 1, 340.00),
    (1004, 1, 202, 1, 20.00),
    (1004, 2, 204, 3, 10.00),
    (1005, 1, 205, 1, 350.00),
    (1006, 1, 201, 2, 58.00),
    (1006, 2, 204, 1, 10.00),
    (1007, 1, 203, 1, 205.00),
    (1007, 2, 202, 1, 18.00);

-- Разрешённые диагностические SELECT после setup:
-- SELECT * FROM src_customers_day84 ORDER BY customer_id;
-- SELECT * FROM src_products_day84 ORDER BY product_id;
-- SELECT * FROM src_orders_day84 ORDER BY order_id;
-- SELECT * FROM src_order_items_day84 ORDER BY order_id, item_id;
--
-- Целевые аналитические таблицы dim_* и fact_* здесь НАМЕРЕННО не создаются:
-- их Grain, ключи и состав столбцов предстоит спроектировать самостоятельно.
