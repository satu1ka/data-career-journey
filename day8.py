# Part 1 — сначала разминка
# Есть sales.csv.
# Бизнес говорит:
# Для аналитики нужны только completed orders из Store_A. Записи с missing price, missing quantity или duplicate order_id использовать нельзя.

# import pandas as pd
# df = pd.read_csv('sales.csv')

# invalid_condition = (
#     df['price'].isna() |
#     df['quantity'].isna() |
#     df['order_id'].duplicated(keep=False)
# )

# quarantine_orders = df[
#     invalid_condition
# ].copy()

# clean_orders = df[
#     ~invalid_condition
# ].copy()

# business_orders = clean_orders[
#     (clean_orders['status'] == 'completed') &
#     (clean_orders['store'] == 'Store_A')
# ].copy()

# business_orders['revenue'] = business_orders['quantity'] * business_orders['price']
# business_orders_count = business_orders['order_id'].count()
# business_orders_total_revenue = business_orders['revenue'].sum()

# print('=== BUSINESS REPORT ===')
# print(f'Orders: {business_orders_count}')
# print(f'Total revenue: {business_orders_total_revenue}')

# Part 2 — первая твоя функция

# def calculate_order_revenue(price, quantity):
#     revenue = price * quantity
#     return revenue

# order_revenue = calculate_order_revenue(250, 4)

# print(order_revenue)

# Part 3 — первая функция с pandas

import pandas as pd

def load_data(file_path):
    df = pd.read_csv(file_path)
    return df

# Part 4 — функция для Data Quality

def validate_data(table):
    invalid_condition = (
        table['price'].isna() |
        table['quantity'].isna() |
        table['order_id'].duplicated(keep=False)
    )

    clean_orders = table[
        ~invalid_condition
    ].copy()

    quarantine_orders = table[
        invalid_condition
    ].copy()

    return clean_orders, quarantine_orders

# Part 5 — filter_business_orders()

def filter_business_orders(table):
    business_orders = table[
        (table['status'] == 'completed') &
        (table['store'] == 'Store_A')
    ].copy()

    return business_orders

# Part 6 — функция с несколькими результатами
# Теперь сделаем:
# calculate_report()

# def calculate_report(table):
#     table = table.copy()

#     table['revenue'] = table['price'] * table['quantity']

#     total_revenue = table['revenue'].sum()
#     orders_count = table['order_id'].count()
#     aov = round(total_revenue / orders_count, 2)
    
#     return total_revenue, orders_count, aov

# total_revenue, orders_count, aov = calculate_report(business_orders)
# print('=== BUSINESS REPORT ===')
# print(f'Orders: {orders_count}')
# print(f'Total revenue: {total_revenue}')
# print(f'AOV: {aov}')

# Part 7.1 - Добавь обработку orders_count == 0 в свою calculate_report().

def calculate_report(table):
    table = table.copy()

    table['revenue'] = table['price'] * table['quantity']

    total_revenue = table['revenue'].sum()
    orders_count = table['order_id'].count()
    if orders_count > 0:
        aov = round(total_revenue / orders_count, 2)
    else:
        aov = None
    
    return total_revenue, orders_count, aov

# # Проверка с пустым магазином
# empty_orders = business_orders[
#     business_orders['store'] == 'Nonexistent_Store'
# ].copy()

# Part 8 - main()

def main():
    our_table = load_data('sales.csv')

    clean_orders, quarantine_orders = validate_data(our_table)

    business_orders = filter_business_orders(clean_orders)

    quarantine_count = quarantine_orders['order_id'].count()

    total_revenue, orders_count, aov = calculate_report(business_orders)

    print('=== BUSINESS REPORT ===')
    print(f'Orders: {orders_count}')
    print(f'Total revenue: {total_revenue}')
    print(f'AOV: {aov}')
    print(f'Quarantine orders: {quarantine_count}')

main()