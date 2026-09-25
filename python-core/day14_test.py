# # Challenge 1 — Functions & validation
# pipelines = [
#     {'name': 'orders', 'rows': 5000, 'failed_rows': 125},
#     {'name': 'users', 'rows': 3000, 'failed_rows': 0},
#     {'name': 'products', 'rows': 2000, 'failed_rows': 2500},
#     {'name': 'events', 'rows': 0, 'failed_rows': 0},
#     {'name': 'payments', 'rows': 4500, 'failed_rows': 250}
# ]

# def calculate_valid_rows(pipeline):
#     if pipeline.get('rows') is None or pipeline.get('failed_rows') is None:
#         return None

#     if pipeline['rows'] <= 0 or pipeline['failed_rows'] < 0 or pipeline['failed_rows'] > pipeline['rows']:
#         return None
    
#     return pipeline['rows'] - pipeline['failed_rows']


# total_valid_rows = 0

# for pipeline in pipelines:
#     valid_rows = calculate_valid_rows(pipeline)

#     if valid_rows is None:
#         continue

#     total_valid_rows += valid_rows

# print(total_valid_rows)

# # Challenge 3 — Functions + raise + обработка на верхнем уровне
# pipelines = [
#     {'name': 'orders', 'rows': 5000, 'failed_rows': 100},
#     {'name': 'users', 'rows': 0, 'failed_rows': 0},
#     {'name': 'products', 'rows': 2500, 'failed_rows': 3000},
#     {'name': 'events', 'rows': 2000, 'failed_rows': 50}
# ]

# def validate_pipeline(pipeline):
#     if pipeline['rows'] <= 0:
#         raise ValueError('Invalid rows')
#     if pipeline['failed_rows'] < 0:
#         raise ValueError ('Invalid failed rows')
#     if pipeline['failed_rows'] > pipeline['rows']:
#         raise ValueError('Failed rows exceed rows')

#     return True

# def process_pipelines(pipelines):
#     valid = []
#     quarantine = []

#     for pipeline in pipelines:
#         try: 
#             validate_pipeline(pipeline)
#             valid.append(pipeline)
#         except ValueError as error:
#             quarantine.append({
#                 'name': pipeline['name'],
#                 'error': str(error)
#             })

#     return valid, quarantine

# valid, quarantine = process_pipelines(pipelines)
# print(valid)
# print(quarantine)

# # Challenge 4 — Function composition + None
# pipelines = [
#     {'name': 'orders', 'rows': 5000, 'failed_rows': 0},
#     {'name': 'users', 'rows': 2000, 'failed_rows': 100},
#     {'name': 'products', 'rows': 1000, 'failed_rows': 200},
#     {'name': 'events', 'rows': 0, 'failed_rows': 0},
#     {'name': 'payments', 'rows': None, 'failed_rows': 10}
# ]

# def calculate_failure_rate(pipeline):
#     rows = pipeline.get('rows')
#     failed_rows = pipeline.get('failed_rows')

#     if rows is None or failed_rows is None:
#         return None

#     if rows <= 0:
#         return None

#     return failed_rows / rows * 100

# def get_pipeline_status(pipeline):
#     rate = calculate_failure_rate(pipeline)
#     if rate is None:
#         return 'UNKNOWN'
#     if rate > 10:
#         return 'CRITICAL'
#     if rate > 0:
#         return 'WARNING'

#     return 'GOOD'

# for pipeline in pipelines:
#     status = get_pipeline_status(pipeline)
#     print(f'{pipeline['name']} {status}')

# # Challenge 5 — Default parameters + filtering
# pipelines = [
#     {'name': 'orders', 'rows': 5000, 'failed_rows': 50},
#     {'name': 'users', 'rows': 800, 'failed_rows': 0},
#     {'name': 'products', 'rows': 3000, 'failed_rows': 150},
#     {'name': 'events', 'rows': 2000, 'failed_rows': 25}
# ]

# def is_pipeline_healthy(pipeline, min_rows=1000, max_failed_rows=100):
#     if pipeline.get('rows') is None or pipeline.get('failed_rows') is None or pipeline['rows'] < min_rows or pipeline['failed_rows'] > max_failed_rows:
#         return False

#     return True

# healty_pipelines = []

# for pipeline in pipelines:
#     if is_pipeline_healthy(pipeline):
#         healty_pipelines.append(pipeline['name'])

# second_pipeline = []

# for pipeline in pipelines:
#     if is_pipeline_healthy(pipeline, min_rows=2000, max_failed_rows=50):
#         second_pipeline.append(pipeline['name'])

# print(healty_pipelines)
# print(second_pipeline)

# # Challenge 6 — return, mutability и новый объект
# pipeline = {
#     'name': 'orders',
#     'rows': 5000,
#     'failed_rows': 100
# }

# def enrich_pipeline(pipeline):
#     enriched_pipeline = pipeline.copy()
#     enriched_pipeline['valid_rows'] = pipeline['rows'] - pipeline['failed_rows']
    
#     return enriched_pipeline

# enriched = enrich_pipeline(pipeline)

# print(pipeline)
# print(enriched)

# Challenge 9 — исправление debugging-задачи
def process_pipeline(pipeline):
    try:
        valid_rows = pipeline['rows'] - pipeline['failed_rows']

        if valid_rows < 0:
            raise ValueError('Invalid valid_rows')

    except (KeyError, TypeError, ValueError) as error:
        return None, str(error)

    return valid_rows, None


pipeline = {
    'name': 'orders',
    'rows': 5000,
    'failed_rows': 6000
}

print(process_pipeline(pipeline))

# По результатам недели: функции и composition у тебя уже заметно увереннее; return, None, default/keyword arguments и передача результатов между функциями в целом норм; try/except и распространение исключений тоже усвоены. Два места, которые пока стоит держать в голове: mutation объекта vs reassignment локального имени — сегодня объяснение сначала было неточным; и raise vs except — в Challenge 9 сначала попытался проверять условие уже внутри except, хотя exception ещё нужно было создать самому.

# Ещё один повторяющийся момент с начала недели — вызов функции дважды вместо call → save → use. Сегодня ты его быстро исправил, так что прогресс здесь есть.

# В целом неделя закрыта нормально. Следующий учебный день начинаем уже с новой темы Python Core, а functions и exceptions дальше просто будут постоянно встречаться в задачах.