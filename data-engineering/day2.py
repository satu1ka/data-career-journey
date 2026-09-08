import pandas as pd

# Прочитать CSV.
df = pd.read_csv("ourtable.csv")

# Оставить только completed. мы создали отдельный DataFrame completed со статусом 'completed'
completed = df[df["status"] == "completed"]

# Создать колонку revenue.
completed["revenue"] = completed["price"] * completed["quantity"]

# Посчитать выручку по каждому товару.
# Отсортировать по убыванию.
result = (
    completed.groupby("product")["revenue"]
    .sum()
    .sort_values(ascending=False)
)

# Вывести общую выручку всех completed-заказов.
total_revenue = completed["revenue"].sum()

# Количество завершённых заказов
completed_orders = completed["order_id"].count()

# Вывести результат.
print(result)
print(total_revenue)
print(completed_orders)










