# Python Core — Day 4: Lists.
# 0. Разминка Day 3
# batch_rows = [1000, 0, 1500, 0, 800, 2000]
# # За один for посчитай:
# # processed_rows — сумму строк непустых batch;
# # processed_batches — количество обработанных batch;
# # skipped_batches — количество нулевых batch.
# # При 0 используй continue.

# processed_rows = 0
# processed_batches = 0
# skipped_batches = 0

# for batch in batch_rows:
#     if batch == 0:
#         skipped_batches += 1
#         continue

#     processed_rows += batch
#     processed_batches += 1

# print(skipped_batches)
# print(processed_rows)
# print(processed_batches)

# # Task 1 — indexing + slicing

# pipelines = [
#     'orders',
#     'customers',
#     'payments',
#     'products',
#     'events'
# ]

# # Выведи первый pipeline.
# # Выведи последний pipeline, используя отрицательный индекс.
# # Выведи 'payments'.
# # Получи первые три pipeline через slicing и сохрани в first_three.
# # Получи последние два через slicing и сохрани в last_two.
# # Замени 'products' на 'inventory'.
# # Выведи весь изменённый pipelines.

# print(pipelines[0])
# print(pipelines[-1])
# print(pipelines[2])
# first_three = pipelines[0:3]
# last_two = pipelines[-2:]
# pipelines[3] = 'inventory'
# print(pipelines)

# # Task 2 — изменение списка

# files = ['orders.csv', 'users.csv', 'temp.csv']

# files.append('products.csv')
# files.append('events.csv')
# files.remove('temp.csv')
# removed_file = files.pop(-1)
# print(removed_files)
# print(files)
# print(len(files))
# if 'orders.csv' in files:
#     print('Orders file found')

# # Task 3 — filter into new list
# file_rows = [1200, 0, 850, 2400, 0, 1750, 600]
# non_empty_files = []

# for banana in file_rows:
#     if banana > 0:
#         non_empty_files.append(banana)

# print(f'Original: {file_rows}')
# print(f'Non-empty: {non_empty_files}')

# # Task 4 - transform into new list
# batch_rows = [1000, 1500, 800, 2000]
# rows_in_thousands = []

# for banana in batch_rows:
#     rows_in_thousands.append(banana / 1000)

# print(rows_in_thousands)

# # Task 5 — in + list
# required_files = [
#     'orders.csv',
#     'customers.csv',
#     'products.csv'
# ]

# received_files = [
#     'orders.csv',
#     'products.csv'
# ]

# for file in required_files:
#     if file not in received_files:
#         print(f'Missing: {file}')
#         continue
    
#     print(f'Found: {file}')

# # Task 6 — один 🙂
# statuses = ['success', 'failed', 'success', 'skipped', 'failed', 'success']
# successful_statuses = []
# problem_statuses = []

# for status in statuses:
#     if status == 'success':
#         successful_statuses.append(status)
#     else:
#         problem_statuses.append(status)

# print(successful_statuses)
# print(problem_statuses)

# # Task 8
# numbers = [2, 7, 4, 9, 12, 3, 8, 5]
# even_numbers = []

# for number in numbers:
#     if number % 2 == 0:
#         even_numbers.append(number)

# print(numbers)
# print(even_numbers)

# Task 9 — финальный на Day 4
file_sizes = [120, 850, 0, 1500, 300, 0, 2200, 90]
# Размеры файлов указаны в MB. 0 означает пустой файл.
valid_files = []
large_files = []

# За один for:
# пустые (0) полностью пропускай через continue;
# каждый непустой размер добавляй в valid_files;
# если размер больше 1000 MB, дополнительно добавляй его в large_files.

for file_size in file_sizes:
    if file_size == 0:
        continue

    valid_files.append(file_size)

    if file_size > 1000:
        large_files.append(file_size)

print(f'Valid files: {valid_files}')
print(f'Large files: {large_files}')
print(f'Number of valid files: {len(valid_files)}')
print(f'Number of large files: {len(large_files)}')