# Task 2 — маленький код, Data Quality
# sensor_id | temperature | recorded_at

def invalid_condition(table):
    invalid_temperature_condition = (
        table['temperature'].isna()
    )
    invalid_recorded_date = (
        table['recorded_at'].isna()
    )

    invalid_condition = (
        invalid_temperature_condition |
        invalid_recorded_date
    )

    return invalid_condition

# тут было сильно больше заданий (9), но они были теоретическими, так что этот файл больше для галочки, что не пропустил деньg