# JSON — JavaScript Object Notation
# JSON — текстовый формат хранения и передачи структурированных данных.
# Quest 2 — Reading JSON
import json

with open('pipelines.json', 'r') as file:
    data = json.load(file)

# print(data)
# print(type(data))
# print(type(data[0]))
# print(type(data[0]['rows']))
# print(type(data[0]['active']))
# print(type(data[2]['rows']))

# # Quest 3 — Filtering JSON Data
# active_pipelines = []

# for pipeline in data:
#     if pipeline['active']:
#         active_pipelines.append(pipeline['name'])

# print(active_pipelines)

# # Quest 4 — Aggregation
# total_rows = 0
# total_failed_rows = 0

# for pipeline in data:
#     if pipeline['rows'] is None:
#         continue
#     total_rows += pipeline['rows']
#     total_failed_rows += pipeline['failed_rows']

# print(f'Total rows: {total_rows}')
# print(f'Total failed rows: {total_failed_rows}')

# # Quest 6 — Type Validation in Practice
# total_rows = 0
# total_failed_rows = 0

# for pipeline in data:
#     if not isinstance(pipeline['rows'], int) or not isinstance(pipeline['failed_rows'], int):
#         continue
#     total_rows += pipeline['rows']
#     total_failed_rows += pipeline['failed_rows']

# print(f'Total rows: {total_rows}')
# print(f'Total failed rows: {total_failed_rows}')

# # Quest 7 — Type Validation: Boolean Edge Case
# total_rows = 0
# total_failed_rows = 0

# for pipeline in data:
#     if (
#          type(pipeline['rows']) is not int
#         or type(pipeline['failed_rows']) is not int
#     ):
#         continue
#     total_rows += pipeline['rows']
#     total_failed_rows += pipeline['failed_rows']

# print(f'Total rows: {total_rows}')
# print(f'Total failed rows: {total_failed_rows}')

# # Quest 9 — Schema Validation
# total_rows = 0
# total_failed_rows = 0
# required_keys = {'name', 'rows', 'failed_rows', 'active'}

# for pipeline in data:
#     columns_name = set(pipeline)
#     difference = required_keys - columns_name
#     if difference:
#         continue
#     if (
#          type(pipeline['rows']) is not int
#         or type(pipeline['failed_rows']) is not int
#     ):
#         continue
#     total_rows += pipeline['rows']
#     total_failed_rows += pipeline['failed_rows']

# print(f'Total rows: {total_rows}')
# print(f'Total failed rows: {total_failed_rows}')

# Quest 10 — Business Validation + clean/quarantine
total_rows = 0
total_failed_rows = 0
clean_pipelines = []
quarantine_pipelines = []
required_keys = {'name', 'rows', 'failed_rows', 'active'}

for pipeline in data:
    columns_name = set(pipeline)
    difference = required_keys - columns_name
    if difference:
        quarantine_pipelines.append(pipeline)
        continue
    if (
         type(pipeline['rows']) is not int
        or type(pipeline['failed_rows']) is not int
    ):
        quarantine_pipelines.append(pipeline)
        continue
    if (
        pipeline['rows'] < 0 
        or pipeline['failed_rows'] < 0
        or pipeline['failed_rows'] > pipeline['rows']
    ):
        quarantine_pipelines.append(pipeline)
        continue
    clean_pipelines.append(pipeline)
    total_rows += pipeline['rows']
    total_failed_rows += pipeline['failed_rows']

print(f'Total rows: {total_rows}')
print(f'Total failed rows: {total_failed_rows}')
print(f'Clean records: {len(clean_pipelines)}')
print(f'Quarantine records: {len(quarantine_pipelines)}')
print(clean_pipelines)
print(quarantine_pipelines)