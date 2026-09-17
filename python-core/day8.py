# Functions
# def calculate_revenue(price, quantity):
#     result = price * quantity

#     return result

# total_revenue = calculate_revenue(125, 8)

# print(f'Total revenue: {total_revenue}')
# Task 2 — несколько вызовов одной функции
# products = [
#     {'name': 'Keyboard', 'price': 120, 'quantity': 3},
#     {'name': 'Mouse', 'price': 50, 'quantity': 5},
#     {'name': 'Monitor', 'price': 400, 'quantity': 2}
# ]

# for product in products:
#     revenue = calculate_revenue(product['price'], product['quantity'])
#     print(f'{product['name']}: {revenue}')

# # Task 3 — return vs print
# def calculate_valid_rows(rows, failed_rows):
#     valid_rows = rows - failed_rows

#     return valid_rows

# valid_rows = calculate_valid_rows(5000, 125)

# if valid_rows >= 4500:
#     print('Large valid dataset')
# else:
#     print('Small valid dataset')

# # Task 4 — early return
# def get_pipeline_status(rows, failed_rows):
#     if failed_rows is None:
#         return 'UNKNOWN'
#     if failed_rows > 500:
#         return 'CRITICAL'
#     if failed_rows > 0:
#         return 'WARNING'

#     return 'PERFECT'

# print(get_pipeline_status(10000, None))
# print(get_pipeline_status(10000, 700))
# print(get_pipeline_status(10000, 250))
# print(get_pipeline_status(10000, 0))

# # Task 5 — функция + validation
# def calculate_success_rate(total_rows, failed_rows):
#     if total_rows <= 0:
#         return None
#     if failed_rows is None:
#         return None

#     successful_rows_percentage = (total_rows - failed_rows) / total_rows * 100

#     return successful_rows_percentage

# rate = calculate_success_rate(10000, 250)
# print(rate)

# Task 6 — default parameter
# Можно задать параметру значение по умолчанию:
# def calculate_price(price, discount=0):
#     return price - price * discount
# Тогда оба вызова допустимы:
# calculate_price(100)       # discount = 0
# calculate_price(100, 0.2)  # discount = 0.2

# def calculate_batch_count(rows, batch_size=1000):
#     batch_count = (rows + batch_size - 1) // batch_size

#     return batch_count

# default_batches = calculate_batch_count(4500)
# custom_batches = calculate_batch_count(4500, 2000)

# print(default_batches)
# print(custom_batches)

# # Task 7 — keyword arguments
# def calculate_load_time(rows, rows_per_second=1000):
#     return rows / rows_per_second

# rows = 15000
# rows_per_second = 2500

# load_time = calculate_load_time(
#     rows_per_second = rows_per_second,
#     rows = rows
# )

# print(f'Load time: {load_time}')

# # Task 8 — закрепим это на практике
# def create_pipeline_config(name, source, batch_size=1000, retries=3):
#     config = {
#         'name': name,
#         'source': source,
#         'batch_size': batch_size,
#         'retries': retries
#     }

#     return config

# pipeline_config = create_pipeline_config(
#     'name',
#     'source',
#     retries=5
# )

# print(pipeline_config)

# # Task 9 — функция возвращает несколько значений
# # Функция может вернуть несколько значений:
# # def calculate(a, b):
# #     return a + b, a - b
# # А результат можно сразу распаковать:
# # sum_result, difference = calculate(10, 3)
# def get_row_stats(total_rows, failed_rows):
#     valid_rows = total_rows - failed_rows
#     failed_percentage = failed_rows / total_rows * 100
#     return valid_rows, failed_percentage

# valid_rows, failed_percentage = get_row_stats(10000, 250)
# print(valid_rows)
# print(failed_percentage)

# # Task 10 — функция + цикл внутри
# def calculate_total_rows(file_sizes):
#     total_rows = 0
#     for file_size in file_sizes:
#         if file_size <= 0:
#             continue

#         total_rows += file_size

#     return total_rows

# file_sizes = [1200, 0, 850, -1, 2400, 1500]
# total_rows = calculate_total_rows(file_sizes)

# print(f'Total rows: {total_rows}')

# # Task 11 — функция + dict + несколько return
# record = {
#     'id': 101,
#     'rows': 1500,
#     'failed_rows': 25
# }

# # Правила:
# # если 'rows' отсутствует или равен None → вернуть None;
# # если 'failed_rows' отсутствует или равен None → вернуть None;
# # иначе посчитать valid_rows;
# # вернуть новый dict:

