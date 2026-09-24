# Day 13 — Exceptions Part 3: raise
# Task 1 — первый raise
# def validate_batch_size(batch_size):
#     if batch_size <= 0:
#         raise ValueError('Batch size must be greater than zero')
    
#     return batch_size

# # Task 2 — теперь ловим собственный exception
# batch_sizes = [1000, 500, 0, 2000, -100]

# for batch_size in batch_sizes:
#     try:
#         validate_batch_size(batch_size)
#         print(f'Valid batch size: {batch_size}')
#     except ValueError as error:
#         print(f'Invalid batch size: {error}')

# # Task 3 — несколько правил → разные сообщения
# def validate_failed_rows(rows, failed_rows):
#     if rows <= 0:
#         raise ValueError('Rows must be greater than zero')
#     if failed_rows < 0:
#         raise ValueError('Failed rows cannot be negative')
#     if failed_rows > rows:
#         raise ValueError('Failed rows cannot exceed total rows')

#     return failed_rows

# # Task 5 — validation + calculation
# def calculate_valid_rows(rows, failed_rows):
#     validate_failed_rows(rows, failed_rows )
    
#     return rows - failed_rows

# # Task 6
# def build_summary(rows, failed_rows):
#     valid_rows = calculate_valid_rows(rows, failed_rows)

#     return {
#         'rows': rows,
#         'failed_rows': failed_rows,
#         'valid_rows': valid_rows
#     }

# # Task 8
# pipelines = [
#     {'name': 'orders', 'rows': 1000, 'failed_rows': 50},
#     {'name': 'users', 'rows': 2000, 'failed_rows': 2500},
#     {'name': 'events', 'rows': 1500, 'failed_rows': 0},
#     {'name': 'payments', 'rows': 1000, 'failed_rows': -10}
# ]

# def process_pipelines(pipelines):
#     clean = []
#     quarantine = []

#     for pipeline in pipelines:
#         try: 
#             summary = build_summary(pipeline['rows'], pipeline['failed_rows'])
#             clean.append(summary)
#         except ValueError as error:
#             quarantine.append({
#                 'name': pipeline['name'],
#                 'error': str(error)
#             })

#     return clean, quarantine

# clean, quarantine = process_pipelines(pipelines)

# print(clean)
# print(quarantine)

# # Task 11 — raise после преобразования
# def parse_positive_rows(value):
#     converted = int(value)

#     if converted <= 0:
#         raise ValueError('Rows must be positive')

#     return converted

# # Task 12 — поймай оба типа
# values = ['5000', 'unknown', '-100', None, '2500']

# valid_rows = []
# errors = []

# for value in values:
#     try:
#         converted = parse_positive_rows(value)
#         valid_rows.append(converted)
#     except (ValueError, TypeError) as error:
#         errors.append({
#             'value': value,
#             'error': str(error)
#         })

# print(valid_rows)
# print(errors)

# Day 13 — Exceptions закрыты ✅

# За Days 11–13 ты прошёл try / except, конкретные типы исключений, несколько except, объединение типов, as error, else, finally, raise, распространение exception через цепочку функций и выбор уровня, на котором ошибку имеет смысл ловить.

# И главное — уже есть нормальная модель:

# ожидаемое бизнес-ветвление → if
# техническая ошибка операции → exception
# нарушение обязательного контракта → можем raise
# ошибку ловим там, где знаем, что с ней делать

# На этом не надо ещё неделю долбить exceptions отдельно. Дальше они просто будут регулярно появляться в практических задачах.