# Part 5 — Mini Coding
# Напиши функцию:
# validate_orders(table)
# которая считает запись invalid, если:
# price missing;
# quantity missing;
# price <= 0;
# quantity <= 0;
# order_id duplicate.

def validate_orders(table):
    invalid_condition = (
        table['price'].isna() |
        table['quantity'].isna() |
        (table['price'] <= 0) |
        (table['quantity'] <= 0) |
        table['order_id'].duplicated(keep=False)
    )

    clean_orders = table[
        ~invalid_condition
    ].copy()

    quarantine_orders = table[
        invalid_condition
    ].copy()

    return clean_orders, quarantine_orders