# Python Core — Day 5: Dictionaries (dict).
# Сегодня: создание словаря → доступ по ключу → изменение/добавление значений → in → .get() → перебор словаря. Потом начнём соединять dict со списками. 

# # 0. Разминка Day 4
# file_sizes = [0, 450, 1200, 0, 800, 2100, 300]

# valid_files = []
# large_files = []

# for file_size in file_sizes:
#     if file_size == 0:
#         continue

#     valid_files.append(file_size)

#     if file_size >= 1000:
#         large_files.append(file_size)

# print(f'Valid files: {valid_files}')
# print(f'Large files: {large_files}')
# print(f'Valid count: {len(valid_files)}')
# print(f'Large count: {len(large_files)}')
    
# 1. Dictionary — dict

# # Task 1 — первый dict
# pipeline = {
#     'name': 'customers_daily',
#     'rows_received': 8500,
#     'failed_rows': 120,
#     'completed': True
# }

# # # Выведи только название pipeline.
# # # Выведи количество failed_rows.
# # # Измени failed_rows с 120 на 80.
# # # Добавь новый ключ 'source' со значением 'api'.
# # # Добавь новый ключ 'valid_rows'. Его значение посчитай из данных самого словаря: rows_received - failed_rows.
# # # Выведи весь словарь.

# # print(pipeline['name'])
# # print(pipeline['failed_rows'])
# pipeline['failed_rows'] = 80
# pipeline['source'] = 'api'
# pipeline['valid_rows'] = pipeline['rows_received'] - pipeline['failed_rows']
# # print(pipeline)

# # Task 2
# # если ключ 'source' существует → вывести Source found;
# # если ключа нет → Source missing;
# # отдельно проверить ключ 'destination';
# # если его нет → вывести Destination missing.

# if 'source' in pipeline:
#     print('Source found')
# else:
#     print('Source missing')
# if 'destination' not in pipeline:
#     print('Destination missing')

# 4. .get() — безопасное получение значения
# Если ключа нет:
# pipeline.get('destination')
# → вернёт None вместо KeyError.
# Можно указать значение по умолчанию:
# pipeline.get('destination', 'unknown')
# → если ключа нет, получим:
# unknown

# # Task 4
# pipeline = {
#     'name': 'orders_daily',
#     'source': 'api',
#     'rows': 12500
# }

# # Используя только .get() для получения значений, выведи:
# # Pipeline: orders_daily
# # Source: api
# # Destination: not specified
# # Rows: 12500

# print(f'Pipeline: {pipeline.get('name')}')
# print(f'Source: {pipeline.get('source')}')
# print(f'Destination: {pipeline.get('destination', 'not specified')}')
# print(f'Rows: {pipeline.get('rows')}')

# # Task 5 — .get() + логика
# pipeline = {
#     'name': 'payments_daily',
#     'rows_received': 10000,
#     'failed_rows': 250
# }
# # Нужно вывести:
# # если failed_rows == 0 → Pipeline is clean
# # если failed_rows <= 300 → Pipeline has warnings
# # иначе → Pipeline has critical errors
# if pipeline.get('failed_rows') == 0:
#     print('Pipeline is clean')
# elif pipeline.get('failed_rows') <= 300:
#     print('Pipeline has warnings')
# else:
#     print('Pipeline has critical errors')

# 5. Перебор словаря через for
# Если сделать:
# for key in pipeline:
#     print(key)
# Python перебирает ключи:
# name
# rows_received
# failed_rows
# А значение можно получить:
# for key in pipeline:
#     print(key, pipeline[key])
# Но есть более удобный способ — .items():
# for key, value in pipeline.items():
#     print(key, value)

# # Task 6
# pipeline = {
#     'name': 'events_daily',
#     'source': 'kafka',
#     'rows_received': 18500,
#     'failed_rows': 75
# }

# for key, value in pipeline.items():
#     print(f'{key}: {value}')

# 6. .keys() и .values()

