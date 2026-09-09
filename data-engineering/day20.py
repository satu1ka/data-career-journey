# Ticket 1 — первые нормальные logs
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s | %(levelname)s | %(message)s',
    # запись логов в файл:
    # filename='day20_pipeline.log'
    # вывод логов в терминал и сохранение в файл:
    handlers=[
        logging.FileHandler('day20_pipeline.log'),
        logging.StreamHandler()
    ]
)

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

def business_filtering(table, target_status):
    business_orders = table[
        table['status'] == target_status
    ].copy()

    return business_orders

def filter_by_date(table, process_date):
    our_date = pd.to_datetime(process_date).date()
    table_condition = (table['created_at'].dt.date == our_date)

    our_table = table[
        table_condition
    ].copy()

    return our_table

def enrich_time_data(table):
    table = table.copy()
    table['order_date'] = table['created_at'].dt.date
    table['order_hour'] = table['created_at'].dt.hour
    table['day_of_week'] = table['created_at'].dt.day_name()

    table['revenue'] = table['price'] * table['quantity']

    table.loc[
        table['order_hour'] < 12,
        'time_of_day'
    ] = 'morning'
    table.loc[
        (table['order_hour'] >= 12) & (table['order_hour'] <18),
        'time_of_day'
    ] = 'afternoon'
    table.loc[
        table['order_hour'] >= 18,
        'time_of_day'
    ] = 'evening'

    return table

def build_daily_summary(table):
    orders_count = table.groupby('order_date')['order_id'].count()
    total_revenue = table.groupby('order_date')['revenue'].sum()
    average_revenue = table.groupby('order_date')['revenue'].mean().round(2)

    daily_summary = pd.DataFrame({
        'orders_count': orders_count,
        'total_revenue': total_revenue,
        'average_revenue': average_revenue
    }).reset_index()

    return daily_summary

def main(process_date, target_status):
    try:
        logging.info('Pipeline started')

        table = load_data('daily_sales.csv')
        # Проверки ошибок:
        # table = load_data('wrong_table.csv')
        # table = table.drop(columns=['price'])
        logging.info('Data loaded successfully')

        table = validate_schema(table)
        table = select_required_columns(table)
        table = convert_data_types(table)

        clean_orders, quarantine_orders, dq_metrics = validate_data(table)
    
        # Ticket 3 - добавляет ВОРНИНГ о том, что какие-то строки ушли в карантин
        if dq_metrics['quarantine_orders'] > 0:
            logging.warning(f'There are {dq_metrics['quarantine_orders']} quarantine orders after data validation')

        # Ticket 2 - вывод через логгинг инфы про validate_data
        logging.info(
            f'Data validation completed: '
            f'Raw records: {dq_metrics['raw_records']} | '
            f'Clean records: {dq_metrics['clean_records']} | '
            f'Quarantine records: {dq_metrics['quarantine_orders']} | '
            f'Clean rate: {dq_metrics['clean_rate']}'
        )

        # Ticket 13 — самостоятельная задача
        table_filtered_by_date = filter_by_date(clean_orders, process_date)

        if table_filtered_by_date.empty:
            logging.warning(f'No clean orders found for process date {process_date}')
        else:
            business_orders = business_filtering(table_filtered_by_date, target_status)
            if business_orders.empty:
                logging.warning(f'No {target_status} orders found for process date {process_date}')
            else:
                enriched_orders = enrich_time_data(business_orders)
                daily_summary = build_daily_summary(enriched_orders)     
    
    except ValueError as error:
        logging.exception(f'We lost something: {error}')
    except FileNotFoundError as error:
        logging.exception(f"Can't continue, cause: {error}")

    else:
        logging.info('Pipeline completed successfully')

    finally:
        logging.info('Pipeline execution finished') 

main('2026-09-02', 'completed')

