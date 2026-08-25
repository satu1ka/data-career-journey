import pandas as pd

# Task 1 — Warm-up
# Менеджер хочет: 
# Получить все completed заказы из Store_A.
df = pd.read_csv('sales.csv')

store_a_orders = df[
    (df['status'] == 'completed') &
    (df['store'] == 'Store_A')
]

store_a_orders['revenue'] = store_a_orders['price'] * store_a_orders['quantity']

print(store_a_orders)

# Task 2
# Сколько общей revenue принесли товары категории Electronics?
# Create DF for Electronics
electronics = store_a_orders[store_a_orders['category'] == 'Electronics']

revenue_by_electronics = electronics['revenue'].sum()

print(revenue_by_electronics)

# Mini Task cause stupid 
# Сколько общей revenue принесли товары категории Furniture?
furniture = store_a_orders[store_a_orders['category'] == 'Furniture']

revenue_by_furniture = furniture['revenue'].sum()

print(revenue_by_furniture)

# Task 3
# Какая категория принесла больше revenue в Store_A среди completed-заказов?
revenue_by_category = (
    store_a_orders.groupby('category')['revenue']
    .sum()
    .sort_values(ascending=False)
)

print(revenue_by_category)

#Task 4 - Average Order Value
# Какова средняя revenue одного completed-заказа Store_A?
total_revenue = store_a_orders['revenue'].sum()
completed_orders = store_a_orders['order_id'].count()
average_order_value = round(total_revenue / completed_orders, 2)
print(average_order_value)

# Task 5 
# После 18:00 включительно была запущена promo campaign.
# Top 2 products by revenue среди completed orders в Store_A начиная с 18:00.
df = pd.read_csv('sales.csv')

store_a_orders = df[
    (df['status'] == 'completed') &
    (df['store'] == 'Store_A') &
    (df['hour'] >= 18)
]

store_a_orders['revenue'] = store_a_orders['price'] * store_a_orders['quantity']

revenue_by_products = (
    store_a_orders.groupby('product')['revenue']
    .sum()
    .sort_values(ascending=False)
    .head(2)
)

print(revenue_by_products)