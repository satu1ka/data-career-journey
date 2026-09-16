# Challenge 1 — чистый Python
# files = [
#     {'name': 'sales.csv', 'rows': 1250, 'failed_rows': 25},
#     {'name': 'users.csv', 'rows': 0, 'failed_rows': 0},
#     {'name': 'events.csv', 'rows': 2400, 'failed_rows': 150},
#     {'name': 'products.csv', 'rows': 850, 'failed_rows': 0},
#     {'name': 'archive.csv', 'rows': 1700, 'failed_rows': None}
# ]

# # Total valid rows: ...
# # Processed files: ...
# # Problem files: [...]

# # Правила:
# # файл с rows == 0 полностью пропускаем;
# # если failed_rows равен None, файл тоже полностью пропускаем;
# # остальные считаются обработанными → processed_files += 1;
# # valid_rows = rows - failed_rows;
# # прибавляем valid_rows к total_valid_rows;
# # если failed_rows > 0, добавляем имя файла в problem_files.

# total_valid_rows = 0
# processed_files = 0
# problem_files = []

# for record in files:
#     if record['rows'] == 0 or record['failed_rows'] is None:
#         continue

#     processed_files += 1
#     total_valid_rows += record['rows'] - record['failed_rows']

#     if record['failed_rows'] > 0:
#         problem_files.append(record['name'])

# print(f'Total valid rows: {total_valid_rows}')
# print(f'Processed files: {processed_files}')
# print(f'Problem files: {problem_files}')

# # Challenge 2 — debugging
# # По бизнес-правилу:
# # 0 → пропускаем;
# # отрицательное значение → тоже просто пропускаем, обработка следующих файлов должна продолжаться;
# # положительное → прибавляем размер к total_size и 1 к valid_files.
# file_sizes = [1200, 0, 850, -1, 2400]

# total_size = 0
# valid_files = 0

# for size in file_sizes:
#     if size == 0 or size < 0:
#         continue

#     total_size += size
#     valid_files += 1

# print(f'Total size: {total_size}')
# print(f'Valid files: {valid_files}')

# Challenge 3 — prediction: dict + .get()
# pipeline = {
#     'name': 'orders',
#     'rows': 1500,
#     'failed_rows': None
# }

# rows = pipeline.get('rows', 0)
# failed = pipeline.get('failed_rows', 0)
# source = pipeline.get('source', 'unknown')

# print(rows)
# print(failed)
# print(source)

# if failed:
#     print('Has failures')
# else:
#     print('No failures')

# # 1500
# # None
# # unknown
# # no failures

# # Challenge 4 — boolean logic + условия
# # Без промежуточных флагов напиши if / elif / else для проверки pipeline:
# pipeline_status = 'completed'
# rows_received = 10000
# rows_loaded = 9700
# failed_rows = 300
# # Правила:
# # CRITICAL, если выполняется хотя бы одно:
# # pipeline_status не 'completed';
# # failed_rows > 500.
# # WARNING, если pipeline не CRITICAL и выполняется хотя бы одно:
# # rows_received != rows_loaded;
# # failed_rows > 0.
# # Иначе:
# # PERFECT.

# if pipeline_status != 'completed' or failed_rows > 500:
#     print('Pipeline: CRITICAL')
# elif rows_received != rows_loaded or failed_rows > 0:
#     print('Pipeline: WARNING')
# else: 
#     print('Pipeline: PERFECT')

# # Challenge 5 — set + поиск дублей
# # Есть список ID транзакций:
# transaction_ids = [501, 502, 503, 501, 504, 502, 505, 501]
# # Нужно получить два множества:
# unique_ids = set()
# duplicate_ids = set()
# # После обработки:
# # unique_ids должен содержать все уникальные ID;
# # duplicate_ids — только те ID, которые встретились повторно;
# # в конце выведи количество уникальных ID и само множество дублей.
# for transaction_id in transaction_ids:
#     if transaction_id in unique_ids:
#         duplicate_ids.add(transaction_id)
#     else:
#         unique_ids.add(transaction_id)

# print(f'Unique transactions: {len(unique_ids)}')
# print(f'Duplicate IDs: {duplicate_ids}')

# Challenge 6 — структуры данных
# Теперь без кода. Для каждого случая выбери list / tuple / set / dict и буквально в нескольких словах объясни почему.

# Последовательность последних 100 HTTP status codes (200, 200, 404, 500...). Важен порядок, одинаковые значения должны сохраняться.
# Координата точки (latitude, longitude). Всегда ровно два связанных значения, их позиция имеет смысл.
# Набор уже обработанных order_id. Нужно быстро проверять, встречался ли ID раньше, дубли хранить не нужно.
# Информация о pipeline: name, source, status, rows. Нужно получать значения по понятным именам.

