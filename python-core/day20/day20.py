import csv

# # Quest 1 — первое чтение CSV
# with open('pipelines.csv', 'r') as file:
#     reader = csv.DictReader(file)

#     for line in reader:
#         print(line)

# # Quest 2
# with open('pipelines.csv', 'r') as file:
#     reader = csv.DictReader(file)

#     for line in reader:
#         print(f'Name: {line['name']}')
#         print(f'Rows: {line['rows']}')
#         print(f'Failed rows: {line['failed_rows']}')

# # Quest 3
# with open('pipelines.csv', 'r') as file:
#     reader = csv.DictReader(file)

#     for line in reader:
#         line['rows'] = int(line['rows'])
#         line['failed_rows'] = int(line['failed_rows'])
#         print(line)

# print(type(line['rows']))
# print(type(line['failed_rows']))

# # Quest 4 — плохое числовое значение
# with open('pipelines.csv', 'r') as file:
#     reader = csv.DictReader(file)

#     for line in reader:
#         try:
#             line['rows'] = int(line['rows'])
#             line['failed_rows'] = int(line['failed_rows'])
#         except ValueError:
#             continue
#         print(line)

# # Quest 5 — не теряем плохие строки
# clean_rows = []
# quarantine_rows = []

# with open('pipelines.csv', 'r') as file:
#     reader = csv.DictReader(file)

#     for line in reader:
#         try:
#             line['rows'] = int(line['rows'])
#             line['failed_rows'] = int(line['failed_rows'])
#             clean_rows.append(line)
#         except ValueError:
#             quarantine_rows.append(line)
#             continue

# print(clean_rows)
# print(quarantine_rows)

# # Quest 6 — не мутируем строку до полной validation
# clean_rows = []
# quarantine_rows = []

# with open('pipelines.csv', 'r') as file:
#     reader = csv.DictReader(file)

#     for line in reader:
#         try:
#             rows = int(line['rows'])
#             failed_rows = int(line['failed_rows'])
#             line['rows'] = rows
#             line['failed_rows'] = failed_rows
#             clean_rows.append(line)
#         except ValueError:
#             quarantine_rows.append(line)

# print(clean_rows)
# print(quarantine_rows)

# # Quest 7 — Business Validation
# clean_rows = []
# quarantine_rows = []

# with open('pipelines.csv', 'r') as file:
#     reader = csv.DictReader(file)

#     for line in reader:
#         try:
#             rows = int(line['rows'])
#             failed_rows = int(line['failed_rows'])
#             if rows < 0 or failed_rows < 0 or failed_rows > rows:
#                 quarantine_rows.append(line)
#             else:
#                 line['rows'] = rows
#                 line['failed_rows'] = failed_rows
#                 clean_rows.append(line)
#         except ValueError:
#             quarantine_rows.append(line)

# print(len(clean_rows))
# print(len(quarantine_rows))

# Quest 8 — Function-based processing
def process_csv(file_path):
    clean_rows = []
    quarantine_rows = []

    with open(file_path, 'r') as file:
        reader = csv.DictReader(file)

        for line in reader:
            try:
                rows = int(line['rows'])
                failed_rows = int(line['failed_rows'])
                if rows < 0 or failed_rows < 0 or failed_rows > rows:
                    quarantine_rows.append(line)
                else:
                    line['rows'] = rows
                    line['failed_rows'] = failed_rows
                    clean_rows.append(line)
            except ValueError:
                quarantine_rows.append(line)

    return clean_rows, quarantine_rows

clean_rows, quarantine_rows = process_csv('pipelines.csv')

print(len(clean_rows))
print(len(quarantine_rows))