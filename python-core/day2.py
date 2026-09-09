# Warm-up
# total_rows = 18750
# batch_size = 2000

# full_batches = total_rows // batch_size
# rows_remain = total_rows % batch_size
# total_batches = (total_rows + batch_size - 1) // batch_size

# print(full_batches)
# print(rows_remain)
# print(total_batches)

# # Task 1
# rows_received = 15000
# rows_loaded = 14750
# failed_rows = 250
# max_failed_rows = 300
# pipeline_status = 'completed'

# # Создай четыре переменные типа bool:
# # Все ли полученные строки были загружены.
# # Не превышает ли количество failed rows допустимый максимум.
# # Равен ли pipeline_status строке 'completed'.
# # Есть ли вообще failed rows (failed_rows больше нуля).

# is_all_rows_loaded = rows_received == rows_loaded
# is_failed_rows_in_limit = failed_rows <= max_failed_rows
# is_pipeline_completed = pipeline_status == 'completed'
# is_failed_rows_exist = failed_rows > 0

# print(f'All rows loaded: {is_all_rows_loaded}')
# print(f'Failed rows within limit: {is_failed_rows_in_limit}')
# print(f'Pipeline completed: {is_pipeline_completed}')
# print(f'Has failed rows: {is_failed_rows_exist}')

# # Task 2 — Boolean logic
# is_pipeline_healthy = is_pipeline_completed and is_failed_rows_in_limit
# needs_attention = not is_all_rows_loaded or is_failed_rows_exist
# is_perfect_run = (
#     is_pipeline_completed 
#     and is_all_rows_loaded 
#     and not is_failed_rows_exist
# )
# has_no_failed_rows = not is_failed_rows_exist

# print(f'Pipeline healthy: {is_pipeline_healthy}')
# print(f'Pipeline needs attention: {needs_attention}')
# print(f'Perfect pipeline: {is_perfect_run}')
# print(f'Pipeline has no failed rows: {has_no_failed_rows}')

# # Task 3 — первый if
# failed_rows = 250

# if failed_rows > 0:
#     print('Pipeline has failed rows')
# else:
#     print('No failed rows')

# # Task 4 — if / elif / else
# failed_rows = 250

# if failed_rows == 0:
#     print('Pipeline status: PERFECT')
# elif (failed_rows >= 1) and (failed_rows <= 300):
#     print('Pipeline status: WARNING')
# else:
#     print('Pipeline status: CRITICAL')

# Task 5 — финальная на сегодня
rows_received = 10000
rows_loaded = 9700
failed_rows = 300
pipeline_status = 'completed'

if pipeline_status != 'completed' or failed_rows > 500:
    print('Final status: CRITICAL')
elif (rows_received != rows_loaded) or (failed_rows > 0):
    print('Final status: WARNING')
else:
    print('Final status: PERFECT')