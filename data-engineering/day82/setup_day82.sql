-- =============================================================
-- DAY 82 — DATA INTEGRITY / DATABASE CONSTRAINTS
-- PostgreSQL | учебные таблицы, отдельные от предыдущих дней
--
-- Тема: защита бизнес-правил на уровне базы данных.
-- Начальная схема содержит PRIMARY KEY и базовые NOT NULL.
-- FOREIGN KEY, UNIQUE и CHECK намеренно НЕ добавлены:
-- их предстоит спроектировать и применить в заданиях.
--
-- Безопасный повторный запуск: пересоздаёт ТОЛЬКО таблицы Day 82.
-- ВНИМАНИЕ: повторный запуск удалит изменения в этих таблицах.
-- =============================================================

BEGIN;

-- Удаляем сначала дочерние таблицы (зависимости по смыслу данных).
DROP TABLE IF EXISTS incoming_payments_day82;
DROP TABLE IF EXISTS payments_day82;
DROP TABLE IF EXISTS orders_day82;
DROP TABLE IF EXISTS customers_day82;

-- -------------------------------------------------------------
-- customers_day82 — ПОКУПАТЕЛИ / СПРАВОЧНИК ПОКУПАТЕЛЕЙ
-- Одна строка = один покупатель.
-- Grain: customer_id. PRIMARY KEY гарантирует его уникальность.
-- Связь: один покупатель может иметь несколько заказов (1:N).
-- -------------------------------------------------------------
CREATE TABLE customers_day82 (
    customer_id   BIGINT PRIMARY KEY,
    customer_name TEXT NOT NULL
);

-- -------------------------------------------------------------
-- orders_day82 — ЗАКАЗЫ
-- Одна строка = один заказ, а не отдельный товар или платёж.
-- Grain: order_id (PRIMARY KEY).
-- customer_id показывает владельца заказа (планируем FOREIGN KEY).
-- order_total — заявленная сумма заказа, а не сумма платежей.
-- -------------------------------------------------------------
CREATE TABLE orders_day82 (
    order_id     BIGINT PRIMARY KEY,
    customer_id  BIGINT NOT NULL,
    created_at   TIMESTAMP NOT NULL,
    order_total  NUMERIC(10, 2) NOT NULL,
    order_status TEXT NOT NULL
);

-- -------------------------------------------------------------
-- payments_day82 — ПЛАТЕЖИ / РЕЕСТР ПЛАТЁЖНЫХ ОПЕРАЦИЙ
-- Одна строка = одна платёжная операция.
-- Grain: payment_id (PRIMARY KEY).
-- Один заказ может иметь несколько платежей (1:N).
-- provider_reference — внешний идентификатор платёжной операции;
--   он должен быть уникальным в целевой таблице.
-- В заданиях добавим FOREIGN KEY на заказ и бизнес-проверки.
-- -------------------------------------------------------------
CREATE TABLE payments_day82 (
    payment_id         BIGINT PRIMARY KEY,
    order_id           BIGINT NOT NULL,
    provider_reference TEXT NOT NULL,
    amount             NUMERIC(10, 2) NOT NULL,
    payment_status     TEXT NOT NULL,
    paid_at            TIMESTAMP NOT NULL
);

-- -------------------------------------------------------------
-- incoming_payments_day82 — СЫРЫЕ ВХОДЯЩИЕ ПЛАТЕЖИ / RAW-STAGING
-- Одна строка = одна входящая запись от внешнего источника.
-- Grain: source_row_id, НЕ payment_id!
-- В RAW допустимы ошибочные, повторные и противоречивые записи.
-- Назначение: проверить правила и решить, что можно перенести
-- в целевой реестр payments_day82.
-- -------------------------------------------------------------
CREATE TABLE incoming_payments_day82 (
    source_row_id      BIGINT PRIMARY KEY,
    payment_id         BIGINT,
    order_id           BIGINT,
    provider_reference TEXT,
    amount             NUMERIC(10, 2),
    payment_status     TEXT,
    paid_at            TIMESTAMP
);

INSERT INTO customers_day82 (customer_id, customer_name) VALUES
    (1, 'Anna'),
    (2, 'Boris'),
    (3, 'Maria');

INSERT INTO orders_day82 (order_id, customer_id, created_at, order_total, order_status) VALUES
    (1001, 1, '2026-11-01 09:00:00', 100.00, 'completed'),
    (1002, 1, '2026-11-01 09:30:00',  75.00, 'completed'),
    (1003, 2, '2026-11-01 10:00:00', 120.00, 'processing'),
    (1004, 3, '2026-11-01 11:00:00',  50.00, 'completed');

INSERT INTO payments_day82 (
    payment_id, order_id, provider_reference, amount, payment_status, paid_at
) VALUES
    (5001, 1001, 'pay-A',  60.00, 'captured', '2026-11-01 09:05:00'),
    (5002, 1001, 'pay-B',  40.00, 'captured', '2026-11-01 09:10:00'),
    (5003, 1002, 'pay-C',  75.00, 'captured', '2026-11-01 09:35:00'),
    (5004, 1003, 'pay-D', 120.00, 'failed',   '2026-11-01 10:05:00'),
    (5005, 1004, 'pay-E',  50.00, 'captured', '2026-11-01 11:05:00');

-- Правила, которые предстоит обеспечить для целевого payments:
--  * order_id должен существовать в orders_day82;
--  * provider_reference должен быть уникальным;
--  * amount должен быть строго положительным;
--  * payment_status только: captured, failed, pending, refunded.
-- Входные записи намеренно содержат разные сценарии ошибок.
INSERT INTO incoming_payments_day82 (
    source_row_id, payment_id, order_id, provider_reference, amount, payment_status, paid_at
) VALUES
    (1, 5006, 1003, 'pay-F', 120.00, 'captured', '2026-11-02 08:00:00'), -- корректная
    (2, 5007, 9999, 'pay-G',  20.00, 'captured', '2026-11-02 08:05:00'), -- заказ отсутствует
    (3, 5008, 1002, 'pay-H', -10.00, 'captured', '2026-11-02 08:10:00'), -- отрицательная сумма
    (4, 5009, 1004, 'pay-I',  30.00, 'unknown',  '2026-11-02 08:15:00'), -- неизвестный статус
    (5, 5010, 1001, 'pay-A',  60.00, 'captured', '2026-11-02 08:20:00'), -- provider_reference уже существует
    (6, 5006, 1003, 'pay-J', 120.00, 'captured', '2026-11-02 08:25:00'), -- payment_id повторяется в RAW
    (7, 5011, 1003, 'pay-K',   0.00, 'failed',   '2026-11-02 08:30:00'), -- сумма равна нулю
    (8, 5012, 1003, NULL,     10.00, 'captured', '2026-11-02 08:35:00'), -- отсутствует внешний идентификатор
    (9, 5013, 1003, 'pay-L',  25.00, 'captured', '2026-11-02 08:40:00'); -- корректная

COMMIT;

-- Диагностика после setup (по желанию):
-- SELECT * FROM customers_day82 ORDER BY customer_id;
-- SELECT * FROM orders_day82 ORDER BY order_id;
-- SELECT * FROM payments_day82 ORDER BY payment_id;
-- SELECT * FROM incoming_payments_day82 ORDER BY source_row_id;
