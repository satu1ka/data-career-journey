import pandas as pd

# Отдел аналитики хочет получить корректный отчёт по выполненным заказам Store_A. Перед расчётами данные должны пройти Data Quality validation. Записи с отсутствующей price, отсутствующей quantity или duplicate order_id нельзя использовать в бизнес-расчётах, но удалять их из исходных данных нельзя.

# Making function which read our table
def read_table(file_path):
    df = pd.read_csv(file_path)
    return df

# Making function which have condition to sort for clean/quarantine orders
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

# Making function to find missing price, quantity and duplicated rows
def missing_parts(table):
    missing_price_count = table['price'].isna().sum()
    missing_quantity_count = table['quantity'].isna().sum()
    duplicated_rows_count = table['order_id'].duplicated(keep=False).sum()

    return missing_price_count, missing_quantity_count, duplicated_rows_count

# Making function to separate business orders
def filter_business_orders(table):
    business_orders = table[
        (table['store'] == 'Store_A') &
        (table['status'] == 'completed')
    ].copy()

    return business_orders

# Making function to calculate revenue and AOV
def calculation(table):
    table = table.copy()

    table['revenue'] = table['price'] * table['quantity']
    total_revenue = table['revenue'].sum()
    orders_count = table['order_id'].count()

    if orders_count > 0:
        aov = round(total_revenue / orders_count, 2)
    else:
        aov = None

    return total_revenue, aov

# Making main function to show report
def main():
    our_table = read_table('weekly_sales.csv')
    clean_orders, quarantine_orders = validate_data(our_table)
    raw_records = our_table['order_id'].count()
    clean_orders_count = clean_orders['order_id'].count()
    quarantine_orders_count = quarantine_orders['order_id'].count()
    missing_price_count, missing_quantity_count, duplicated_rows_count = missing_parts(our_table)
    completed_orders = filter_business_orders(clean_orders)
    completed_orders_count = completed_orders['order_id'].count()
    total_revenue, aov = calculation(completed_orders)

    print('=== DATA QUALITY REPORT ===')
    print(f'Raw records: {raw_records}')
    print(f'Clean records: {clean_orders_count}')
    print(f'Quarantine orders: {quarantine_orders_count}')
    print(f'Missing price: {missing_price_count}')
    print(f'Missing quantity: {missing_quantity_count}')
    print(f'Duplicated rows: {duplicated_rows_count}')

    print('=== STORE A REPORT ===')
    print(f'Completed orders: {completed_orders_count}')
    print(f'Total revenue: {total_revenue}')
    print(f'AOV: {aov}')
    
main()
