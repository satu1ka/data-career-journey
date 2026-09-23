\set ON_ERROR_STOP on

SELECT 'CREATE DATABASE data_career_journey'
WHERE NOT EXISTS (
    SELECT FROM pg_database
    WHERE datname = 'data_career_journey'
)
\gexec

\connect data_career_journey

SELECT current_database() AS database_name;
