-- Data Integrity (целостность данных)
-- Database Constraints:
-- Constraint	Что защищает
-- PRIMARY KEY	Уникальность и наличие идентификатора строки
-- FOREIGN KEY	Существование связанной записи
-- UNIQUE	Отсутствие повторяющихся значений ключа
-- CHECK	Соблюдение бизнес-условий
-- NOT NULL	Обязательное наличие значения

-- Quest 1 — Database Schema Review
-- почекали, вроде понятно

-- -- Quest 2 — Реализуем Database Constraints
-- ALTER TABLE orders_day82
-- ADD CONSTRAINT exist_customer
-- FOREIGN KEY (customer_id)
-- REFERENCES customers_day82(customer_id);

-- ALTER TABLE payments_day82
-- ADD CONSTRAINT exist_order_id 
-- FOREIGN KEY (order_id)
-- REFERENCES orders_day82(order_id);

-- -- Проверочный инсерт, чтобы удостовериться, что констрейты работают:
-- INSERT INTO payments_day82 (
--     payment_id,
--     order_id,
--     provider_reference,
--     amount,
--     payment_status,
--     paid_at
-- )
-- VALUES (
--     6001,
--     9999,
--     'pay-X',
--     50.00,
--     'captured',
--     CURRENT_TIMESTAMP
-- );

-- -- Quest 2.2 — UNIQUE Constraint
-- ALTER TABLE payments_day82
-- ADD CONSTRAINT unique_provider_reference
-- UNIQUE (provider_reference);

-- INSERT INTO payments_day82 (
--     payment_id,
--     order_id,
--     provider_reference,
--     amount,
--     payment_status,
--     paid_at
-- )
-- VALUES (
--     5006,
--     1001,
--     'pay-N',
--     35.0,
--     'captured',
--     CURRENT_TIMESTAMP
-- );

-- INSERT INTO payments_day82 (
--     payment_id,
--     order_id,
--     provider_reference,
--     amount,
--     payment_status,
--     paid_at
-- )
-- VALUES (
--     5007,
--     1001,
--     'pay-N',
--     35.0,
--     'captured',
--     CURRENT_TIMESTAMP
-- );

-- -- Quest 2.4 — CHECK Constraint
-- ALTER TABLE payments_day82
-- ADD CONSTRAINT positive_payment_amount
-- CHECK (amount > 0);

-- ALTER TABLE payments_day82
-- ADD CONSTRAINT valid_payment_status
-- CHECK (payment_status IN ('pending', 'captured', 'failed', 'refunded'));

-- -- Quest 3 — Data Integrity Testing
-- SELECT
--     payment_id,
--     order_id,
--     provider_reference
-- FROM payments_day82
-- WHERE payment_id IN (5006, 5007)
--    OR provider_reference IN ('pay-F', 'pay-N', 'pay-A')
-- ORDER BY payment_id;

-- -- Quest 3.5 — Найдём конфликты через SQL и тут же дальше
-- WITH conflicted_payment_id AS (
--     SELECT
--         payment_id,
--         COUNT(*) AS records_count
--     FROM incoming_payments_day82
--     GROUP BY payment_id
-- )

-- SELECT
--     ip.source_row_id,
--     ip.payment_id,
--     ip.provider_reference,
--     ip.amount
-- FROM incoming_payments_day82 AS ip
-- LEFT JOIN conflicted_payment_id AS cp
-- ON ip.payment_id = cp.payment_id
-- WHERE cp.records_count > 1;

-- -- Quest 4 — Data Quality: обнаруживаем нарушения до INSERT
-- SELECT
--     ip.source_row_id,
--     ip.payment_id,
--     ip.order_id,
--     'INVALID_ORDER_ID' AS error_reason
-- FROM incoming_payments_day82 AS ip
-- LEFT JOIN orders_day82 AS o
-- ON ip.order_id = o.order_id
-- WHERE o.order_id IS NULL;

-- -- Quest 4.2 — Проверяем бизнес-правила платежей
-- WITH errors_in_payments AS (
--     SELECT
--         source_row_id,
--         payment_id,
--         amount,
--         payment_status,
--         CASE
--             WHEN amount <= 0 
--                 OR amount IS NULL THEN 'INVALID_AMOUNT'
--             WHEN payment_status NOT IN ('pending', 'captured', 'failed', 'refunded')
--                 OR payment_status IS NULL THEN 'INVALID_STATUS'
--         END AS error_reason
--     FROM incoming_payments_day82
-- )
-- SELECT
--     source_row_id,
--     payment_id,
--     amount,
--     payment_status,
--     error_reason
-- FROM errors_in_payments
-- WHERE error_reason IS NOT NULL;

-- Quest 4.3 — Финальная Data Quality диагностика
SELECT
    ip.source_row_id,
    ip.payment_id,
    ip.provider_reference,
    CASE
        WHEN p.payment_id IS NOT NULL 
            THEN 'DUPLICATE_PAYMENT_ID'
        WHEN pd.provider_reference IS NOT NULL 
            THEN 'DUPLICATE_PROVIDER_REFERENCE'
    END AS error_reason
FROM incoming_payments_day82 AS ip
LEFT JOIN payments_day82 AS p
ON ip.payment_id = p.payment_id
LEFT JOIN payments_day82 AS pd
ON ip.provider_reference = pd.provider_reference
WHERE p.payment_id IS NOT NULL 
OR pd.provider_reference IS NOT NULL;
