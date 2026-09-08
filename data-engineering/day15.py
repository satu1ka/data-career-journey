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
    # Task A — новое validation rule quantity > 100 → invalid
    invalid_quantity_condition = (
        (df['quantity'] <= 0) |
        (df['quantity'] > 100) |
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

def filter_analysis_orders(table):
    business_table = table[
        table['status'] == 'completed'
    ].copy()

    return business_table

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
    ] = 'critical'
    table.loc[
        (table['store'] == 'Store_B') & (table['order_size'] == 'large'),
        'priority'
    ] = 'high'
    table['priority'] = table['priority'].fillna('normal')

    table['revenue_per_item'] = table['revenue'] / table['quantity']

    table.loc[
        table['revenue'] < 500,
        'revenue_band'
    ] = 'low'
    table.loc[
        (table['revenue'] >= 500) & (table['revenue'] <= 1499),
        'revenue_band'
    ] = 'mid'
    table.loc[
        table['revenue'] >= 1500,
        'revenue_band'
    ] = 'high'

    return table

def calculate_enrichment_metrics(table):
    order_size_share = round(table['order_size'].value_counts(normalize=True) * 100, 2)
    order_size_counts = table['order_size'].value_counts()
    priority_counts = table['priority'].value_counts()
    small_orders_count = order_size_counts.get('small', 0)
    medium_orders_count = order_size_counts.get('medium', 0)
    large_orders_count = order_size_counts.get('large', 0)
    critical_priority_count = priority_counts.get('critical', 0)
    high_priority_count = priority_counts.get('high', 0)
    normal_priority_count = priority_counts.get('normal', 0)
    revenue_band_counts = table['revenue_band'].value_counts()
    low_revenue_band_count = revenue_band_counts.get('low', 0)
    mid_revenue_band_count = revenue_band_counts.get('mid', 0)
    high_revenue_band_count = revenue_band_counts.get('high', 0)

    enriched_metrics = {
        'order_size': order_size_share,
        'priority': priority_counts,
        'small_orders': small_orders_count,
        'medium_orders': medium_orders_count,
        'large_orders': large_orders_count,
        'critical_priority': critical_priority_count,
        'high_priority': high_priority_count,
        'normal_priority': normal_priority_count,
        'low_revenue_band': low_revenue_band_count,
        'mid_revenue_band': mid_revenue_band_count,
        'high_revenue_band': high_revenue_band_count
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
    total_revenue = (
        table['revenue'].sum()
    )
    revenue_by_band = table.groupby('revenue_band')['revenue'].sum()

    revenue_metrics = {
        'revenue_by_order_size': revenue_by_order_size,
        'average_revenue_by_store': average_revenue_by_store,
        'total_revenue_by_store': total_revenue_by_store,
        'total_revenue': total_revenue,
        'revenue_by_band': revenue_by_band
    }

    return revenue_metrics

def print_data_quality_report(metrics):
    raw_records = metrics['raw_records']
    clean_orders = metrics['clean_orders']
    quarantine_orders = metrics['quarantine_orders']
    clean_rate = metrics['clean_rate']

    print('=== DATA QUALITY REPORT ===')
    print(f'Raw records: {raw_records}')
    print(f'Clean records: {clean_orders}')
    print(f'Quarantine records: {quarantine_orders}')
    print(f'Clean rate: {clean_rate}%\n')

def print_enrichment_report(metrics):
    print('=== ENRICHMENT REPORT ===')
    print(f'Small orders: {metrics['small_orders']}')
    print(f'Medium orders: {metrics['medium_orders']}')
    print(f'Large orders: {metrics['large_orders']}')
    print()
    print(f'Low band orders: {metrics['low_revenue_band']}')
    print(f'Mid band orders: {metrics['mid_revenue_band']}')
    print(f'High band orders: {metrics['high_revenue_band']}')
    print()
    print(f'Critical priority orders: {metrics['critical_priority']}')
    print(f'High priority orders: {metrics['high_priority']}')
    print(f'Normal priority orders: {metrics['normal_priority']}')

def print_revenue_report(metrics):
    print('=== REVENUE REPORT ===')
    print(f'Completed revenue: {metrics['total_revenue']}')
    print()
    print(f'Store_A total revenue: {metrics['total_revenue_by_store'].get('Store_A', 0)}')
    print(f'Store_B total revenue: {metrics['total_revenue_by_store'].get('Store_B', 0)}')
    print()
    print(f'Store_A average revenue: {metrics['average_revenue_by_store'].get('Store_A', 0)}')
    print(f'Store_B average revenue: {metrics['average_revenue_by_store'].get('Store_B', 0)}')
    print()
    print(f'Low band revenue: {metrics['revenue_by_band'].get('low', 0)}')
    print(f'Mid band revenue: {metrics['revenue_by_band'].get('mid', 0)}')
    print(f'High band revenue: {metrics['revenue_by_band'].get('high', 0)}')

def print_full_report(dq_metrics, enriched_metrics, revenue_metrics):
    print_data_quality_report(dq_metrics)
    print_enrichment_report(enriched_metrics)
    print_revenue_report(revenue_metrics)

def save_to_csv(table, file_path):
    table.to_csv(file_path, index=False)

def save_pipeline_outputs(enriched_orders, quarantine_orders, store_summary, category_summary, store_performance, business_summary):
    save_to_csv(enriched_orders, 'enriched_orders.csv')
    save_to_csv(quarantine_orders, 'quarantine_orders.csv')
    save_to_csv(store_summary, 'store_summary.csv')
    save_to_csv(category_summary, 'category_summary.csv')
    save_to_csv(store_performance, 'store_performance.csv')
    save_to_csv(business_summary, 'business_summary.csv')

def build_store_summary(revenue_metrics):
    total_revenue = revenue_metrics['total_revenue_by_store']
    average_revenue = revenue_metrics['average_revenue_by_store']

    store_summary = pd.DataFrame({
        'total_revenue': total_revenue,
        'average_revenue': average_revenue
    })

    store_summary = store_summary.reset_index()

    return store_summary

# Task 1
def build_category_summary(table):
    orders_count = table.groupby('category')['order_id'].count()
    total_revenue = table.groupby('category')['revenue'].sum()
    average_revenue = table.groupby('category')['revenue'].mean().round(2)

    category_summary = pd.DataFrame({
        'orders_count': orders_count,
        'total_revenue': total_revenue,
        'average_revenue': average_revenue
    }).reset_index()

    category_summary.loc[
        category_summary['average_revenue'] >= 600,
        'performance'
    ] = 'high'
    category_summary.loc[
        category_summary['average_revenue'] < 600,
        'performance'
    ] = 'normal'

    return category_summary

# Task 2
def calculate_store_performance(table):
    orders_count = table.groupby('store')['order_id'].count()
    total_revenue = table.groupby('store')['revenue'].sum()
    large_orders = (
        table[table['order_size'] == 'large'] 
        .groupby('store')['order_id']
        .count()
    )   
    
    store_performance = pd.DataFrame({
        'orders_count': orders_count,
        'total_revenue': total_revenue,
        'large_orders': large_orders
    }).reset_index()

    store_performance['large_orders'] = store_performance['large_orders'].fillna(0)

    store_performance['large_orders_share'] = (store_performance['large_orders'] / store_performance['orders_count'] * 100).round(2)
  
    return store_performance

# Task 3 
def build_business_summary(performance, revenue_metrics):
    average_revenue = revenue_metrics['average_revenue_by_store'].reset_index(name='average_revenue')
    
    business_summary = performance.merge(
        average_revenue,
        on='store',
        how='left'
    )

    business_summary.loc[
        (business_summary['average_revenue'] >= 700) & (business_summary['large_orders_share'] >= 40),
        'performance'
    ] = 'strong'
    business_summary['performance'] = business_summary['performance'].fillna('normal')
    
    return business_summary

def main():
    our_table = load_data('weekly_sales.csv')

    clean_orders, quarantine_orders, dq_metrics = validate_data(our_table)
    analysis_orders = filter_analysis_orders(clean_orders)
    enriched_orders = enrich_orders(analysis_orders)

    enriched_metrics = calculate_enrichment_metrics(enriched_orders)
    revenue_metrics = calculate_revenue(enriched_orders)

    print_full_report(dq_metrics, enriched_metrics, revenue_metrics)

    store_summary = build_store_summary(revenue_metrics)
    # Task 1
    category_summary = build_category_summary(enriched_orders)
    # Task 2
    store_performance = calculate_store_performance(enriched_orders)
    # Task 3
    business_summary = build_business_summary(store_performance, revenue_metrics)
    
    save_pipeline_outputs(enriched_orders, quarantine_orders, store_summary, category_summary, store_performance, business_summary)
    
main()


