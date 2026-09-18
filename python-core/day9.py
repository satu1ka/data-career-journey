# # Python Core — Day 9: Functions, Part 2.
# # Task 1 — Warm-up: validation + early return
# record = {
#     'name': 'orders',
#     'rows': 5000,
#     'failed_rows': 125
# }
# # Правила:
# # если rows отсутствует или равен None → вернуть None;
# # если failed_rows отсутствует или равен None → вернуть None;
# # если rows <= 0 → вернуть None;
# # иначе вернуть количество валидных строк:

# def calculate_valid_rows(record):
#     if record.get('rows') is None:
#         return None
#     if record.get('failed_rows') is None:
#         return None
#     if record['rows'] <= 0:
#         return None

#     return record['rows'] - record['failed_rows']

# # valid_rows = calculate_valid_rows(record)

# # print(f'Valid rows: {valid_rows}')

# # Task 2 — функция вызывает функцию

# records = [
#     {'name': 'orders', 'rows': 5000, 'failed_rows': 125},
#     {'name': 'users', 'rows': 3000, 'failed_rows': 0},
#     {'name': 'products', 'rows': 2000, 'failed_rows': None},
#     {'name': 'events', 'rows': 0, 'failed_rows': 0},
#     {'name': 'payments', 'rows': 4500, 'failed_rows': 250}
# ]

# def calculate_total_valid_rows(records):
#     total_valid_rows = 0

#     for record in records:
#         valid_rows = calculate_valid_rows(record)

#         if valid_rows is None:
#             continue

#         total_valid_rows += valid_rows

#     return total_valid_rows

# total_valid_rows = calculate_total_valid_rows(records)

# print(f'Total valid rows: {total_valid_rows}')

# # Task 3 — функция как фильтр
# pipelines = [
#     {'name': 'orders', 'rows': 5000, 'status': 'completed'},
#     {'name': 'users', 'rows': 800, 'status': 'completed'},
#     {'name': 'products', 'rows': 2500, 'status': 'failed'},
#     {'name': 'events', 'rows': 0, 'status': 'completed'},
#     {'name': 'payments', 'rows': 4200, 'status': 'completed'}
# ]

# def is_valid_pipeline(pipeline):
#     # if pipeline['status'] == 'completed' and pipeline['rows'] > 0:
#     #     return True
#     # else:
#     #     return False
#     return pipeline['status'] == 'completed' and pipeline['rows'] > 0
    
# # for pipeline in pipelines:
# #     print(pipeline['name'], is_valid_pipeline(pipeline))

# # Task 4 — используем boolean-функцию
# def get_valid_pipeline_names(pipelines):
#     valid_names = []

#     for pipeline in pipelines:
#         if is_valid_pipeline(pipeline):
#             valid_names.append(pipeline['name'])

#     return valid_names

# valid_names = get_valid_pipeline_names(pipelines)
# print(valid_names)

# # Task 5 — default parameter + функция-фильтр
# pipeline = {
#     'name': 'orders',
#     'rows': 1500
# }

# def is_large_pipeline(pipeline, min_rows=1000):
#     return pipeline['rows'] >= min_rows

# print(is_large_pipeline(pipeline))
# print(is_large_pipeline(pipeline, 2000))
# print(is_large_pipeline(pipeline, min_rows=1500))

# # Task 6 — несколько default parameters
# pipeline = {
#     'name': 'orders',
#     'rows': 1500,
#     'failed_rows': 75
# }

# def is_pipeline_healthy(
#     pipeline,
#     max_failed_rows=100,
#     min_rows=1000
# ):
#     if pipeline.get('rows') is None or pipeline.get('failed_rows') is None:
#         return False
    
#     return pipeline['rows'] >= min_rows and pipeline['failed_rows'] <= max_failed_rows

# print(is_pipeline_healthy(pipeline))
# print(is_pipeline_healthy(pipeline, max_failed_rows=50))
# print(is_pipeline_healthy(pipeline, min_rows=2000))

# Task 9 — три функции в цепочке
# pipeline = {
#     'name': 'orders',
#     'rows': 10000,
#     'failed_rows': 250
# }

def calculate_failure_rate(rows, failed_rows):
    if rows <= 0:
        return None

    return failed_rows / rows * 100

def get_quality_status(pipeline):
    if pipeline.get('rows') is None or pipeline.get('failed_rows') is None:
        return 'UNKNOWN'

    failure_rate = calculate_failure_rate(pipeline['rows'], pipeline['failed_rows'])

    if failure_rate > 5:
        return 'BAD'
    if failure_rate > 0:
        return 'WARNING'
    return 'GOOD'

# status = get_quality_status(pipeline)
# print(status)

# финальная задача Day 9
pipelines = [
    {'name': 'orders', 'rows': 10000, 'failed_rows': 250},
    {'name': 'users', 'rows': 5000, 'failed_rows': 0},
    {'name': 'events', 'rows': 2000, 'failed_rows': 200},
    {'name': 'products', 'rows': None, 'failed_rows': None}
]

def get_pipeline_report(pipelines):
    report = []

    for pipeline in pipelines:
        quality_status = get_quality_status(pipeline)

        report.append({
            'name': pipeline['name'],
            'status': quality_status
        })

    return report

report = get_pipeline_report(pipelines)
print(report)

# Day 9 — закрыт ✅

# Сегодня закрепили return и early return, default/keyword parameters, boolean-функции, передачу None между функциями, сохранение результата функции вместо повторного вызова и главное — разбиение логики на небольшие функции и их композицию.

# Основные ошибки сегодня были уже не столько синтаксические: дважды вызвал calculate_valid_rows() вместо сохранения результата; один раз снова смешались print() и return; потребовалась подсказка с обработкой None между двумя функциями. Зато к концу ты самостоятельно увидел дублирование логики и нормально собрал цепочку из функций — это как раз то, что нам было нужно от Day 9.