# 1. list - т.к. важен порядок, не имеет значения: одинаковые или нет
# 2. tuple - фиксированный порядок
# 3. set - уникальные значения
# 4. dict - key - value

# # Challenge 7 — tuple unpacking + цикл
# # Есть результаты выполнения jobs:
# jobs = [
#     ('extract_users', 12.5, 'success'),
#     ('load_orders', 31.8, 'failed'),
#     ('update_products', 8.4, 'success'),
#     ('cleanup_logs', 4.2, 'failed')
# ]
# # Нужно за один for:
# # распаковывать tuple прямо в заголовке цикла;
# # посчитать total_time для всех jobs;
# # посчитать количество failed jobs;
# # добавить имена failed jobs в failed_jobs.
# # Начальные переменные:

# total_time = 0
# failed_count = 0
# failed_jobs = []

# for name, execution_time, status in jobs:
#     if status == 'failed':
#         failed_count += 1
#         failed_jobs.append(name)

#     total_time += execution_time

# print(f'Total time: {total_time}')
# print(f'Failed count: {failed_count}')
# print(f'Failed jobs: {failed_jobs}')

# # Challenge 8 — уже пожирнее: schema validation
# # Пришли колонки из CSV:
# required_columns = {'order_id', 'customer_id', 'price', 'quantity'}
# allowed_columns = {
#     'order_id',
#     'customer_id',
#     'price',
#     'quantity',
#     'created_at',
#     'source'
# }

# received_columns = {
#     'order_id',
#     'price',
#     'quantity',
#     'created_at',
#     'debug_info'
# }

# # Нужно вычислить:
# # missing_columns = ...
# # unexpected_columns = ...

# missing_columns = required_columns - received_columns
# unexpected_columns = received_columns - allowed_columns

# if missing_columns:
#     schema_status = 'INVALID'
# elif unexpected_columns:
#     schema_status = 'WARNING'
# else:
#     schema_status = 'VALID'

# print(f'Missing: {missing_columns}')
# print(f'Unexpected: {unexpected_columns}')
# print(f'Schema status: {schema_status}')

# # Challenge 9 — while + batching
# rows_remaining = 4700
# batch_size = 1000
# batch_number = 1
# # Нужно имитировать обработку данных батчами.
# # Программа должна печатать:
# # Batch 1: processing 1000 rows
# # Batch 2: processing 1000 rows
# # ...
# # Batch 5: processing 700 rows
# # Processing finished

# # Условия:
# # использовать while;
# # размер обычного батча — 1000;
# # последний батч должен обработать только оставшиеся строки, то есть 700, а не 1000;
# # после каждого батча уменьшать rows_remaining;
# # увеличивать batch_number;
# # никаких дополнительных библиотек.
# while rows_remaining > 0:
#     if rows_remaining >= batch_size:
#         current_batch = batch_size
#     else:
#         current_batch = rows_remaining
#     rows_remaining -= current_batch

#     print(f'Batch {batch_number}: processing {current_batch} rows')
    
#     batch_number += 1
# print('Processing finished')

# # Challenge 11 — list + dict + set
# events = [
#     {'user_id': 10, 'event': 'login'},
#     {'user_id': 20, 'event': 'purchase'},
#     {'user_id': 10, 'event': 'purchase'},
#     {'user_id': 30, 'event': 'login'},
#     {'user_id': 20, 'event': 'logout'},
#     {'user_id': 40, 'event': 'purchase'},
#     {'user_id': 10, 'event': 'logout'}
# ]
# unique_users = set()
# purchase_users = set()
# purchase_count = 0

# # Правила простые: unique_users — все встретившиеся user_id; 
# # purchase_users — уникальные пользователи, у которых был хотя бы один 'purchase'; 
# # purchase_count — общее количество событий 'purchase', не количество пользователей.

# for event in events:
#     unique_users.add(event['user_id'])

#     if event['event'] == 'purchase':
#         purchase_users.add(event['user_id'])
#         purchase_count += 1
    
# print(f'Unique users: {unique_users}')
# print(f'User with purchases: {purchase_users}')
# print(f'Purchase events: {purchase_count}')

# # Challenge 12 — debugging посложнее
# records = [
#     {'id': 1, 'rows': 1200},
#     {'id': 2, 'rows': None},
#     {'id': 3},
#     {'id': 4, 'rows': 800}
# ]

# total_rows = 0
# processed_records = 0

# for record in records:
#     if record.get('rows') is None:
#         continue

#     total_rows += record['rows']
#     processed_records += 1

