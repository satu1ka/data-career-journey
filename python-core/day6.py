# # Warm-up — list + dict + get()
# pipelines = [
#     {'name': 'orders', 'rows': 1500, 'failed_rows': 25},
#     {'name': 'customers', 'rows': 800},
#     {'name': 'events', 'rows': 2400, 'failed_rows': None},
#     {'name': 'products', 'rows': 1200, 'failed_rows': 0},
#     {'name': 'payments', 'rows': 1800, 'failed_rows': 150}
# ]

# total_valid_rows = 0

# for pipeline in pipelines:
#     if pipeline.get('failed_rows') is None:
#         continue

#     valid_rows = pipeline['rows'] - pipeline['failed_rows']
#     total_valid_rows += valid_rows

# print(f'Total valid rows: {total_valid_rows}')

# 1. Tuple - кортеж
# почти тоже самое, что и list, только значения внутри нельзя менять

# # Task 1 — базовый tuple
# file_info = ('orders.csv', 1500, 'success', 'api')

# print(f'File: {file_info[0]}')
# print(f'Rows: {file_info[1]}')
# print(f'Status: {file_info[2]}')
# print(f'Source: {file_info[-1]}')

# 2. Tuple unpacking
# Вместо:

# file_name = file_info[0]
# rows = file_info[1]
# status = file_info[2]
# source = file_info[3]

# можно написать:

# file_name, rows, status, source = file_info

# Python автоматически разложит значения:

# file_name → 'orders.csv'
# rows      → 1500
# status    → 'success'
# source    → 'api'

# # Task 2 — unpacking
# pipeline_info = ('payments_daily', 'database', 12500, 75)
# name, source, rows, failed_rows = pipeline_info
# print(f'Pipeline: {name}')
# print(f'Source: {source}')
# print(f'Valid rows: {rows - failed_rows}')

# 3. Ошибка при unpacking
# Здесь есть важное правило: количество переменных обычно должно совпадать с количеством элементов.
# 3 values → 2 variables = too many values
# 2 values → 3 variables = not enough values

# # Task 4 — tuple внутри списка
# files = [
#     ('orders.csv', 1200),
#     ('customers.csv', 850),
#     ('products.csv', 2400)
# ]

# for name, rows in files:
#     print(f'{name}: {rows} rows')

# 4. Переходим к set
# Список может содержать дубликаты:
# statuses = [
#     'success',
#     'failed',
#     'success',
#     'skipped',
#     'failed'
# ]
# Если превратить его в set:
# unique_statuses = set(statuses)
# получим уникальные значения:
# {'success', 'failed', 'skipped'}
# Порядок при этом не стоит считать гарантированным.
# !
# Главная идея:
# set — коллекция уникальных значений.
# !
# Создать напрямую:
# statuses = {'success', 'failed', 'skipped'}
# Добавить:
# statuses.add('warning')
# Если добавить существующее значение:
# statuses.add('success')
# второго 'success' не появится.
# Проверка membership знакомая:

# if 'failed' in statuses:
#     print('Failed status exists')

# # Task 5 — первый set
# file_types = [
#     'csv',
#     'json',
#     'csv',
#     'parquet',
#     'json',
#     'csv',
#     'xml'
# ]

# unique_file_types = set(file_types)
# print(f'Unique types: {unique_file_types}')
# print(f'Number of unique types: {len(unique_file_types)}')

# У set нет индексов как у list и tuple.

# 5. .add() и .remove()
# Добавление одного элемента:
# file_types = {'csv', 'json'}
# file_types.add('parquet')
# Если 'csv' уже существует:
# file_types.add('csv')
# ничего страшного не происходит — дубликат просто не появляется.
# Удалить:
# file_types.remove('json')

# .remove()   нет элемента → KeyError
# .discard()  нет элемента → ничего не происходит

# # Task 7 — add/remove/discard
# formats = {'csv', 'json', 'xml'}
# # Добавь 'parquet'.
# # Попробуй ещё раз добавить 'csv'.
# # Удали существующий 'xml' через .remove().
# # Попробуй удалить отсутствующий 'avro' без возникновения ошибки.
# # Выведи итоговый formats.
# # Выведи количество элементов.
# formats.add('parquet')
# formats.add('csv')
# formats.remove('xml')
# formats.discard('avro')
# print(formats)
# print(len(formats))

# 6. Set operations
# Допустим, есть ожидаемые файлы и реально полученные:
required_files = {
    'orders.csv',
    'customers.csv',
    'products.csv',
    'payments.csv'
}
received_files = {
    'orders.csv',
    'products.csv',
    'events.csv'
}
# Мы можем сравнивать наборы.
# Difference — разница
# required_files - received_files
# означает:
# Что есть в required_files, но отсутствует в received_files?

# required_files.difference(received_files)

# Task 8 — missing files
# missing_files = required_files.difference(received_files)
# print(f'Missing files: {missing_files}')
# print(f'Missing count: {len(missing_files)}')

