-- =============================================================
-- DAY 81 — DATA MODELING: TABLE GRAIN & JOIN CARDINALITY
-- Учебный сценарий: интернет-магазин, заказы и платежи.
--
-- ВНИМАНИЕ: повторный запуск удаляет и пересоздаёт ТОЛЬКО
-- учебные таблицы с суффиксом _day81.
-- =============================================================

BEGIN;

-- Сначала удаляем дочерние таблицы, затем родительскую.
DROP TABLE IF EXISTS payments_day81;
DROP TABLE IF EXISTS order_items_day81;
DROP TABLE IF EXISTS orders_day81;

-- -------------------------------------------------------------
-- orders_day81 — ЗАКАЗЫ (ORDER HEADERS)
-- Назначение: общие сведения о заказе, а не о товарах или платежах.
-- Одна строка = ОДИН заказ.
-- Первичный ключ: order_id.
-- Связи: одному заказу могут соответствовать несколько позиций
-- в order_items_day81 и несколько платежей в payments_day81.
-- Важно: отсутствие позиций или платежей не удаляет заказ.
-- -------------------------------------------------------------
CREATE TABLE orders_day81 (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER NOT NULL,
    ordered_at    TIMESTAMP NOT NULL,
    order_status  TEXT NOT NULL CHECK (
        order_status IN ('placed', 'completed', 'cancelled')
    )
);

-- -------------------------------------------------------------
-- order_items_day81 — ПОЗИЦИИ ЗАКАЗА (ORDER LINE ITEMS)
-- Назначение: какие товары и в каком количестве входят в заказ.
-- Одна строка = ОДНА позиция заказа, а НЕ целый заказ.
-- Первичный ключ: item_id.
-- Внешний ключ: order_id -> orders_day81.order_id.
-- Один order_id может встречаться много раз (связь 1:N).
-- Сумма позиции = quantity * unit_price.
-- -------------------------------------------------------------
CREATE TABLE order_items_day81 (
    item_id      INTEGER PRIMARY KEY,
    order_id     INTEGER NOT NULL REFERENCES orders_day81(order_id),
    sku          TEXT NOT NULL,
    quantity     INTEGER NOT NULL CHECK (quantity > 0),
    unit_price   NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0)
);

-- -------------------------------------------------------------
-- payments_day81 — ПЛАТЕЖИ / ПОПЫТКИ ОПЛАТЫ
-- Назначение: история платежных операций по заказам.
-- Одна строка = ОДНА платежная операция, НЕ целый заказ.
-- Первичный ключ: payment_id.
-- Внешний ключ: order_id -> orders_day81.order_id.
-- Один заказ может иметь несколько платежей (связь 1:N).
-- Важно: failed — не полученные деньги; captured — успешное
-- списание. Эти статусы понадобятся в следующих заданиях.
-- -------------------------------------------------------------
CREATE TABLE payments_day81 (
    payment_id      INTEGER PRIMARY KEY,
    order_id        INTEGER NOT NULL REFERENCES orders_day81(order_id),
    amount          NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    payment_status  TEXT NOT NULL CHECK (
        payment_status IN ('captured', 'failed')
    )
);

-- Тестовые заказы.
INSERT INTO orders_day81 (order_id, customer_id, ordered_at, order_status) VALUES
    (1001, 201, '2026-11-01 09:00', 'completed'),
    (1002, 202, '2026-11-01 10:00', 'completed'),
    (1003, 201, '2026-11-02 11:00', 'completed'),
    (1004, 203, '2026-11-02 12:00', 'cancelled'),
    (1005, 204, '2026-11-03 08:00', 'placed'),
    (1006, 205, '2026-11-03 09:00', 'completed');

-- Позиции заказов: обрати внимание, что у 1001 и 1003
-- несколько позиций, а у 1005 позиций пока нет.
INSERT INTO order_items_day81 (item_id, order_id, sku, quantity, unit_price) VALUES
    (1, 1001, 'BOOK-A',   2, 30.00),
    (2, 1001, 'CABLE-B',  1, 40.00),
    (3, 1002, 'LAMP-C',   1, 75.00),
    (4, 1003, 'PEN-D',    3, 20.00),
    (5, 1003, 'CASE-E',   1, 10.00),
    (6, 1003, 'BOOK-A',   1, 30.00),
    (7, 1004, 'LAMP-C',   1, 75.00),
    (8, 1006, 'MOUSE-F',  2, 25.00);

-- Платежи: у 1001 два успешных платежа, у 1003 есть
-- неудачная попытка и последующая успешная операция;
-- у 1004 и 1005 платежей нет.
INSERT INTO payments_day81 (payment_id, order_id, amount, payment_status) VALUES
    (7001, 1001,  60.00, 'captured'),
    (7002, 1001,  40.00, 'captured'),
    (7003, 1002,  75.00, 'captured'),
    (7004, 1003, 100.00, 'failed'),
    (7005, 1003, 100.00, 'captured'),
    (7006, 1006,  20.00, 'captured'),
    (7007, 1006,  30.00, 'captured');

COMMIT;

-- Контроль объёма исходных данных (не меняет таблицы):
SELECT 'orders_day81' AS table_name, COUNT(*) AS row_count FROM orders_day81
UNION ALL
SELECT 'order_items_day81', COUNT(*) FROM order_items_day81
UNION ALL
SELECT 'payments_day81', COUNT(*) FROM payments_day81
ORDER BY table_name;
