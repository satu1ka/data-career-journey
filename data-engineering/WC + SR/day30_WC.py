import pandas as pd

# table = pd.DataFrame({
#     'order_id': ['A1', 'A2', 'A3'],
#     'price': [100, 250, 80],
#     'status': ['completed', 'pending', 'completed']
# })

# table - DF

# table['price'] - series

# table[['price']] - DF

# table['price'].iloc[0] - scalar

# table['price'] > 100 - series

# Запоминаем важную цепочку:

# table['status']                    → Series
# table['status'] == 'completed'     → Series
# condition.iloc[0]                  → scalar

# .all - проверяет всю series на True, если хоть один False -> False
# .any - проверяет всю series и требует хотя бы 1 True

# Quest 10 — финальный на сегодня
table = pd.DataFrame({
    'order_id': ['A1', 'A2', 'A3', 'A4'],
    'price': [100, 250, 80, 300],
    'quantity': [2, 1, 5, 3],
    'status': ['completed', 'pending', 'completed', 'completed']
})

condition = (
    (table['status'] == 'completed')
    & (table['price'] >= 100)
)

result = table[condition]

assert (result['status'] == 'completed').all()