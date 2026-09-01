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

    clean_orders_count = clean_orders['order_id'].count()
    quarantine_orders_count = quarantine_orders['order_id'].count()
    raw_records_count = df['order_id'].count()

    if raw_records_count > 0:
        clean_rate = round(clean_orders_count / raw_records_count * 100, 2)
    else:
        clean_rate = None
    
    dq_metrics = {
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

    return clean_orders, quarantine_orders, dq_metrics

def enrich_orders(table):
    table = table.copy()
    table['revenue'] = table['price'] * table['quantity']

    table.loc[
        table['revenue'] < 300,
        'order_size'
    ] = 'small'
    table.loc[
        (table['revenue'] >= 300) & (table['revenue'] < 800),
        'order_size'
    ] = 'medium'
    table.loc[
        table['revenue'] >= 800,
        'order_size'
    ] = 'large'

    table.loc[
        (table['store'] == 'Store_A') & (table['order_size'] == 'large'),
        'priority'
    ] = 'high'

    table['priority'] = table['priority'].fillna('normal')

    return table

def calculate_enrichment_metrics(table):
    order_size_share = round(table['order_size'].value_counts(normalize=True) * 100, 2)
    order_size_counts = table['order_size'].value_counts()
    priority_counts = table['priority'].value_counts()
    small_orders_count = order_size_counts.get('small', 0)
    medium_orders_count = order_size_counts.get('medium', 0)
    large_orders_count = order_size_counts.get('large', 0)
    high_priority_count = priority_counts.get('high', 0)
    normal_priority_count = priority_counts.get('normal', 0)

    enriched_metrics = {
        'order_size': order_size_share,
        'priority': priority_counts,
        'small_orders': small_orders_count,
        'medium_orders': medium_orders_count,
        'large_orders': large_orders_count,
        'high_priority': high_priority_count,
        'normal_priority': normal_priority_count
    }

    return enriched_metrics

def calculate_revenue(table):
    revenue_by_order_size = table.groupby(['store', 'order_size'])['revenue'].sum() 
    average_revenue_by_store = (
        round(table.groupby('store')['revenue'].mean(), 2)
    )
    total_revenue_by_store = (
        table.groupby('store')['revenue'].sum().round(2)
    )

    revenue_metrics = {
        'revenue_by_order_size': revenue_by_order_size,
        'average_revenue_by_store': average_revenue_by_store,
        'total_revenue_by_store': total_revenue_by_store
    }

    return revenue_metrics

def main():
    our_table = load_data('weekly_sales.csv')
    clean_orders, quarantine_orders, dq_metrics = validate_data(our_table)
    enriched_orders = enrich_orders(clean_orders)
    enriched_metrics = calculate_enrichment_metrics(enriched_orders)
    revenue_metrics = calculate_revenue(enriched_orders)

    print('=== DATA QUALITY REPORT ===')
    print(f'Raw records: {dq_metrics['raw_records']}')
    print(f'Clean records: {dq_metrics['clean_orders']}')
    print(f'Quarantine records: {dq_metrics['quarantine_orders']}')
    print(f'Clean rate: {dq_metrics['clean_rate']}%\n')

    print('=== ENRICHMENT REPORT ===')
    print(f'Small orders: {enriched_metrics['small_orders']}')
    print(f'Medium orders: {enriched_metrics['medium_orders']}')
    print(f'Large orders: {enriched_metrics['large_orders']}')
    print(f'High priority: {enriched_metrics['high_priority']}')
    print(f'Normal priority: {enriched_metrics['normal_priority']}')
    print(f'Small share: {enriched_metrics['order_size'].get('small', 0)}%')
    print(f'Medium share: {enriched_metrics['order_size'].get('medium', 0)}%')
    print(f'Large share: {enriched_metrics['order_size'].get('large', 0)}%')

    print('=== REVENUE REPORT ===')
    print(f'Store_A total revenue: {revenue_metrics['total_revenue_by_store'].get('Store_A', 0)}')
    print(f'Store_B total revenue: {revenue_metrics['total_revenue_by_store'].get('Store_B', 0)}')
    print(f'Store_A average revenue: {revenue_metrics['average_revenue_by_store'].get('Store_A', 0)}')
    print(f'Store_B average revenue: {revenue_metrics['average_revenue_by_store'].get('Store_B', 0)}')
    print(f'Store_A small revenue: {revenue_metrics['revenue_by_order_size'].get(('Store_A', 'small'), 0)}')
    print(f'Store_A medium revenue: {revenue_metrics['revenue_by_order_size'].get(('Store_A', 'medium'), 0)}')
    print(f'Store_A large revenue: {revenue_metrics['revenue_by_order_size'].get(('Store_A', 'large'), 0)}')
    print(f'Store_B small revenue: {revenue_metrics['revenue_by_order_size'].get(('Store_B', 'small'), 0)}')
    print(f'Store_B medium revenue: {revenue_metrics['revenue_by_order_size'].get(('Store_B', 'medium'), 0)}')
    print(f'Store_B large revenue: {revenue_metrics['revenue_by_order_size'].get(('Store_B', 'large'), 0)}')
    
main()