# print(f'Total rows: {total_rows}')
# print(f'Processed records: {processed_records}')

# # Новые бизнес-правила такие:
# # если 'rows' отсутствует → запись не обрабатываем;
# # если 'rows' is None → тоже не обрабатываем;
# # только записи с настоящим числом участвуют и в total_rows, и в processed_records.

# # Challenge 13 — арифметика + batching без цикла
# total_rows = 10301
# failed_rows = 326
# batch_size = 2000

# valid_rows = total_rows - failed_rows
# full_batches = valid_rows // batch_size
# remainder_rows = valid_rows % batch_size
# total_batches = (valid_rows + batch_size - 1) // batch_size

# print(f'Valid rows: {valid_rows}')
# print(f'Full batches: {full_batches}')
# print(f'Remainder rows: {remainder_rows}')
# print(f'Total batches: {total_batches}')

# # Challenge 14 — break vs continue
# checks = ['ok', 'warning', 'ok', 'critical', 'ok', 'warning']
# successful_checks = 0
# for result in checks:
#     if result == 'warning':
#         continue
#     if result == 'critical':
#         break
#     successful_checks += 1

# print(f'Successful checks: {successful_checks}')

# # Challenge 15 — вложенные dict + Data Quality
# pipelines = [
#     {
#         'name': 'orders',
#         'stats': {'received': 1500, 'failed': 20}
#     },
#     {
#         'name': 'users',
#         'stats': {'received': 800, 'failed': 0}
#     },
#     {
#         'name': 'events',
#         'stats': {'received': 2200, 'failed': None}
#     },
#     {
#         'name': 'products',
#         'stats': {'received': 1200}
#     }
# ]
# healthy_pipelines = []
# total_valid_rows = 0

# for pipeline in pipelines:
#     if pipeline['stats'].get('failed') is None:
#         continue

#     valid_rows = pipeline['stats']['received'] - pipeline['stats']['failed']
#     total_valid_rows += valid_rows

#     if pipeline['stats']['failed'] == 0:
#         healthy_pipelines.append(pipeline['name'])

# print(f'Total valid rows: {total_valid_rows}')
# print(f'Healthy pipelines: {healthy_pipelines}')

# # Challenge 16 — вложенные циклы
# batches = [
#     [1200, 800, 0],
#     [500, 1500],
#     [0, 0, 2200]
# ]
# total_rows = 0
# processed_files = 0
# empty_files = 0

# for batch in batches:
#     for size in batch:
#         if size == 0:
#             empty_files += 1
#             continue

#         total_rows += size
#         processed_files += 1

# print(f'Total rows: {total_rows}')
# print(f'Processed files: {processed_files}')
# print(f'Empty files: {empty_files}')

# Final Challenge — маленькая обработка данных
orders = [
    {'id': 101, 'status': 'completed', 'amount': 1200},
    {'id': 102, 'status': 'failed', 'amount': 800},
    {'id': 103, 'status': 'completed', 'amount': None},
    {'id': 101, 'status': 'completed', 'amount': 1200},
    {'id': 104, 'status': 'completed', 'amount': 600},
    {'id': 105, 'status': 'cancelled', 'amount': 500},
    {'id': 106, 'status': 'completed'}
]

seen_ids = set()
duplicate_ids = set()
total_amount = 0
processed_orders = 0

for order in orders:
    if order['id'] in seen_ids:
        duplicate_ids.add(order['id'])
        continue

    seen_ids.add(order['id'])

    if order['status'] != 'completed' or order.get('amount') is None:
        continue

    total_amount += order['amount']
    processed_orders += 1

print(f'Total amount: {total_amount}')
print(f'Processed orders: {processed_orders}')
print(f'Duplicate IDs: {duplicate_ids}')

# Day 7 — Review завершён ✅

# Сегодня получилось прям полноценное повторение Days 1–6. По общей картине база уже заметно закрепилась: list, dict, nested dict, tuple, set, циклы, условия, .get(), проверки None, accumulators, поиск дублей, schema validation — большинство задач ты решал сразу.

# Основные ошибки сегодня были не синтаксические, а логические: в batching сначала считал от total_rows, хотя нужно было от valid_rows; с break сначала засчитал critical как успешный; в финальной задаче обнаружил duplicate, но не остановил обработку текущей записи. Это хороший тип ошибок для текущего этапа — Python ты уже пишешь, теперь тренируем порядок выполнения программы и бизнес-логику.

# Day 7 record: повторили Days 1–6; хорошо — collections, loops, conditions, nested data, sets/deduplication; повторить — continue/break, порядок проверок, выбор правильной переменной для расчёта.