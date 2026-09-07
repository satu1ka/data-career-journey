import pandas as pd

# Task 1
def load_data(file_path):
    table = pd.read_csv(file_path)
    # Преобразуем колонку created_at в datetime и присваеваем ей же её преобразованные значения
    table['created_at'] = pd.to_datetime(
        table['created_at'],
        errors='coerce'
    )

    return table

# Task 2 - добавить в валидацию данных время
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

def business_filtering(table):
    business_orders = table[
        table['status'] == 'completed'
    ].copy()

    return business_orders

# Ticket 3
def filter_by_date(table, process_date):
    our_date = pd.to_datetime(process_date).date()
    table_condition = (table['created_at'].dt.date == our_date)

    our_table = table[
        table_condition
    ].copy()

    return our_table

# Ticket 1
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

# Ticket 2
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

def main():
    table = load_data('daily_sales.csv')
    # # Task 1
    # print(table[['order_id', 'created_at']])
    # print()
    # print(table['created_at'].dtype)
    # Task 2
    clean_orders, quarantine_orders, dq_metrics = validate_data(table)
    table_filtered_by_date = filter_by_date(clean_orders, process_date='2026-09-02')
    business_orders = business_filtering(table_filtered_by_date)
    enriched_orders = enrich_time_data(business_orders)
    daily_summary = build_daily_summary(enriched_orders)
    print(daily_summary)
    print(enriched_orders[['order_id', 'order_hour', 'time_of_day']
])

main()