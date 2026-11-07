
-- Day 77 — Late Commit Experiment
-- Удаляем только учебные таблицы Day 77

DROP TABLE IF EXISTS orders_processed_day77;
DROP TABLE IF EXISTS orders_events_day77;
DROP TABLE IF EXISTS pipeline_state_day77;

CREATE TABLE orders_events_day77 (
    event_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    amount NUMERIC(10, 2),
    status TEXT,
    updated_at TIMESTAMP NOT NULL,
    ingested_at TIMESTAMP NOT NULL
);

CREATE TABLE orders_processed_day77 (
    event_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    ingested_at TIMESTAMP NOT NULL
);

CREATE TABLE pipeline_state_day77 (
    pipeline_name TEXT PRIMARY KEY,
    last_ingested_at TIMESTAMP NOT NULL,
    last_event_id INT NOT NULL
);

-- Начальная позиция
INSERT INTO pipeline_state_day77
VALUES (
    'orders_late_commit_lab',
    '2026-11-01 12:20:00',
    4014
);

-- Событие, которое уже было обработано ранее
INSERT INTO orders_events_day77
VALUES (
    4014, 712, 250.00, 'completed',
    '2026-11-01 12:15:00',
    '2026-11-01 12:20:00'
);

INSERT INTO orders_processed_day77
VALUES (
    4014, 712, '2026-11-01 12:20:00'
);