# # Task 9 — две разницы
# missing_files = required_files - received_files
# unexpected_files = received_files - required_files
# print(missing_files)
# print(unexpected_files)

# 7. Intersection — пересечение
# Теперь другой вопрос:
# Какие файлы одновременно есть и в required_files, и в received_files?
# Для этого есть intersection:
# required_files.intersection(received_files)
# или гораздо короче:
# required_files & received_files

# # Task 10 — intersection
# available_files = required_files & received_files
# print(f'Available files: {available_files}')
# print(f'Available count: {len(available_files)}')

# 8. Union — объединение
# Если нужно получить все уникальные элементы из обоих наборов:
# all_files = required_files | received_files

# # Task 12 — найди дубликаты
# order_ids = [101, 102, 103, 102, 104, 105, 101, 106]

# seen_ids = set()
# duplicate_ids = set()

# for order_id in order_ids:
#     if order_id in seen_ids:
#         duplicate_ids.add(order_id)
#     else:
#         seen_ids.add(order_id)

# print(seen_ids)
# print(duplicate_ids)

# # Task 13 — теперь сам на другом датасете
# user_ids = [10, 20, 30, 20, 40, 10, 50, 20]

# seen_users = set()
# duplicate_users = set()

# for user_id in user_ids:
#     if user_id in seen_users:
#         duplicate_users.add(user_id)
#     else:
#         seen_users.add(user_id)

# print(f'Duplicate users: {duplicate_users}')
# print(f'Number of duplicate users: {len(duplicate_users)}')

# 10. Проверка subset
# Можно спросить:
# Все ли обязательные колонки присутствуют среди полученных?
# required_columns.issubset(received_columns)
# → True.
# Также можно написать:
# required_columns <= received_columns

# # Task 14 — schema validation

# required_columns = {
#     'order_id',
#     'customer_id',
#     'price',
#     'quantity'
# }

# received_columns = {
#     'order_id',
#     'price',
#     'quantity',
#     'status'
# }

# if required_columns.issubset(received_columns):
#     print('Schema valid')
# else:
#     print('Schema invalid')

# # Task 15 — validation + missing columns

# if required_columns <= received_columns:
#     print('Schema valid')
# else:
#     print('Schema invalid')
#     missing_columns = required_columns - received_columns
#     print(f'Missing columns: {missing_columns}')

# # Task 16 — schema validation чуть реалистичнее
# required_columns = {
#     'order_id',
#     'customer_id',
#     'price'
# }

# allowed_columns = {
#     'order_id',
#     'customer_id',
#     'price',
#     'quantity',
#     'status'
# }

# received_columns = {
#     'order_id',
#     'price',
#     'quantity',
#     'debug_info'
# }

# missing_columns = required_columns - received_columns
# unexpected_columns = received_columns - allowed_columns
# print(f'Missing columns: {missing_columns}')
# print(f'Unexpected columns: {unexpected_columns}')

# 11. Когда list, tuple, set, dict?
# Упрощённая шпаргалка:

# list  → порядок / последовательность
# tuple → фиксированный порядок
# set   → уникальность
# dict  → key → value

# Task 19 — финальная практика Day 6
# Соберём set + dict + циклы в одной небольшой задаче.
# пришли:
events = [
    {'event_id': 101, 'type': 'click'},
    {'event_id': 102, 'type': 'view'},
    {'event_id': 103, 'type': 'click'},
    {'event_id': 102, 'type': 'view'},
    {'event_id': 104, 'type': 'purchase'},
    {'event_id': 101, 'type': 'click'},
    {'event_id': 105, 'type': 'view'}
]
# Создай:
seen_event_ids = set()
duplicate_event_ids = set()
event_types = set()

# За один for нужно:
# собрать все уникальные 'type' в event_types;
# определить повторяющиеся 'event_id';
# каждый встреченный впервые ID добавить в seen_event_ids.

for event in events:
    if event['event_id'] in seen_event_ids:
        duplicate_event_ids.add(event['event_id'])
    else:
        seen_event_ids.add(event['event_id'])

    event_types.add(event['type'])

print(f'Event types: {event_types}')
print(f'Duplicate event IDs: {duplicate_event_ids}')
print(f'Unique event count: {len(seen_event_ids)}')


# Day 6 — закончен ✅
# Сегодня прошли две новые структуры.
# tuple: создание через (), индексы и slicing как у list, immutable-структура, unpacking:
# name, rows = ('orders.csv', 1500)
# и unpacking прямо в цикле:
# for name, rows in files:
# Также познакомились с ValueError при несовпадении количества элементов и переменных.
# set: уникальные значения, отсутствие индексов и гарантированного порядка, .add(), .remove(), .discard(), membership через in, а также основные операции:
# A - B   # difference
# A & B   # intersection
# A | B   # union
# A <= B  # subset