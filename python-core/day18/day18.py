import csv

# # with open('pipelines.csv', 'r') as file:
# #     content = csv.DictReader(file)
# # # Task 2 — преобразование типов    
# #     for row in content:
# #         converted_rows = int(row['rows'])
# #         converted_failed_rows = int(row['failed_rows'])
# #         valid_rows = converted_rows - converted_failed_rows
# #         print(f'{row['name']}: {valid_rows}')

# # Task 3 — собираем нормализованные записи
# processed_rows = []
# with open('pipelines.csv', 'r') as file:
#     content = csv.DictReader(file)
#     for row in content:
#         converted_rows = int(row['rows'])
#         converted_failed_rows = int(row['failed_rows'])
#         valid_rows = converted_rows - converted_failed_rows
#         processed_rows.append({
#             'name': row['name'],
#             'rows': converted_rows,
#             'failed_rows': converted_failed_rows,
#             'valid_rows': valid_rows
#         })

# print(processed_rows)

# # Task 4 — фильтрация
# healthy_pipelines = []

# for pipeline in processed_rows:
#     if pipeline['failed_rows'] <= 100:
#         healthy_pipelines.append(pipeline)

# print(healthy_pipelines)

# # Task 5 — записываем результат обратно в CSV
# with open('healthy_pipelines.csv', 'w', newline='') as file:
#     fieldnames = ['name', 'rows', 'failed_rows', 'valid_rows']
#     writer = csv.DictWriter(file, fieldnames=fieldnames)

#     writer.writerows(healthy_pipelines)

# # Task 1
# with open('pipelines.csv', 'r') as file:
#     data = csv.DictReader(file)

#     for row in data:
#         try:
#             rows = int(row['rows'])  
#             failed_rows = int(row['failed_rows'])
#             print(f'Valid: {row['name']}')
#         except ValueError:
#             print(f'Invalid: {row['name']}')

# # Task 2
# valid_records = []
# invalid_records = []

# with open('pipelines.csv', 'r') as file:
#     data = csv.DictReader(file)

#     for row in data:
#         try:
#             rows = int(row['rows'])  
#             failed_rows = int(row['failed_rows'])
#             valid_records.append(
#                 {
#                     'name': row['name'],
#                     'rows': rows,
#                     'failed_rows': failed_rows
#                 }
#             )
#         except ValueError:
#             invalid_records.append(row)

# print(valid_records)
# print(invalid_records)

# # Task 3
# valid_records = []
# invalid_records = []

# with open('pipelines.csv', 'r') as file:
#     data = csv.DictReader(file)

#     for row in data:
#         try:
#             rows = int(row['rows'])  
#             failed_rows = int(row['failed_rows'])
#             if rows <= 0 or failed_rows <0 or failed_rows > rows:
#                 invalid_records.append(row)
#             else:
#                 valid_records.append(
#                     {
#                         'name': row['name'],
#                         'rows': rows,
#                         'failed_rows': failed_rows
#                     }
#                 )
#         except ValueError:
#             invalid_records.append(row)

# print(valid_records)
# print(invalid_records)

# # Task 4
# valid_records = []
# invalid_records = []

# with open('pipelines.csv', 'r') as file:
#     data = csv.DictReader(file)

#     for row in data:
#         try:
#             rows = int(row['rows'])  
#             failed_rows = int(row['failed_rows'])
#             if rows <= 0 or failed_rows <0 or failed_rows > rows:
#                 invalid_records.append(
#                     {
#                         'name': row['name'],
#                         'error': 'Invalid row counts'
#                     }
#                 )
#             else:
#                 valid_records.append(
#                     {
#                         'name': row['name'],
#                         'rows': rows,
#                         'failed_rows': failed_rows
#                     }
#                 )
#         except ValueError:
#             invalid_records.append(
#                 {
#                     'name': row['name'],
#                     'error': 'Invalid numeric value'
#                 })

# print(valid_records)
# print(invalid_records)

# Task 5 — записываем clean и quarantine отдельно
# with open('valid_pipelines.csv', 'w', newline='') as file:
#     fieldnames = ['name', 'rows', 'failed_rows']
#     writer = csv.DictWriter(file, fieldnames=fieldnames)

#     writer.writeheader()
#     writer.writerows(valid_records)

# with open('invalid_pipelines.csv', 'w', newline='') as file:
#     fieldnames = ['name', 'error']
#     writer = csv.DictWriter(file, fieldnames=fieldnames)

#     writer.writeheader()
#     writer.writerows(invalid_records)

# Task 7
def read_and_validate_csv(file_path):
    valid_records = []
    invalid_records = []
    
    with open(file_path, 'r') as file:
        data = csv.DictReader(file)

        for row in data:
            try:
                rows = int(row['rows'])  
                failed_rows = int(row['failed_rows'])
            except ValueError:
                invalid_records.append(
                    {
                        'name': row['name'],
                        'error': 'Invalid numeric value'
                    })
                continue

            if rows <= 0 or failed_rows <0 or failed_rows > rows:
                invalid_records.append(
                    {
                        'name': row['name'],
                        'error': 'Invalid row counts'
                    }
                )
            else:
                valid_records.append(
                    {
                        'name': row['name'],
                        'rows': rows,
                        'failed_rows': failed_rows,
                        'valid_rows': rows - failed_rows
                    }
                )

    return valid_records, invalid_records

# Task 6 — выносим запись CSV в функцию
def write_csv(file_path, fieldnames, records):
    with open(file_path, 'w', newline='') as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)

        writer.writeheader()
        writer.writerows(records)

# # Task 8 - orchestration-часть
# try:
#     valid_records, invalid_records = read_and_validate_csv('pipelines.csv')
#     print('CSV successfully processed')
# except FileNotFoundError:
#     print('Input CSV not found')
# else:
#     write_csv(
#         'valid_pipelines.csv',
#         ['name', 'rows', 'failed_rows', 'valid_rows'],
#         valid_records
#     )

#     write_csv(
#         'invalid_pipelines.csv',
#         ['name', 'error'],
#         invalid_records
#     )

# Task 12 — финальная на Day 18
def process_csv(input_path, valid_output_path, invalid_output_path):
    try:
        valid_records, invalid_records = read_and_validate_csv(input_path)
    except FileNotFoundError:
        print('Input CSV not found')
    else:
        write_csv(
            valid_output_path,
            ['name', 'rows', 'failed_rows', 'valid_rows'],
            valid_records
        )
        
        write_csv(
            invalid_output_path,
            ['name', 'error'],
            invalid_records
        )
        print('CSV successfully processed')

process_csv('pipelines.csv', 'valid_pipelines.csv', 'invalid_pipelines.csv')