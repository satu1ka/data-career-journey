# Part 1
# Найти completed orders из Store_A, посчитать revenue и вывести Top 3 products by revenue.
import pandas as pd

df = pd.read_csv('sales.csv')

orders = df[
    (df['status'] == 'completed') &
    (df['store'] == 'Store_A')
].copy()

orders['revenue'] = orders['price'] * orders['quantity']

revenue_by_products = (
    orders.groupby('product')['revenue']
    .sum()
    .sort_values(ascending=False)
    .head(3)
)

print(revenue_by_products)

# Part 2
# Найди все строки, где отсутствует price.
# Сохрани их в DataFrame missing_price.
# Выведи их.
# Посчитай, сколько таких записей.

missing_price = df[
    df['price'].isna()
]

missing_price_count = df['price'].isna().sum()

print(missing_price)
print(f'Missing price count: {missing_price_count}')

# Part 3
# разделяем valid / invalid data

valid_orders = df[
    (df['price'].notna()) &
    (df['quantity'].notna())
]

invalid_orders = df[
    (df['price'].isna()) |
    (df['quantity'].isna())
]

print(valid_orders)
print(invalid_orders)

# Part 5
# Data Quality Report
# Нужно получить:
# Total records: 11
# Valid records: 10
# Invalid records: 1

total_records = (
    df['order_id'].count()
)

valid_records = (
    valid_orders['order_id'].count()
)
invalid_records_count = (
    invalid_orders['order_id'].count()
)

print(f'Total records: {total_records}')
print(f'Valid records: {valid_records}')
print(f'Invalid records: {invalid_records_count}')

# Part 6.1
# Дупликаты в таблице

duplicate_orders = df[
    df['order_id'].duplicated()
]

duplicate_count = (
    duplicate_orders['order_id'].count()
)

print(f'Duplicate orders: \n {duplicate_orders}')
print(f'Duplicate count: {duplicate_count}')

# Part 6.2
# Тож самое только вывести обе строки, которые повторяются:

duplicate_orders = df[
    df['order_id'].duplicated(keep=False)
]

print(f'Duplicate orders: \n {duplicate_orders}')

# Part 7
# Хочу получить примерно такой вывод:
# === DATA QUALITY REPORT ===
# Total records: 12
# Missing price: 1
# Duplicate rows: 2

total_records = df['order_id'].count()

missing_price_rows = df[
    df['price'].isna()
]

missing_price_count = missing_price_rows['order_id'].count()

duplicate_rows = df[
    df['order_id'].duplicated(keep=False)
]

duplicate_rows_count = duplicate_rows['order_id'].count()

print('=== DATA QUALITY REPORT ===')
print(f'Total records: {total_records}')
print(f'Missing price: {missing_price_count}')
print(f'Duplicate rows: {duplicate_rows_count}')