# def process_record(record):
#     if record.get('rows') is None:
#         return None
#     if record.get('failed_rows') is None:
#         return None

#     valid_rows = record['rows'] - record['failed_rows']

#     new_dict = {
#         'id': record['id'], 
#         'valid_rows': valid_rows
#     }

#     return new_dict


# result = process_record(record)

# print(result)
# print(record)

# # Task 12 — функция внутри функции
# def calculate_valid_rows(rows, failed_rows):
#     return rows - failed_rows

# def build_pipeline_summary(name, rows, failed_rows):
#     if failed_rows is None:
#         return None
#     valid_rows = calculate_valid_rows(rows, failed_rows)

#     pipeline_summary = {
#         'name': name,
#         'rows': rows,
#         'failed_rows': failed_rows,
#         'valid_rows': valid_rows
#     }

#     return pipeline_summary

# summary = build_pipeline_summary('orders', 10000, 250)
# print(summary)

# # Task 20 — закрепляем functions + mutability кодом
# pipeline = {
#     'name': 'orders',
#     'rows': 10000,
#     'failed_rows': 250
# }

# def create_enriched_pipeline(pipeline):
#     new_dict = {
#         'name': pipeline['name'],
#         'rows': pipeline['rows'],
#         'failed_rows': pipeline['failed_rows'],
#         'valid_rows': pipeline['rows'] - pipeline['failed_rows']
#     }

#     return new_dict

# enriched_pipeline = create_enriched_pipeline(pipeline)

# print(pipeline)
# print(enriched_pipeline)

# # Task 21 — функция обработки списка записей
# records = [
#     {'id': 1, 'rows': 1200, 'failed_rows': 20},
#     {'id': 2, 'rows': 800, 'failed_rows': 0},
#     {'id': 3, 'rows': 1500, 'failed_rows': None},
#     {'id': 4, 'rows': 0, 'failed_rows': 0},
#     {'id': 5, 'rows': 2000, 'failed_rows': 100}
# ]

# def calculate_dataset_stats(records):
#     valid_rows = 0
#     processed_records = 0
#     for record in records:
#         if record['rows'] <= 0:
#             continue
#         if record.get('failed_rows') is None:
#             continue

#         valid_rows += record['rows'] - record['failed_rows']
#         processed_records += 1

#     return valid_rows, processed_records

# total_valid_rows, processed_records = calculate_dataset_stats(records)

# print(f'Total valid rows: {total_valid_rows}')
# print(f'Processed records: {processed_records}')

# # Task 24 — напиши сам
# numbers = [10, 20, 30, 40]

# def calculate_average(values):
#     if not values:
#         return
    
#     numbers_sum = 0

#     for number in values:
#         numbers_sum += number

#     average = numbers_sum / len(values)

#     return average

# average = calculate_average(numbers)

# print(average)

# Task 25 — небольшая самостоятельная функция
pipelines = [
    {'name': 'orders', 'failed_rows': 0},
    {'name': 'users', 'failed_rows': 25},
    {'name': 'products', 'failed_rows': None},
    {'name': 'events'},
    {'name': 'payments', 'failed_rows': 100}
]

def get_problem_pipelines(pipelines):
    failed_pipelines = []
    for pipeline in pipelines:
        if pipeline.get('failed_rows') is None or pipeline['failed_rows'] == 0:
            continue
    
        failed_pipelines.append(pipeline['name'])

    return failed_pipelines

problem_pipelines = get_problem_pipelines(pipelines)

print(problem_pipelines)

# Day 8 — Functions завершён

# Сегодня хорошо продвинулись. Прошли def, параметры и аргументы, return, early return, default parameters, keyword arguments, возврат нескольких значений и unpacking, вызов одной функции из другой, scope, отличие mutation от reassignment для mutable/immutable объектов, неявный return None, функции с циклами, словарями и списками.

# Основные моменты, где сегодня спотыкались: иногда внутри функции обращался к глобальной переменной вместо параметра; return сначала забывался; None и пустая коллекция — разные вещи; закрепили if not values:; и важная штука — dict/list могут измениться внутри функции, если мутировать сам объект.

# На сегодня достаточно. Завтра продолжим Day 9 — Functions, но уже почти без базовой теории: больше самостоятельных задач на проектирование небольших функций, validation, composition и обработку данных. Потом двинемся дальше по Python Core.