# У словаря есть три основных способа перебора:

# pipeline.keys()    # только ключи
# pipeline.values()  # только значения
# pipeline.items()   # ключ + значение

# # Task 7
# file_stats = {
#     'orders.csv': 1200,
#     'customers.csv': 850,
#     'products.csv': 2400,
#     'events.csv': 600
# }

# # # Используя .items(), посчитай общее количество строк во всех файлах.

# # total_rows = 0

# # for file_name, rows in file_stats.items():
# #     total_rows += rows

# # print(f'Total rows: {total_rows}')

# # Task 8
# large_files = []

# for file_name, rows in file_stats.items():
#     if rows >= 1000:
#         large_files.append(file_name)

# print(f'Large files: {large_files}')

# Task 9 — nested dictionary
# pipeline = {
#     'name': 'orders_daily',
#     'source': {
#         'type': 'api',
#         'system': 'shop'
#     },
#     'stats': {
#         'rows_received': 15000,
#         'failed_rows': 250
#     }
# }
# # Не используя циклы, выведи:
# # Pipeline: orders_daily
# # Source type: api
# # Source system: shop
# # Rows received: 15000
# # Failed rows: 250

# # print(f'Pipeline: {pipeline['name']}')
# # print(f'Source type: {pipeline['source']['type']}')
# # print(f'Source system: {pipeline['source']['system']}')
# # print(f'Rows received: {pipeline['stats']['rows_received']}')
# # print(f'Failed rows: {pipeline['stats']['failed_rows']}')

# pipeline['stats']['failed_rows'] = 100
# pipeline['stats']['valid_rows'] = pipeline['stats']['rows_received'] - pipeline['stats']['failed_rows']
# pipeline['source']['format'] = 'json'
# print(pipeline)

# 7. List of dictionaries
pipelines = [
    {
        'name': 'orders',
        'rows': 1200,
        'status': 'success'
    },
    {
        'name': 'customers',
        'rows': 850,
        'status': 'failed'
    },
    {
        'name': 'products',
        'rows': 2400,
        'status': 'success'
    }
]

# Task 11
# Через один for выведи:

# orders: success
# customers: failed
# products: success

# for pipeline in pipelines:
#     print(f"{pipeline['name']}: {pipeline['status']}")

# Task 12 — list of dicts + фильтрация
# failed_pipelines = []

# for pipeline in pipelines:
#     if pipeline['status'] == 'failed':
#         failed_pipelines.append(pipeline['name'])

# print(f"Failed pipelines: {failed_pipelines}")

# Task 13 — list of dicts + агрегация
# Нужно посчитать общее количество строк только у успешных pipeline.
# successful_rows = 0
# for pipeline in pipelines:
#     if pipeline['status'] != 'success':
#         continue

#     successful_rows += pipeline['rows']

# print(f'Successful rows: {successful_rows}')

# # Task 15 — чуть сложнее
# pipelines = [
#     {'name': 'orders', 'rows': 1500, 'failed_rows': 50},
#     {'name': 'customers', 'rows': 800, 'failed_rows': 0},
#     {'name': 'events', 'rows': 2400, 'failed_rows': 300},
#     {'name': 'products', 'rows': 1200, 'failed_rows': 20}
# ]

# healthy_pipelines = []

# for pipeline in pipelines:
#     if pipeline['rows'] >= 1000 and pipeline['failed_rows'] <= 50:
#         healthy_pipelines.append(pipeline['name'])

# print(f'Healthy pipelines: {healthy_pipelines}')

# # Task 16 — изменение словарей внутри списка
# pipelines = [
#     {'name': 'orders', 'rows': 1500, 'failed_rows': 50},
#     {'name': 'customers', 'rows': 800, 'failed_rows': 0},
#     {'name': 'events', 'rows': 2400, 'failed_rows': 300}
# ]

# for pipeline in pipelines:
#     pipeline['valid_rows'] = pipeline['rows'] - pipeline['failed_rows']

