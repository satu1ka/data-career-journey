# Dictionary:
# test_report = {
#     'store': 'Store_A',
#     'orders': 5,
#     'revenue': 2540,
#     'aov': 508.0
# }

# test_report['orders'] = 6
# test_report['quarantine'] = 4

# print(f"Store: {test_report['store']}")
# print(f"Orders: {test_report['orders']}")
# print(f"Revenue: {test_report['revenue']}")
# print(f"AOV: {test_report['aov']}")
# print(f"Quarantine: {test_report['quarantine']}")

# Теперь представим новые бизнес-правила:

# price       → должна быть > 0
# quantity    → должна быть > 0
# hour        → только от 0 до 23
# status      → только completed / pending / cancelled
# store       → только Store_A / Store_B

import pandas as pd

def load_data(file_path):
    df = pd.read_csv(file_path)
    return df

def validate_data(df):
    invalid_price_condition = (
        df['price'].isna() |
        (df['price'] <= 0) 
    )   
    invalid_hour_condition = (
        df['hour'].isna() |
        (df['hour'] < 0) |
        (df['hour'] > 23) 
    )
    invalid_status_condition = ~(
        df['status'].isin(['completed', 'pending', 'cancelled'])
    )
    invalid_store_condition = ~(
        df['store'].isin(['Store_A', 'Store_B'])
    )
    invalid_quantity_condition = (
        (df['quantity'] <= 0) |
        df['quantity'].isna()
    )
    duplicate_condition = (
        df['order_id'].duplicated(keep=False)
    )

    invalid_condition = (
        invalid_price_condition |
        invalid_hour_condition |
        invalid_status_condition |
        invalid_store_condition | 
        invalid_quantity_condition |
        duplicate_condition
    )
    # All this pieces can be putted in metrics # 'invalid_price': invalid_price_condition.sum() == 'invalid_price': invalid_price_count,
    invalid_price_count = invalid_price_condition.sum()
    invalid_quantity_count = invalid_quantity_condition.sum()
    invalid_hour_count = invalid_hour_condition.sum()
    invalid_status_count = invalid_status_condition.sum()
    invalid_store_count = invalid_store_condition.sum()
    duplicate_rows_count = duplicate_condition.sum()
        
    clean_orders = df[
        ~invalid_condition
    ].copy()

    quarantine_orders = df[
        invalid_condition
    ].copy()
    #Same as previous comment
    clean_orders_count = clean_orders['order_id'].count()
    quarantine_orders_count = quarantine_orders['order_id'].count()
    raw_records_count = df['order_id'].count()

    if raw_records_count > 0:
        clean_rate = round(clean_orders_count / raw_records_count * 100, 2)
    else:
        clean_rate = None
    

    metrics = {
        'invalid_price': invalid_price_count,
        'invalid_quantity': invalid_quantity_count,
        'invalid_hour': invalid_hour_count,
        'invalid_status': invalid_status_count,
        'invalid_store': invalid_store_count,
        'duplicate_rows': duplicate_rows_count,
        'clean_orders': clean_orders_count,
        'quarantine_orders': quarantine_orders_count,
        'raw_records': raw_records_count,
        'clean_rate': clean_rate
    }

    return clean_orders, quarantine_orders, metrics

def main():
    our_table = load_data('weekly_sales.csv')
    clean_orders, quarantine_orders, metrics = validate_data(our_table)
        
    print('=== DATA QUALITY REPORT ===')
    print(f'Raw records: {metrics['raw_records']}')
    print(f'Clean records: {metrics['clean_orders']}')
    print(f'Quarantine records: {metrics['quarantine_orders']}')
    print(f'Clean rate: {metrics['clean_rate']}%\n')
    print('=== VALIDATION ERRORS ===')
    print(f'Invalid price: {metrics['invalid_price']}')
    print(f'Invalid quantity: {metrics['invalid_quantity']}')
    print(f'Invalid hour: {metrics['invalid_hour']}')
    print(f'Invalid status: {metrics['invalid_status']}')
    print(f'Invalid store: {metrics['invalid_store']}')
    print(f'Duplicate rows: {metrics['duplicate_rows']}')

main()



