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

# Task F — Новое бизнес-требование:Заказы со статусом cancelled больше не должны участвовать в enrichment и revenue analysis вообще.
# Но при этом они не являются плохими данными и не должны попадать в quarantine.
# def filter_analysis_orders(table):
#     business_table = table[
#         table['status'] != 'cancelled'
#     ].copy()

#     return business_table

# Task G — ещё одно изменение требований: Для revenue analysis нужны только completed orders.
# pending тоже должны оставаться clean data, но не участвовать в enrichment и revenue calculations.
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
    # Task E — изменение бизнес-логики high priority теперь должен получать любой large заказ, независимо от магазина.
    # Но large заказ из Store_A должен получить отдельный уровень 'critical'.
    table.loc[
        (table['store'] == 'Store_A') & (table['order_size'] == 'large'),
        'priority'
    ] = 'critical'
    table.loc[
        (table['store'] == 'Store_B') & (table['order_size'] == 'large'),
        'priority'
    ] = 'high'
    table['priority'] = table['priority'].fillna('normal')

    # Task B Добавить в enriched data колонку revenue_per_item = revenue / quantity.
    table['revenue_per_item'] = table['revenue'] / table['quantity']

    # Final Task
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
    # Task E
    critical_priority_count = priority_counts.get('critical', 0)
    high_priority_count = priority_counts.get('high', 0)
    normal_priority_count = priority_counts.get('normal', 0)
    # Final Task
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
        # Task E
        'critical_priority': critical_priority_count,
        'high_priority': high_priority_count,
        'normal_priority': normal_priority_count,
        # Final Task
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
    # Task D: нужно посчитать total revenue отдельно для каждого status
    # revenue_by_status = (
    #     table.groupby('status')['revenue'].sum()
    # )
    # Task G
    total_revenue = (
        table['revenue'].sum()
    )
    # Final Task
    revenue_by_band = table.groupby('revenue_band')['revenue'].sum()

    revenue_metrics = {
        'revenue_by_order_size': revenue_by_order_size,
        'average_revenue_by_store': average_revenue_by_store,
        'total_revenue_by_store': total_revenue_by_store,
        # Task D: нужно посчитать total revenue отдельно для каждого status
        # 'revenue_by_status': revenue_by_status
        # Task G
        'total_revenue': total_revenue,
        # Final Task
        'revenue_by_band': revenue_by_band
    }

    return revenue_metrics

def main():
    our_table = load_data('weekly_sales.csv')
    clean_orders, quarantine_orders, dq_metrics = validate_data(our_table)
    # Task F
    analysis_orders = filter_analysis_orders(clean_orders)
    enriched_orders = enrich_orders(analysis_orders)
    enriched_metrics = calculate_enrichment_metrics(enriched_orders)
    revenue_metrics = calculate_revenue(enriched_orders)

    # print('=== DATA QUALITY REPORT ===')
    # print(f'Raw records: {dq_metrics['raw_records']}')
    # print(f'Clean records: {dq_metrics['clean_orders']}')
    # print(f'Quarantine records: {dq_metrics['quarantine_orders']}')
    # print(f'Clean rate: {dq_metrics['clean_rate']}%\n')

    # print('=== ENRICHMENT REPORT ===')
    # print(f'Small orders: {enriched_metrics['small_orders']}')
    # print(f'Medium orders: {enriched_metrics['medium_orders']}')
    # print(f'Large orders: {enriched_metrics['large_orders']}')
    # print(f'High priority: {enriched_metrics['high_priority']}')
    # print(f'Normal priority: {enriched_metrics['normal_priority']}')
    # print(f'Small share: {enriched_metrics['order_size'].get('small', 0)}%')
    # print(f'Medium share: {enriched_metrics['order_size'].get('medium', 0)}%')
    # print(f'Large share: {enriched_metrics['order_size'].get('large', 0)}%')
    
    # print('=== REVENUE REPORT ===')
    # print(f'Store_A total revenue: {revenue_metrics['total_revenue_by_store'].get('Store_A', 0)}')
    # print(f'Store_B total revenue: {revenue_metrics['total_revenue_by_store'].get('Store_B', 0)}')
    # print(f'Store_A average revenue: {revenue_metrics['average_revenue_by_store'].get('Store_A', 0)}')
    # print(f'Store_B average revenue: {revenue_metrics['average_revenue_by_store'].get('Store_B', 0)}')
    # print(f'Store_A small revenue: {revenue_metrics['revenue_by_order_size'].get(('Store_A', 'small'), 0)}')
    # print(f'Store_A medium revenue: {revenue_metrics['revenue_by_order_size'].get(('Store_A', 'medium'), 0)}')
    # print(f'Store_A large revenue: {revenue_metrics['revenue_by_order_size'].get(('Store_A', 'large'), 0)}')
    # print(f'Store_B small revenue: {revenue_metrics['revenue_by_order_size'].get(('Store_B', 'small'), 0)}')
    # print(f'Store_B medium revenue: {revenue_metrics['revenue_by_order_size'].get(('Store_B', 'medium'), 0)}')
    # print(f'Store_B large revenue: {revenue_metrics['revenue_by_order_size'].get(('Store_B', 'large'), 0)}')

    print('=== DAY 13 CHANGES ===')
    # Task C - Здесь небольшой подвох: бизнес просит: показать количество high priority заказов.
    print(f'High priority orders: {enriched_metrics['high_priority']}')
    # Task D: нужно посчитать total revenue отдельно для каждого status
    # print(f'Completed revenue: {revenue_metrics['revenue_by_status'].get('completed', 0)}')
    # print(f'Pending revenue: {revenue_metrics['revenue_by_status'].get('pending', 0)}')
    # Task G
    print(f'Completed revenue: {revenue_metrics['total_revenue']}')
    # Из-за Task F убираем cancelled_orders
    # print(f'Cancelled revenue: {revenue_metrics['revenue_by_status'].get('cancelled', 0)}')
    # Task E
    print(f'Critical priority orders: {enriched_metrics['critical_priority']}')
    print(f'High priority orders: {enriched_metrics['high_priority']}')
    print(f'Normal priority orders: {enriched_metrics['normal_priority']}')
    # Final Task
    print(f'Low band orders: {enriched_metrics['low_revenue_band']}')
    print(f'Mid band orders: {enriched_metrics['mid_revenue_band']}')
    print(f'Large band orders: {enriched_metrics['high_revenue_band']}')
    print(f'Low band revenue: {revenue_metrics['revenue_by_band'].get('low', 0)}')
    print(f'Mid band revenue: {revenue_metrics['revenue_by_band'].get('mid', 0)}')
    print(f'High band revenue: {revenue_metrics['revenue_by_band'].get('high', 0)}')
main()