# # print(pipelines)

# # Task 17 — enrichment + условие
# for pipeline in pipelines:
#     if pipeline['failed_rows'] == 0:
#         pipeline['quality'] = 'perfect'
#     elif pipeline['failed_rows'] <= 100:
#         pipeline['quality'] = 'warning'
#     else:
#         pipeline['quality'] = 'critical'

# print(pipelines)

# # Task 18 — dict.get() в реальных неполных данных
# pipelines = [
#     {'name': 'orders', 'rows': 1500, 'failed_rows': 50},
#     {'name': 'customers', 'rows': 800},
#     {'name': 'events', 'rows': 2400, 'failed_rows': 300},
#     {'name': 'products', 'rows': 1200}
# ]

# for pipeline in pipelines:
#     print(f"{pipeline['name']}: {pipeline.get('failed_rows', 0)}")

# # Task 21 — маленькая DE-задача
# records = [
#     {'name': 'orders', 'rows': 1500},
#     {'name': 'customers', 'rows': None},
#     {'name': 'events'},
#     {'name': 'products', 'rows': 800}
# ]

# total_rows = 0

# for record in records:
#     if 'rows' not in record:
#         continue
#     elif record['rows'] is None:
#         continue

#     total_rows += record.get('rows')

# print(f'Total rows: {total_rows}')

# # Task 22 — теперь самостоятельно
# pipelines = [
#     {'name': 'orders', 'failed_rows': 25},
#     {'name': 'customers'},
#     {'name': 'events', 'failed_rows': None},
#     {'name': 'products', 'failed_rows': 0},
#     {'name': 'payments', 'failed_rows': 150}
# ]

# problem_pipelines = []

# # Правила:
# # отсутствующий failed_rows → пропускаем;
# # failed_rows is None → пропускаем;
# # failed_rows == 0 → тоже не проблема;
# # если failed_rows > 0 → добавить имя pipeline в problem_pipelines.
# # Постарайся сделать через early continue, без else.

# for pipeline in pipelines:
#     if 'failed_rows' not in pipeline or pipeline['failed_rows'] is None or pipeline['failed_rows'] == 0:
#         continue

#     problem_pipelines.append(pipeline['name'])

# print(f'Problem pipelines: {problem_pipelines}')

# Task 23 — финальная задача Day 5
pipelines = [
    {'name': 'orders', 'rows': 1500, 'failed_rows': 25},
    {'name': 'customers', 'rows': 800},
    {'name': 'events', 'rows': 2400, 'failed_rows': None},
    {'name': 'products', 'rows': 1200, 'failed_rows': 0},
    {'name': 'payments', 'rows': 1800, 'failed_rows': 150}
]

# Нужно обогатить каждую запись новым ключом 'status'.
# Правила:
# failed_rows отсутствует или None → 'unknown'
# failed_rows == 0                 → 'perfect'
# failed_rows <= 100               → 'warning'
# failed_rows > 100                → 'critical'

for pipeline in pipelines:
    if pipeline.get('failed_rows') is None:
        pipeline['status'] = 'unknown'
    elif pipeline['failed_rows'] == 0:
        pipeline['status'] = 'perfect'
    elif pipeline['failed_rows'] <= 100:
        pipeline['status'] = 'warning'
    else:
        pipeline['status'] = 'critical'

    print(f"{pipeline['name']}: {pipeline['status']}")

# Day 5 — закончен ✅
# Сегодня мы довольно далеко ушли с dict:
# создание словаря и доступ dict['key'];
# изменение и добавление ключей;
# in / not in;
# KeyError;
# .get() и default value;
# разница между отсутствующим ключом и None;
# .keys(), .values(), .items();
# перебор key, value;
# nested dictionaries;
# list из dict;
# фильтрация и агрегация таких записей;
# enrichment — добавление рассчитанных полей;
# обработка неполных данных;
# early continue;
# немного зацепили short-circuit or.