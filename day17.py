# Part B
# 6
(table['revenue'] >= 500) & (table['revenue'] < 1000)
# 7
full_revenue_by_store = orders.groupby('store')['revenue'].sum()
# 8
store_summary = pd.DataFrame({
    'orders_count': orders_count,
    'high_orders': high_orders
}).reset_index()
# 9
store_summary['high_orders'] = store_summary['high_orders'].fillna(0)
# 10
store_summary['high_share'] = (store_summary['high_orders'] / store_summary['orders_count'] * 100).round(2)