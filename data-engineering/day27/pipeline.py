import pandas as pd

def load_data(file_path):
    table = pd.read_csv(file_path)

    return table

def validate_schema(table):
    required_columns = [
        'order_id',
        'product',
        'category',
        'price',
        'quantity',
        'status',
        'store',
        'created_at'
    ]

    missing_columns = []

    for item in required_columns:
        if item not in table.columns:
            missing_columns.append(item)

    if missing_columns:
        raise ValueError(f'Missing required columns: {missing_columns}')

    return table

def select_required_columns(table):
    required_columns = [
        'order_id',
        'product',
        'category',
        'price',
        'quantity',
        'status',
        'store',
        'created_at'
    ]

    table = table[required_columns].copy()

    return table
    
def convert_data_types(table):
    table = table.copy()

    table['created_at'] = pd.to_datetime(
            table['created_at'],
            errors='coerce'
        )
    table['price'] = pd.to_numeric(
        table['price'],
        errors='coerce'
    )
    table['quantity'] = pd.to_numeric(
        table['quantity'],
        errors='coerce'
    )

    return table

def validate_data(table):
    invalid_price_condition = (
        (table['price'].isna()) |
        (table['price'] <= 0)
    )
    invalid_quantity_condition = (
        (table['quantity'] <= 0) |
        (table['quantity'].isna())
    )
    invalid_time_condition = (
        table['created_at'].isna()
    )

    invalid_condition = (
        invalid_price_condition |
        invalid_quantity_condition |
        invalid_time_condition
    )

    clean_orders = table[
        ~invalid_condition
    ].copy()

    quarantine_orders = table[
        invalid_condition
    ].copy()

    raw_records_count = table['order_id'].count()
    clean_records_count = clean_orders['order_id'].count()
    quarantine_orders_count = quarantine_orders['order_id'].count()
    clean_rate = (clean_records_count / raw_records_count * 100).round(2)

    dq_metrics = {
        'raw_records': raw_records_count,
        'clean_records': clean_records_count,
        'quarantine_orders': quarantine_orders_count,
        'clean_rate': clean_rate
    }

    return clean_orders, quarantine_orders, dq_metrics
