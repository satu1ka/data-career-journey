import pandas as pd
# Задача #1
# Загрузили csv
df = pd.read_csv("ourtable.csv")
# Оставили только "completed"
completed = df[df["status"] == "completed"]
# Сделали "revenue"
completed["revenue"] = completed["price"] * completed["quantity"]
# Вывели "completed"
print(completed)
# Задача 2
# Сделали переменную для группировки всех продуктов по revenue и их сумме
full_revenue = (
    completed.groupby("product")["revenue"]
    .sum()
    .sort_values(ascending=False)
    .head(2)
)
print(full_revenue)
# Задача 3
# Сделали переменную для всех completed заказов и общая выручка
full_orders = completed["order_id"].count()
full_revenue_two = completed["revenue"].sum()



# Задача 1 — разогрев

# Напиши код, который:

# Загружает CSV.
# Оставляет только completed.
# Создаёт revenue = price × quantity.
# Выводит completed.

# Без подсказок.

# 🟡 Задача 2 — небольшая модификация

# Теперь на основе completed получи:

# Топ-2 товара по общей выручке.

# То есть результат должен быть примерно:

# Monitor      600
# Keyboard     320

# Подумай, какие вчерашние инструменты тебе понадобятся.

# 🟠 Задача 3 — маленькая бизнес-задача

# Представь, что менеджер спрашивает:

# «Сколько всего completed-заказов и какую общую выручку они принесли?»

# Выведи:

# Completed orders: 5
# Total revenue: 795