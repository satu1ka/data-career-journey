# 0. Разминка — conditions
pipeline_status = 'completed'
rows_received = 12000
rows_loaded = 12000
failed_rows = 40

if pipeline_status != 'completed' or failed_rows > 500:
    print('CRITICAL')
elif rows_received != rows_loaded or failed_rows > 0:
    print('WARNING')
else:
    print('PERFECT')

# Task 1 - first for
file_rows = [1200, 850, 2400, 1750, 900]

for rows in file_rows:
    print(f'Rows in file: {rows}')
print('Finished')

# Task 2 — for + if
for rows in file_rows:
    if rows >= 1000:
        print(f'Large file: {rows} rows')
    else:
        print(f'Small file: {rows} rows')

# 3. Accumulator — очень важный паттерн
# Частая задача: пройти по набору значений и что-нибудь накопить.

# Task 3 — accumulator + counter
# За один for посчитай:
# Общее количество строк во всех файлах → total_rows.
# Количество больших файлов (>= 1000) → large_files.
# Количество маленьких файлов (< 1000) → small_files.
total_rows = 0
large_files = 0
small_files = 0

for rows in file_rows:
    total_rows += rows
    if rows >= 1000:
        large_files += 1 
    else:
        small_files += 1

print(total_rows)
print(large_files)
print(small_files)

# Task 4 — только range()
for batch_numbers in range(1, 6):
    print(f'Batch {rows}')

# Task 5 — continue
# Напиши цикл, который:
# если rows == 0 → выводит 'Empty file skipped';
# после этого через continue переходит к следующему элементу;
# для нормальных файлов выводит 'Processing X rows'.
file_rows = [1200, 0, 850, 0, 2400, 1750]
for rows in file_rows:
    if rows == 0:
        print('Empty file skipped')
        continue
    print(f'Processing {rows} rows')

# Task 6 — break
# Иди по списку и:
# для нормального batch выводи 'Processed X rows';
# при -1 выведи 'Critical batch error';
# после этого полностью останови цикл через break.
batch_rows = [1000, 1000, 1000, -1, 1000, 1000]
for batch in batch_rows:
    if batch < 0:
        print('Critical batch error')
        break
    print(f'Processed {batch} rows')

# Task 7 — первый while
rows_remaining = 5000
while rows_remaining > 0:
    print(f'Rows remaining: {rows_remaining}')
    rows_remaining -= 1000
    
print('Processing finished')

# Task 8 — while + counter
batch_number = 1
total_batches = 5
while batch_number <= total_batches:
    print(f'Processing batch {batch_number}')
    batch_number += 1

print('All batches processed')

# Финальная задача Day 3
file_rows = [1200, 0, 850, 2400, 0, 1750, 600]

# 0 означает пустой файл, который мы не обрабатываем.
# За один цикл for нужно посчитать:
# total_processed_rows — сколько строк реально обработали;
# processed_files — сколько файлов обработали;
# skipped_files — сколько пустых файлов пропустили;
# large_files — сколько среди обработанных файлов имели >= 1000 строк.
# При встрече 0:
# Skipped empty file
# и обязательно используй continue.
# Для нормального файла:
# Processing 1200 rows

total_processed_rows= 0
processed_files = 0
skipped_files = 0
large_files = 0

for rows in file_rows:
    if rows == 0: 
        skipped_files += 1
        print('Skipped empty file')
        continue

    total_processed_rows += rows
    processed_files += 1
    print(f'Processing {rows} rows')

    if rows >= 1000:
        large_files += 1

print('Processing finished')
print(f'Total processed rows: {total_processed_rows}')
print(f'Processed files: {processed_files}')
print(f'Skipped files: {skipped_files}')
print(f'Large files: {large_files}')
