# # Quest 1
# total_rows = '12750'
# failed_rows = '350'
# batch_size = '2000'
# processing_time = '25.5'

# total_rows = int(total_rows)
# failed_rows = int(failed_rows)
# batch_size = int(batch_size)
# processing_time = float(processing_time)

# valid_rows = total_rows - failed_rows
# failed_percentage = failed_rows / total_rows * 100
# number_of_full_batches = valid_rows // batch_size
# rows_out_of_batches = valid_rows % batch_size
# total_batches = (valid_rows + batch_size - 1) // batch_size
# rows_per_second = total_rows / processing_time

# print(valid_rows)
# print(failed_percentage)
# print(number_of_full_batches)
# print(rows_out_of_batches)
# print(total_batches)
# print(rows_per_second)

# # Quest 2 - Boolean
# pipeline_status = 'completed'
# rows_received = 10000
# rows_loaded = 9700
# failed_rows = 300

# if pipeline_status != 'completed' or failed_rows > 500:
#     print('CRITICAL')
# elif rows_received != rows_loaded or failed_rows >0:
#     print('WARNING')
# else:
#     print('PERFECT')

# # Quest 3 - Loops
# file_rows = [1200, 0, 850, 2400, 0, 1750]

# processed_files = 0
# skipped_files = 0
# total_processed_rows = 0

# for rows in file_rows:
#     if rows == 0:
#         skipped_files += 1
#         continue

#     processed_files += 1
#     total_processed_rows += rows

# print(processed_files)
# print(skipped_files)
# print(total_processed_rows)

# # Quest 4
# file_sizes = [120, 0, 850, 1500, 300, 0, 2200]

# valid_files = []
# large_files = []

# for file in file_sizes:
#     if file == 0:
#         continue

#     valid_files.append(file)
#     if file > 1000:
#         large_files.append(file)

# print(valid_files)
# print(large_files)

# # Quest 5
# pipeline = {
#     'name': 'orders',
#     'rows': 5000,
#     'failed_rows': None
# }

# rows = pipeline.get('rows')
# failed_rows = pipeline.get('failed_rows')

# print(rows)
# print(failed_rows)

# if failed_rows is None:
#     print('Missing failed_rows')
# else:
#     valid_rows = rows - failed_rows
#     print(valid_rows)

# # Quest 6
# order_ids = [101, 102, 103, 102, 104, 101, 105]

# seen_ids = set()
# duplicate_ids = set()

# for order_id in order_ids:
#     if order_id in seen_ids:
#         duplicate_ids.add(order_id)
#     else:
#         seen_ids.add(order_id)

# print(duplicate_ids)

# # Quest 7 — быстро проверим tuple
# pipeline_info = ('orders', 5000, 100)

# name, rows, failed_rows = pipeline_info

# valid_rows = rows - failed_rows
# print(f'{name} {valid_rows}')

# # Quest 8
# pipelines = [
#     {'name': 'orders', 'rows': 5000, 'failed_rows': 100},
#     {'name': 'users', 'rows': 3000, 'failed_rows': None},
#     {'name': 'events', 'rows': 2000, 'failed_rows': 50}
# ]

# def calculate_valid_rows(pipeline):
#     if pipeline.get('rows') is None:
#         return None
#     elif pipeline.get('failed_rows') is None:
#         return None
    
#     valid_rows = pipeline['rows'] - pipeline['failed_rows']

#     return valid_rows

# total_valid_rows = 0

# for pipeline in pipelines:
#     valid_rows = calculate_valid_rows(pipeline)
#     if valid_rows is None:
#         continue

#     total_valid_rows += valid_rows

# print(total_valid_rows)

# # Quest 11
# pipeline = {
#     'name': 'orders',
#     'rows': 5000,
#     'failed_rows': 100
# }

# def get_pipeline_stats(pipeline, min_rows=1000):
#     valid_rows = pipeline['rows'] - pipeline['failed_rows']
#     is_large = pipeline['rows'] >= min_rows
#     has_failures = pipeline['failed_rows'] > 0

#     return valid_rows, is_large, has_failures

# valid_rows, is_large, has_failures = get_pipeline_stats(pipeline, min_rows=1000)

# print(valid_rows)
# print(is_large)
# print(has_failures)

# # Quest 12
# pipeline = {
#     'name': 'orders',
#     'rows': 'adsf'
# }

# try:
#     rows = int(pipeline['rows'])
# except KeyError:
#     print('Missing rows')
# except ValueError:
#     print('Invalid rows value')
# else:
#     print(f'Rows: {rows}')

# Quest 14
def validate_rows(rows):
    if rows <= 0:
        raise ValueError('Rows must be greater than zero')

    return rows

# Quest 15 — ловим собственный raise
values = [5000, 0, -100, 2500]

for rows in values:
    try:
        validate_rows(rows)
        print(f'Valid rows: {rows}')
    except ValueError as error:
        print(f'Invalid rows: {error}')
