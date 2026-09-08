# Практика — Task 1
# Представь, что у нас есть информация о загрузке данных.

pipeline_name = 'orders_daily'
rows_received = 12500
rows_invalid =  375
processing_time = 42.7
pipeline_success = True

print(pipeline_name, type(pipeline_name))
print(rows_received, type(rows_received))
print(rows_invalid, type(rows_invalid))
print(processing_time, type(processing_time))
print(pipeline_success, type(pipeline_success))

# Task 2 — арифметические операторы
# Теперь из этих же переменных посчитай:
# Количество валидных строк: полученные минус невалидные.
# Процент невалидных строк от общего количества.
# Сколько строк в среднем обрабатывалось за одну секунду, используя processing_time.
# Выведи все три результата через print().

valid_rows = rows_received - rows_invalid
invalid_rows_percentage = (rows_invalid / rows_received * 100)
rows_per_second = rows_received / processing_time

print(f'Valid rows: {valid_rows}')
print(f'Invalid rows percentage: {invalid_rows_percentage} %')
print(f'Rows processed per second: {rows_per_second}')

# Task 3 — /, // и %
# Тебе нужно самостоятельно определить:
# Сколько получится полных batch'ей по 1000 строк.
# Сколько строк останется после формирования полных batch'ей.
# Сколько batch'ей потребуется всего, если остаток тоже нужно отправить отдельным batch.
batch_size = 1000
number_of_batches = valid_rows // batch_size
remainder_number_of_rows = valid_rows % batch_size
total_batches  = (valid_rows + batch_size - 1) // batch_size

print(number_of_batches)
print(remainder_number_of_rows)
print(total_batches )

# Task 4 — типы и преобразования
# Теперь важная для DE ситуация: данные пришли из внешнего источника, и числа оказались строками:
rows_received = '12500'
rows_invalid = '375'
processing_time = '42.7'

rows_received = int(rows_received)
rows_invalid = int(rows_invalid)
processing_time = float(processing_time)

valid_rows = rows_received - rows_invalid
rows_per_second = rows_received / processing_time

print(valid_rows, type(valid_rows))
print(rows_per_second, type(rows_per_second))

# Task 5 — закрепление типов и операторов
# Последняя задача на сегодняшний блок, чуть более самостоятельная.
# Из API пришли такие значения:

total_rows = '23750'
failed_rows = '625'
batch_size = '2000'
processing_time = '95.5'

# Напиши код, который:
# Преобразует данные в подходящие числовые типы. +
# Считает количество успешных строк. +
# Считает процент failed rows. +
# Считает количество полных batch'ей из успешных строк. +
# Считает количество строк в остатке. +
# Считает общее количество необходимых batch'ей, включая неполный последний batch. +
# Считает количество обработанных строк в секунду.
# Выводит результаты понятными сообщениями через f-string.

total_rows = int(total_rows)
failed_rows = int(failed_rows)
batch_size = int(batch_size)
processing_time = float(processing_time)

successful_rows = total_rows - failed_rows
failed_rows_percentage = (failed_rows / total_rows * 100)
full_batches = successful_rows // batch_size
remainder_number_of_rows = successful_rows % batch_size
total_batches = (successful_rows + batch_size - 1) // batch_size
rows_per_second = (total_rows / processing_time)

print(f'Successful rows: {successful_rows}')
print(f'Failed rows percentage: {failed_rows_percentage}%')
print(f'Number of full batches: {full_batches}')
print(f'Rows not in batches: {remainder_number_of_rows}')
print(f'Number of total batches: {total_batches}')
print(f'Rows processed per second: {rows_per_second}')
