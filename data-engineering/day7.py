# Day 7 — Data Cleaning: from dirty data to clean data
# Part 1 — Data Quality warm-up
import pandas as pd

df = pd.read_csv('sales.csv')

records_count = df['order_id'].count()

missing_price = df[df['price'].isna()]
missing_price_count = missing_price['order_id'].count()

duplicate_rows = df[df['order_id'].duplicated(keep=False)]
duplicate_rows_count = duplicate_rows['order_id'].count()

print('=== DATA QUALITY REPORT ===')
print(f'Total records: {records_count}')
print(f'Missing price: {missing_price_count}')
print(f'Duplicate rows: {duplicate_rows_count}')

# Part 2 — .drop_duplicates()
without_duplicates = df.drop_duplicates(
    subset=['order_id']
)

before_cleaning = df['order_id'].count()
after_cleaning = without_duplicates['order_id'].count()
removed_duplicates = before_cleaning - after_cleaning

print(before_cleaning)
print(after_cleaning)
print(removed_duplicates)

# Part 2.1 Маленькая задача
# Представим, что мы точно знаем бизнес-правило:
# В sales.csv записи приходят строго хронологически. Если order_id повторяется, более поздняя строка содержит актуальное состояние заказа.

# without_duplicates = df.drop_duplicates(
#     subset=['order_id'],
#     keep='last'
# )

# Part 3 — .fillna()
# Добавили в sales.csv новую колонку discount.
df['discount'] = [
    0, 10, 0, 20, None, 0,
    15, 0, 10, 0, None, 0
]

# Проверяем, где у нас нет значения в 'discount'
# missing_discount = df[df['discount'].isna()]
# missing_discount_count = missing_discount['order_id'].count()
# альтернативный более адекватный вариант, который объединяет 2 строки выше
missing_discount_count = df['discount'].isna().sum()

# создаем копию df и заменяем None на 0 в столбце discount
clean_discount = df.copy()
clean_discount['discount'] = clean_discount['discount'].fillna(0)

# clean_missing_discount = clean_discount[clean_discount['discount'].isna()]
# missing_clean_discount_count = clean_missing_discount['order_id'].count()
# тоже самое, что и выше, объединение 2х строк в более короткую одну
missing_clean_discount_count = (clean_discount['discount'].isna().sum())

clean_discount['final_price'] = clean_discount['price'] * (1 - clean_discount['discount'] / 100)

print(f'Missing discounts before: {missing_discount_count}')
print(f'Missing discounts after: {missing_clean_discount_count}')

# Part 4 - clean_orders и quarantine_orders

# Создаем условие при котором наша строка становится "сомнительной"
invalid_condition = (
    clean_discount['price'].isna() |
    clean_discount['quantity'].isna() |
    clean_discount['order_id'].duplicated(keep=False)
)

# создаем DF в котором строчки удовлетворяют нашему invalid_condition
quarantine_orders = clean_discount[
    invalid_condition
].copy()
quarantine_orders_count = quarantine_orders['order_id'].count()

# создаем DF с чистыми значениями, которые не попадают в invalid_condition
clean_orders = clean_discount[
    ~invalid_condition
].copy()
clean_orders_count = clean_orders['order_id'].count()

# Выводим все в терминал
print('=== CLEAN ORDERS ===')
print(clean_orders)
print('\n=== QUARANTINE ORDERS ===')
print(quarantine_orders)
print(f'Clean records: {clean_orders_count}')
print(f'Quarantine records: {quarantine_orders_count}')

# Part 5 — RAW → CLEAN → BUSINESS RESULT
business_orders = clean_orders[
    (clean_orders['store'] == 'Store_A') &
    (clean_orders['status'] == "completed")
].copy()

business_orders['revenue'] = business_orders['quantity'] * business_orders['final_price']

total_revenue = business_orders['revenue'].sum()
orders_count = business_orders['order_id'].count()
aov = round(total_revenue / orders_count, 2)

raw_records_count = df['order_id'].count()
clean_records_count = clean_orders['order_id'].count()
quarantine_orders_count = quarantine_orders['order_id'].count()

print('=== PIPELINE SUMMARY ===')
print(f'Raw records: {raw_records_count}')
print(f'Clean records: {clean_records_count}')
print(f'Quarantine records: {quarantine_orders_count}')

print('\n=== BUSINESS RESULT ===')
print(f'Total revenue: {total_revenue}')
print(f'Orders: {orders_count}')
print(f'AOV: {aov}')