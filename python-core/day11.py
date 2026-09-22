# # Task 2 — напиши первый try / except
# rows = 0
# failed_rows = 100

# try:
#     failure_rate = failed_rows / rows * 100
#     print(f'Failure rate: {failure_rate}')
# except ZeroDivisionError:
#     print('Cannot calculate failure rate')

# # Task 3 — ловим KeyError
# pipeline = {
#     'name': 'orders'
# }

# try:
#     print(f'Rows: {pipeline['rows']}')
# except KeyError:
#     print('Missing rows field')

# # Task 5
# pipeline = {
#     'name': 'orders',
#     'rows': '5000'
# }

# try:
#     print(f'Rows: {int(pipeline['rows'])}')
# except KeyError:
#     print('Missing rows')
# except ValueError:
#     print('Invalid rows value')

# # # Task 6
# values = ['5000', '2500', 'unknown', '1200']

# # for value in values:
# #     try:
# #         converted = int(value)
# #         print(f'Converted: {converted}')
# #     except ValueError:
# #         print(f'Invalid value: {value}')

# # Task 7
# for value in values:
#     try:
#         converted = int(value)
#     except ValueError:
#         print(f'Invalid value: {value}')
#     else:
#         print(f'Converted: {converted}')

# Task 9 — безопасная обработка записей
pipelines = [
    {'name': 'orders', 'rows': '5000'},
    {'name': 'users', 'rows': 'unknown'},
    {'name': 'products'},
    {'name': 'events', 'rows': '2000'}
]

# valid_pipelines = []

# for pipeline in pipelines:
#     try:
#         converted = int(pipeline['rows'])
#     except KeyError:
#         continue
#     except ValueError:
#         continue
#     else:
#         valid_pipelines.append({'name': pipeline['name'], 'rows': converted})

# print(valid_pipelines)

# # Task 10
# # Перепиши предыдущий код так, чтобы вместо двух except был один:
# invalid_pipelines = []

# for pipeline in pipelines:
#     try:
#         converted = int(pipeline['rows'])
#     except (KeyError, ValueError):
#         invalid_pipelines.append(pipeline)
#     else:
#         valid_pipelines.append({'name': pipeline['name'], 'rows': converted})

# print(valid_pipelines)
# print(invalid_pipelines)

# # Task 11 — узнаём, какая именно ошибка произошла
# for pipeline in pipelines:
#     try:
#         converted = int(pipeline['rows'])
#     except (KeyError, ValueError) as error:
#         print(f'Invalid pipeline: {pipeline['name']}')
#         print(error)
#     else:
#         valid_pipelines.append({'name': pipeline['name'], 'rows': converted})

# # Task 12 — функция с exception handling
# def parse_rows(pipeline):
#     try: 
#         converted = int(pipeline['rows'])
#     except KeyError:
#         return None
#     except ValueError:
#         return None
#     else:
#         return converted


# print(parse_rows({'name': 'orders', 'rows': '5000'}))
# print(parse_rows({'name': 'users', 'rows': 'unknown'}))
# print(parse_rows({'name': 'products'}))

# # Task 13 — разные результаты для разных исключений
def parse_rows(pipeline):
    try: 
        converted = int(pipeline['rows'])
    except KeyError:
        return (None, 'Missing rows')
    except ValueError:
        return (None, 'Invalid rows value')
    else:
        return (converted, None)

# rows, error = parse_rows({'name': 'users', 'rows': 'unknown'})
# print(rows, error)

# # Task 14
# pipeline = {
#     'name': 'users',
#     'rows': 'unknown'
# }

# rows, error = parse_rows(pipeline)

# if error is None:
#     print(f'Rows: {rows}')
# else:
#     print(f'Error: {error}')

# Task 15
pipelines = [
    {'name': 'orders', 'rows': '5000'},
    {'name': 'users', 'rows': 'unknown'},
    {'name': 'products'},
    {'name': 'events', 'rows': '2000'}
]
valid_pipelines = []
invalid_pipelines = []

for pipeline in pipelines:
    rows, error = parse_rows(pipeline)
    if error is None:
        valid_pipelines.append({'name': pipeline['name'], 'rows': rows})
    else:
        invalid_pipelines.append({'name': pipeline['name'], 'error': error})

print(valid_pipelines)
print(invalid_pipelines)

# Day 11 — Exceptions ✅

# Сегодня разобрали try / except, конкретные KeyError, ValueError, ZeroDivisionError, несколько except, объединение исключений через tuple, except ... as error, а также else и finally. В конце связали exceptions с функциями и сделали маленький clean/quarantine flow.

# Главные ошибки сегодня были небольшие, но полезные: сначала в try не было операции, способной вызвать ValueError; один раз использовал сырые данные вместо результата функции; и была путаница между строкой 'error is None' и настоящим None.

# Особенно запомни две модели:

# try → exception → except → finally
# try → success   → else   → finally