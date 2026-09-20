# # Quest 10 — небольшой coding review
import pandas as pd

# def enrich_revenue(table):
#     table['revenue'] = table['price'] * table['quantity']
#     return table

# table = pd.DataFrame({
#     'order_id': ['A1', 'A2', 'A3'],
#     'price': [100, 250, 80],
#     'quantity': [2, 1, 3]
# })

# # добавили ->
# result = enrich_revenue(table)

# assert result['revenue'].loc[0] == 200
# assert result['revenue'].loc[1] == 250
# assert result['revenue'].loc[2] == 240

# # альтернатива нормальная
# assert result['revenue'].tolist() == [200, 250, 240]

table = pd.DataFrame({
    'price': [100, 200, 300],
    'status': ['completed', 'pending', 'completed']
})

print(table['price'])
print(table[['price']])
print(table['price'] == 200)
print(table[table['price'] == 200])
print((table['status'] == 'completed').all())

# На этом Day 31 Sunday Review можно закрывать. Сегодня ты уверенно прошёл pandas mental model, import safety, pytest discovery, unit-test isolation, expected exceptions, regression tests, responsibilities, orchestration, exception boundaries и integration-thinking. Ошибки были в основном не в общей логике, а в формулировках и паре конкретных деталей — это уже хороший уровень для review.