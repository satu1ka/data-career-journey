# File I/O
# Файл в Python открывается через open():
# file = open('data.txt', 'r')
# Но обычно используется более безопасный вариант:
# with open('data.txt', 'r') as file:
#     ...

# # Task 1
# with open('content.txt', 'r') as file:
#     content = file.read()

# print(content)
# print(type(content))

# # Task 2 — разбиваем файл на строки
# with open('content.txt', 'r') as file:
#     content = file.read()
#     # преобразование в список
#     # И важный момент: splitlines() превратил один многострочный str в list[str].
#     lines = content.splitlines()

# print(lines)
# print(type(lines))

# print(f'Name: {lines[0]}')
# print(f'Rows: {lines[1]}')
# print(f'Status: {lines[2]}')

# # Task 3 — чтение файла построчно
# with open('content.txt', 'r') as file:
#     for line in file:
#         line = line.strip()
#         print(f'Value: {line}')

# # Task 4 — запись в файл
# with open('result.txt', 'w') as file:
#     file.write('orders\n')
#     file.write('5000\n')
#     file.write('completed\n')

# # Task 5 — append
# with open('result.txt', 'a') as file:
#     file.write('failed_rows=100\n')
#     file.write('valid_rows=4900\n')

# # # Task 6 — собрать строки в список
# clean_lines = []

# with open('result.txt', 'r') as file:
#     for line in file:
#         line = line.strip()
#         clean_lines.append(line)

# # Task 7 — парсим строки key=value
# for line in clean_lines:
#     if '=' not in line:
#         continue
#     key, value = line.split('=')
#     print(f'{key} -> {value}')

# # Task 8 — собираем dict + преобразуем в инт
# stats = {}

# for line in clean_lines:
#     if '=' not in line:
#         continue
#     key, value = line.split('=')

#     stats[key] = int(value)

# print(stats)

# # Task 10 — плохое значение
# stats = {}

# for line in clean_lines:
#     if '=' not in line:
#         continue
#     key, value = line.split('=')

#     try:
#         stats[key] = int(value)
#     except ValueError:
#         continue

# print(stats)

# Task 11 — заворачиваем это в функцию
def read_stats(file_path):
    stats = {}

    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()

            if '=' not in line:
                continue

            key, value = line.split('=')

            try:
                stats[key] = int(value)
            except ValueError:
                continue

    return stats

kek = read_stats('result.txt')
print(kek)