import pandas as pd

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

    # Зарефакторить и убрать это отсюда
    # table['revenue'] = table['price'] * table['quantity'] 

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

def enrich_revenue(table):
    table = table.copy()
    
    table['revenue'] = table['price'] * table['quantity']

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