def calculate_revenue(price, quantity):
    return price * quantity

def test_calculate_revenue():
    assert calculate_revenue(250, 4) == 1000
    assert calculate_revenue(12.5, 2) == 25

def check_zero_revenue():
    assert calculate_revenue(100, 0) == 0