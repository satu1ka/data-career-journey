-- -- Quest 1 — Financial Reconciliation
-- WITH items_total AS (
--     SELECT
--         order_id,
--         SUM(line_amount) AS items_total
--     FROM wc100_order_items
--     GROUP BY order_id
-- ),
-- captured_total AS (
--     SELECT 
--         order_id,
--         SUM(payment_amount) AS captured_total
--     FROM wc100_payment_events
--     WHERE payment_status = 'CAPTURED'
--     GROUP BY order_id
-- ),
-- total_calculation AS (
--     SELECT
--         o.order_id,
--         it.items_total,
--         ct.captured_total
--     FROM wc100_orders AS o
--     LEFT JOIN items_total AS it
--         ON o.order_id = it.order_id
--     LEFT JOIN captured_total AS ct
--         ON o.order_id = ct.order_id
--     WHERE o.order_status = 'PAID'
-- )
-- SELECT 
--     order_id,
--     items_total,
--     captured_total,
--     CASE
--         WHEN items_total IS NOT DISTINCT FROM captured_total 
--         AND (
--             items_total IS NOT NULL
--             OR captured_total IS NOT NULL
--         ) THEN 'MATCH'
--         ELSE 'MISMATCH'
--     END AS reconciliation_status
-- FROM total_calculation
-- ORDER BY order_id;

-- -- Quest 2: Incident Classification
-- CREATE OR REPLACE VIEW wc100_financial_audit_v AS
-- WITH items_total AS (
--     SELECT
--         order_id,
--         SUM(line_amount) AS items_total
--     FROM wc100_order_items
--     GROUP BY order_id
-- ),
-- captured_total AS (
--     SELECT 
--         order_id,
--         SUM(payment_amount) AS captured_total
--     FROM wc100_payment_events
--     WHERE payment_status = 'CAPTURED'
--     GROUP BY order_id
-- ),
-- total_calculation AS (
--     SELECT
--         o.order_id,
--         it.items_total,
--         ct.captured_total
--     FROM wc100_orders AS o
--     LEFT JOIN items_total AS it
--         ON o.order_id = it.order_id
--     LEFT JOIN captured_total AS ct
--         ON o.order_id = ct.order_id
--     WHERE o.order_status = 'PAID'
-- ),
-- reconciliation_status AS ( 
--     SELECT
--         order_id,
--         items_total,
--         captured_total,
--         CASE
--             WHEN items_total IS NOT DISTINCT FROM captured_total 
--             AND (
--                 items_total IS NOT NULL
--                 OR captured_total IS NOT NULL
--             ) THEN 'MATCH'
--             ELSE 'MISMATCH'
--         END AS reconciliation_status
--     FROM total_calculation
-- )
-- SELECT
--     order_id,
--     items_total,
--     captured_total,
--     reconciliation_status,
--     CASE
--         WHEN reconciliation_status = 'MATCH' THEN 'MATCH'
--         WHEN items_total IS NULL THEN 'MISSING_ITEMS'
--         WHEN captured_total IS NULL THEN 'MISSING_PAYMENT'
--         WHEN captured_total < items_total THEN 'UNDERPAID'
--         WHEN captured_total > items_total THEN 'OVERPAID'
--     END AS incident_type
-- FROM reconciliation_status;

-- BEGIN;

-- INSERT INTO wc100_orders VALUES
-- (123123, 666, 'PAID');

-- SELECT *
-- FROM wc100_financial_audit_v
-- WHERE order_id = 123123;

-- ROLLBACK;

-- SELECT *
-- FROM wc100_financial_audit_v
-- ORDER BY order_id;

-- -- Quest 3: Financial Quality Gate
-- CREATE OR REPLACE VIEW wc100_financial_gate_v AS
-- WITH gate_statuses AS (
--     SELECT
--         COUNT(order_id) AS paid_orders,
--         COUNT(order_id) FILTER (
--             WHERE incident_type = 'MATCH'
--         ) AS match_orders,
--         COUNT(order_id) FILTER (
--             WHERE incident_type = 'OVERPAID'
--         ) AS overpaid_orders,
--         COUNT(order_id) FILTER (
--             WHERE incident_type = 'UNDERPAID'
--         ) AS underpaid_orders,
--         COUNT(order_id) FILTER (
--             WHERE incident_type = 'MISSING_ITEMS'
--         ) AS missing_items_orders,
--         COUNT(order_id) FILTER (
--             WHERE incident_type = 'MISSING_PAYMENT'
--         ) AS missing_payment_orders
--     FROM wc100_financial_audit_v
-- )
-- SELECT
--     paid_orders,
--     match_orders,
--     overpaid_orders,
--     underpaid_orders,
--     missing_items_orders,
--     missing_payment_orders,
--     CASE 
--         WHEN paid_orders = match_orders AND paid_orders != 0 THEN 'PASS'
--         ELSE 'FAIL'
--     END AS quality_status
-- FROM gate_statuses;

-- SELECT * 
-- FROM wc100_financial_gate_v;

-- Quest 4: The Silent Data Loss
CREATE OR REPLACE VIEW wc100_financial_gate_v2 AS
WITH missing_audit_orders AS (
    SELECT 
        COUNT(o.order_id) AS missing_audit_orders
    FROM wc100_orders AS o
    LEFT JOIN wc100_financial_audit_v AS fa
        ON o.order_id = fa.order_id
    WHERE fa.order_id IS NULL
        AND o.order_status = 'PAID'
),
expected_paid_orders AS (
    SELECT 
        COUNT(order_id) AS expected_paid_orders
    FROM wc100_orders
    WHERE order_status = 'PAID'
),
gate_statuses AS (
    SELECT
        COUNT(order_id) AS paid_orders,
        COUNT(order_id) FILTER (
            WHERE incident_type = 'MATCH'
        ) AS match_orders,
        COUNT(order_id) FILTER (
            WHERE incident_type = 'OVERPAID'
        ) AS overpaid_orders,
        COUNT(order_id) FILTER (
            WHERE incident_type = 'UNDERPAID'
        ) AS underpaid_orders,
        COUNT(order_id) FILTER (
            WHERE incident_type = 'MISSING_ITEMS'
        ) AS missing_items_orders,
        COUNT(order_id) FILTER (
            WHERE incident_type = 'MISSING_PAYMENT'
        ) AS missing_payment_orders
    FROM wc100_financial_audit_v
)
SELECT
    gs.paid_orders,
    gs.match_orders,
    gs.overpaid_orders,
    gs.underpaid_orders,
    gs.missing_items_orders,
    gs.missing_payment_orders,
    ma.missing_audit_orders,
    ep.expected_paid_orders,
    CASE
        WHEN gs.paid_orders > 0 
            AND ma.missing_audit_orders = 0
            AND gs.paid_orders = ep.expected_paid_orders
            AND gs.paid_orders = gs.match_orders THEN 'PASS'
        ELSE 'FAIL'
    END AS quality_status
FROM gate_statuses AS gs
CROSS JOIN missing_audit_orders AS ma
CROSS JOIN expected_paid_orders AS ep;

SELECT * 
FROM wc100_financial_gate_v2;