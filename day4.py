# our_table.csv -
# order_id,product,price,quantity,status,store,hour
# 1001,Keyboard,80,1,completed,Store_A,13
# 1002,Mouse,25,2,completed,Store_A,15
# 1003,Monitor,300,1,cancelled,Store_A,16
# 1004,Keyboard,80,3,completed,Store_B,14
# 1005,Mouse,25,1,completed,Store_A,12
# 1006,Monitor,300,2,completed,Store_A,18
# 1007,Keyboard,80,2,completed,Store_A,16

import pandas as pd

# Task 1
# Create DF
df = pd.read_csv("our_table.csv")
# Create DF with orders == completed & store == "Store_A"
orders = df[
    (df["status"] == "completed") & 
    (df["store"] == "Store_A")
]
# Create column with revenue
orders["revenue"] = orders["price"] * orders["quantity"]
# Output DF
print(orders)

# Task 2
# Create DF
df = pd.read_csv("our_table.csv")
# Create DF with orders == completed & store == "Store_A" and filter orders after 14:00
orders = df[
    (df["status"] == "completed") &
    (df["store"] == "Store_A") &
    (df["hour"] >= 14)
]
# Revenue after 14
orders["revenue"] = orders["price"] * orders["quantity"]
# Total revenue
total_revenue = orders["revenue"].sum()
# Output Total revenue
print(total_revenue)

# Task 3
df = pd.read_csv("our_table.csv")
orders = df[
    (df["status"] == "completed") &
    (df["store"] == "Store_A") &
    (df["hour"] >= 14)
]
orders["revenue"] = orders["price"] * orders["quantity"]
# Calculate revenue by product
revenue_by_products = (
    orders.groupby("product")["revenue"]
    .sum()
    .sort_values(ascending=False)
)
print(revenue_by_products)

# Task 4
# If we have order:
# price = 100
# quantity = 3
# discount = 20
orders["revenue"] = (
    orders["price"]
    * orders["quantity"]
    * (1 - orders["discount"] / 100)
)