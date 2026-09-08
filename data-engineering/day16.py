import pandas as pd

def load_data(file_path):
    table = pd.read_csv(file_path)
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
    invalid_rows_condition = (
        table['order_id'].duplicated(keep=False)
    )

    invalid_condition = (
        invalid_price_condition |
        invalid_quantity_condition |
        invalid_rows_condition
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
    if raw_records_count > 0:
        clean_rate = (clean_records_count / raw_records_count * 100).round(2)
    else:
        clean_rate = None

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
    ]

    return business_orders

def enriched_data(table):
    table = table.copy()
    table['revenue'] = table['price'] * table['quantity']

    table.loc[
        table['revenue'] < 500,
        'revenue_level'
    ] = 'low'
    table.loc[
        (table['revenue'] >= 500) & (table['revenue'] < 1000),
        'revenue_level'
    ] = 'medium'
    table.loc[
        table['revenue'] >= 1000,
        'revenue_level'
    ] = 'high'

    return table

def calculation_store_summary(table):
    orders_count = table.groupby('store')['order_id'].count()
    total_revenue = table.groupby('store')['revenue'].sum()
    average_revenue = (total_revenue / orders_count).round(2)

    high_revenue_orders = (
            table[table['revenue_level'] == 'high']
            .groupby('store')['order_id']
            .count()
        )   

    store_summary = pd.DataFrame({
            'orders_count': orders_count,
            'total_revenue': total_revenue,
            'average_revenue': average_revenue,
            'high_revenue_orders': high_revenue_orders
        }).reset_index()

    store_summary['high_revenue_orders'] = store_summary['high_revenue_orders'].fillna(0)
    store_summary['high_revenue_share'] = (store_summary['high_revenue_orders'] / store_summary['orders_count'] * 100).round(2)

    store_summary.loc[
        (store_summary['average_revenue'] >= 700) & (store_summary['high_revenue_share'] >= 40),
        'performance'
    ] = 'strong'
    store_summary['performance'] = store_summary['performance'].fillna('normal')

    return store_summary

def challenge_output(metrics, table):
    raw_records = metrics['raw_records']
    clean_records = metrics['clean_records']
    quarantine_orders = metrics['quarantine_orders']
    clean_rate = metrics['clean_rate']

    print(f'=== DATA QUALITY ===')
    print(f'Raw records: {raw_records}')
    print(f'Clean records: {clean_records}')
    print(f'Quarantine records: {quarantine_orders}')
    print(f'Clean rate: {clean_rate}%')
    print()
    print(f'=== BUSINESS SUMMARY ===')
    print(table)


def save_to_csv(table, file_path):
    table.to_csv(file_path, index=False)

def save_challenge_outputs(enriched_orders, quarantine_orders, store_summary):
    save_to_csv(enriched_orders, 'enriched_orders_day16.csv')
    save_to_csv(quarantine_orders, 'quarantine_orders_day16.csv')
    save_to_csv(store_summary, 'store_summary_day16.csv')

def main():
    our_table = load_data('week2_sales.csv')
    clean_orders, quarantine_orders, dq_metrics = validate_data(our_table)
    business_orders = business_filtering(clean_orders)
    enriched_orders = enriched_data(business_orders)
    store_summary = calculation_store_summary(enriched_orders)

    challenge_output(dq_metrics, store_summary)
    save_challenge_outputs(enriched_orders, quarantine_orders, store_summary)

main()