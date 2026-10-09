-- -- Механика NULLIF
-- NULLIF(a, b)

-- если a = b
-- → NULL

-- иначе
-- → a

-- -- Quest 4 — код
-- SELECT 
--     promo_code,
--     COALESCE(NULLIF(promo_code, ''), 'no_promo') AS normalized_promo;

-- -- Quest 5 — короткий DE-кейс
-- -- Нужно получить нормализованное значение так, чтобы:
-- -- '10' → '10'
-- -- '0'  → NULL
-- -- ''   → NULL
-- -- NULL → NULL
-- NULLIF(
--     NULLIF(discount_percent, ''),
--     '0'
-- ) AS normalized_discount

-- -- Quest 6 — NULLIF + CAST
-- CAST(
--     NULLIF(
--         NULLIF(discount_percent, ''), '0' 
--     ) AS NUMERIC
-- ) AS normalized_discount;

-- Quest 7 — CAST + NULLIF в расчёте
CAST(revenue AS NUMERIC) 
/ 
CAST(
    NULLIF(
        NULLIF(quantity, ''), 
        '0'
    ) AS INTEGER
) AS revenue_per_item;

-- NULLIF
-- → нормализуем специальные значения в NULL

-- CAST
-- → приводим нормальные значения к нужному типу

-- COALESCE
-- → при необходимости заменяем NULL на fallback