# # Day 10 — Task 1: warm-up
# pipelines = [
#     {'name': 'orders', 'rows': 5000, 'failed_rows': 100},
#     {'name': 'users', 'rows': 3000, 'failed_rows': 0},
#     {'name': 'products', 'rows': None, 'failed_rows': 50},
#     {'name': 'events', 'rows': 2000, 'failed_rows': None},
#     {'name': 'payments', 'rows': 4500, 'failed_rows': 500}
# ]

# def calculate_valid_rows(pipeline):
#     if pipeline.get('rows') is None or pipeline.get('failed_rows') is None or pipeline['rows'] <= 0:
#         return None

#     return pipeline['rows'] - pipeline['failed_rows']

# def get_total_valid_rows(pipelines):
#     total_valid_rows = 0

#     for pipeline in pipelines:
#         valid_rows = calculate_valid_rows(pipeline)

#         if valid_rows is None:
#             continue

#         total_valid_rows += valid_rows

#     return total_valid_rows

# print(f'Total valid rows: {get_total_valid_rows(pipelines)}')

# # Task 2 — validation выносим в отдельную функцию
# def is_valid_pipeline(pipeline):
#     if pipeline.get('rows') is None or pipeline.get('failed_rows') is None or pipeline['rows'] <= 0 or pipeline['failed_rows'] < 0 or pipeline['failed_rows'] > pipeline['rows']:
#         return False

#     return True

# def calculate_valid_rows(pipeline):
#     if not is_valid_pipeline(pipeline):
#         return None

#     return pipeline['rows'] - pipeline['failed_rows']

# Task 4 — функция с причиной ошибки
def get_validation_error(pipeline):
    if pipeline.get('rows') is None:
        return 'Missing rows'
    if pipeline.get('failed_rows') is None:
        return 'Missing failed_rows'
    if pipeline['rows'] <= 0:
        return 'Invalid rows'
    if pipeline['failed_rows'] < 0:
        return 'Negative failed_rows'
    if pipeline['failed_rows'] > pipeline['rows']:
        return  'failed_rows exceeds rows'

    return None

# Task 5 — используем результат validation
def is_valid_pipeline(pipeline):
    return get_validation_error(pipeline) is None

# Task 6 — собираем validation report
pipelines = [
    {'name': 'orders', 'rows': 5000, 'failed_rows': 100},
    {'name': 'users', 'rows': 0, 'failed_rows': 0},
    {'name': 'products', 'rows': 2000, 'failed_rows': None},
    {'name': 'events', 'rows': 1000, 'failed_rows': 1200},
    {'name': 'payments', 'rows': 3000, 'failed_rows': 50}
]

# def build_validation_report(pipelines):
#     validation_report = []

#     for pipeline in pipelines:
#         error = get_validation_error(pipeline)
#         validation_report.append({
#             'name': pipeline['name'], 
#             'error': error
#         })

#     return validation_report

# validation_report = build_validation_report(pipelines)

# print(validation_report)

# Task 7 — функция с двумя результатами
def split_valid_pipelines(pipelines):
    valid_pipelines = []
    invalid_pipelines = []

    for pipeline in pipelines:
        error = get_validation_error(pipeline)
        if error is None:
            valid_pipelines.append(pipeline)
        else:
            invalid_pipelines.append({
                'name': pipeline['name'], 
                'error': error
            })

    return valid_pipelines, invalid_pipelines

# valid_pipelines, invalid_pipelines = split_valid_pipelines(pipelines)

# print('VALID:')
# print(valid_pipelines)

# print('INVALID:')
# print(invalid_pipelines)

# Task 8 — добавляем статистику DQ
# def build_dq_summary(pipelines):
#     valid_pipelines, invalid_pipelines = split_valid_pipelines(pipelines)

#     total = len(pipelines)
#     valid = len(valid_pipelines)
#     invalid = len(invalid_pipelines)

#     if total == 0:
#         valid_percentage = 0
#     else: 
#         valid_percentage = valid / total * 100 

#     return {
#         'total': total,
#         'valid': valid,
#         'invalid': invalid,
#         'valid_percentage': valid_percentage
#     }

# # summary = build_dq_summary(pipelines)
# # print(summary)

# Task 11 — теперь чуть меньше инструкций
def build_dq_summary(total, valid_pipelines, invalid_pipelines):
    valid = len(valid_pipelines)
    invalid = len(invalid_pipelines)

    if total == 0:
        valid_percentage = 0
    else: 
        valid_percentage = valid / total * 100 

    return {
        'total': total,
        'valid': valid,
        'invalid': invalid,
        'valid_percentage': valid_percentage
    }

def build_dq_report(pipelines):
    valid_pipelines, invalid_pipelines = split_valid_pipelines(pipelines)
    total = len(pipelines)

    summary = build_dq_summary(total, valid_pipelines, invalid_pipelines)
    
    return {
        'summary': summary,
        'invalid_records': invalid_pipelines
    }

print(build_dq_report(pipelines))

# Сегодня функции уже заметно ушли дальше простой механики def: validation вынесли отдельно, использовали функции как строительные блоки, сделали clean/quarantine-разделение, DQ summary/report, убрали дублирование вычислений и начали контролировать зависимости между функциями.

# Главные ошибки сегодня: один раз повторно вызвал функцию вместо использования сохранённого результата; перепутал valid/invalid при проверке error; в конце случайно вернулся к глобальному pipelines вместо параметра. Последнее особенно полезно поймать сейчас.

# На следующем новом занятии я бы Functions как отдельную тему закрыл. База уже достаточная, дальше функции будут постоянно использоваться в остальных темах. Следующий блок — Exceptions: try / except / else / finally, типы ошибок и нормальная обработка плохих входных данных.