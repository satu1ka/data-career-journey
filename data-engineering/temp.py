# weather_etl/
# ├── __init__.py
# ├── app.py
# ├── api.py
# ├── cleaning.py
# └── reporting.pyФункции:

# request_weather()
# build_api_url()

# convert_temperature()
# remove_invalid_records()

# build_city_summary()
# save_report()

# run()
# main()

# app.py:
# import api, cleaning, reporting
# main()
# run()

# api.py:
# build_api_url()
# request_weather()

# cleaning.py:
# convert_temperature()
# remove_invalid_records()

# reporting.py:
# build_city_summary()
# save_report()

# app.py
# Responsibility: определение логирования, оркестрация пайплайном, запуск программы
# Imports: config_utils, pipeline, transformations
# Imported by:

# config_utils.py
# Responsibility: работа с конфигом: его загрузка, проверка на валидность
# Imports: pandas, json
# Imported by: app

# pipeline.py
# Responsibility: загрузка данных, их преобразование в требуемый вид, их валидация, создание метрики
# Imports: pandas
# Imported by: app

# transformations.py
# Responsibility: преобразование данных под требования бизнеса
# Imports: pandas
# Imported by: app