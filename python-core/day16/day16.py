# # Warm-up 1 — функция + raise + try/except
# values = ['5000', '0', 'unknown', '2500']

# def parse_rows(value):
#     converted = int(value)

#     if converted <= 0:
#         raise ValueError('Rows must be greater than zero')
    
#     return converted

# for value in values:
#     try:
#         converted_value = parse_rows(value)
#         print(f'Valid rows: {converted_value}')
#     except ValueError as error:
#         print(f'Invalid rows: {error}')

# Day 16 — File I/O
# with open('data.txt', 'r') as file:
#     content = file.read()

# print(content)

# # Task 1 — первое чтение файла
# with open('pipeline.txt', 'r') as file:
#     content = file.read()

# # print(content)
# # print(type(content))

# # # Task 2 — .splitlines()
# lines = content.splitlines()
# # print(lines)
# # print(type(lines))

# # print(f'Name: {lines[0]}')
# # print(f'Rows: {lines[1]}')
# # print(f'Status: {lines[2]}')

# # Task 3 — преобразование и безопасная обработка
# try: 
#     rows = int(lines[1])
#     print(f'Rows as int: {rows}')
# except ValueError:
#     print('Invalid rows value')

# # Task 4 — чтение файла построчно
# with open('pipeline.txt', 'r') as file:
#     for line in file:
#         line = line.strip()
#         print(f'Value: {line}')

# # Task 5 — запись в файл
# with open('pipeline_result.txt', 'w') as file:
#     file.write('orders\n')
#     file.write('5000\n')
#     file.write('completed\n')

# # Task 6 — append mode
# with open('pipeline_result.txt', 'a') as file:
#     file.write('failed_rows=100\n')
#     file.write('valid_rows=4900\n')

# # Task 7 — чтение + преобразование + новый файл
# with open('pipeline_result.txt', 'r') as file:
#     clean_lines = []
#     for line in file:
#         line = line.strip()
#         clean_lines.append(line)
# print(clean_lines)

# # # Task 8 — парсим строки key=value
# # for item in clean_lines:
# #     if '=' not in item:
# #         continue
    
# #     key, value = item.split('=')
# #     print(f'{key} -> {value}')

# # # Task 9 — собираем данные в dict
# # stats = {}
# # for item in clean_lines:
# #     if '=' not in item:
# #         continue
    
# #     key, value = item.split('=')
# #     stats[key] = value

# # print(stats)

# # # Task 10 — преобразуем значения в int
# # stats = {}
# # for item in clean_lines:
# #     if '=' not in item:
# #         continue
    
# #     key, value = item.split('=')
# #     stats[key] = int(value)

# # print(stats)

# # Task 11 — добавим обработку плохих данных
# stats = {}
# for item in clean_lines:
#     if '=' not in item:
#         continue
    
#     key, value = item.split('=')

#     try:
#         stats[key] = int(value)
#     except ValueError:
#         print(f'Invalid value for {key}')

# print(stats)

# Task 12 — маленькая финальная сборка
def read_stats(file_path):
    with open(file_path, 'r') as file:
        stats = {}

        for line in file:
            line = line.strip()

            if '=' not in line:
                continue

            key, value = line.split('=')

            try:
                stats[key] = int(value)
            except ValueError:
                pass

        return stats

stats = read_stats('pipeline_result.txt')
print(stats)


