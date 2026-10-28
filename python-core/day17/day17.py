import csv

# with open('pipelines.csv', 'r') as file:
#     content = csv.DictReader(file)
# # Task 2 — преобразование типов    
#     for row in content:
#         converted_rows = int(row['rows'])
#         converted_failed_rows = int(row['failed_rows'])
#         valid_rows = converted_rows - converted_failed_rows
#         print(f'{row['name']}: {valid_rows}')

# Task 3 — собираем нормализованные записи
processed_rows = []
with open('pipelines.csv', 'r') as file:
    content = csv.DictReader(file)
    for row in content:
        converted_rows = int(row['rows'])
        converted_failed_rows = int(row['failed_rows'])
        valid_rows = converted_rows - converted_failed_rows
        processed_rows.append({
            'name': row['name'],
            'rows': converted_rows,
            'failed_rows': converted_failed_rows,
            'valid_rows': valid_rows
        })

print(processed_rows)

# Task 4 — фильтрация
healthy_pipelines = []

for pipeline in processed_rows:
    if pipeline['failed_rows'] <= 100:
        healthy_pipelines.append(pipeline)

print(healthy_pipelines)

# Task 5 — записываем результат обратно в CSV
with open('healthy_pipelines.csv', 'w', newline='') as file:
    fieldnames = ['name', 'rows', 'failed_rows', 'valid_rows']
    writer = csv.DictWriter(file, fieldnames=fieldnames)

    writer.writerows(healthy_pipelines)