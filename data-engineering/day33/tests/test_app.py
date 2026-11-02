import pandas as pd
import pytest

from day33 import app


def make_orders_csv(tmp_path, rows):
    path = tmp_path / 'orders.csv'
    columns = [
        'order_id', 'product', 'category', 'price', 'quantity',
        'status', 'store', 'created_at'
    ]
    pd.DataFrame(rows, columns=columns).to_csv(path, index=False)
    return path


def test_main_returns_daily_summary(tmp_path):
    path = make_orders_csv(tmp_path, [
        {
            'order_id': 'A1', 'product': 'book', 'category': 'books',
            'price': 100, 'quantity': 2, 'status': 'completed',
            'store': 'A', 'created_at': '2026-09-02 10:00:00'
        },
        {
            'order_id': 'A2', 'product': 'book', 'category': 'books',
            'price': -1, 'quantity': 1, 'status': 'completed',
            'store': 'A', 'created_at': '2026-09-02 10:00:00'
        },
        {
            'order_id': 'A3', 'product': 'book', 'category': 'books',
            'price': 300, 'quantity': 1, 'status': 'pending',
            'store': 'A', 'created_at': '2026-09-02 10:00:00'
        }
    ])

    result = app.main('2026-09-02', 'completed', path)

    assert result['orders_count'].iloc[0] == 1
    assert result['total_revenue'].iloc[0] == 200
    assert result['average_revenue'].iloc[0] == 200


@pytest.mark.parametrize('rows', [[], [
    {
        'order_id': 'A1', 'product': 'book', 'category': 'books',
        'price': -10, 'quantity': 1, 'status': 'completed',
        'store': 'A', 'created_at': '2026-09-02'
    }
]])
def test_main_handles_no_clean_orders(tmp_path, rows):
    path = make_orders_csv(tmp_path, rows)

    result = app.main('2026-09-02', 'completed', path)

    assert result.empty
    assert result.columns.tolist() == [
        'order_date', 'orders_count', 'total_revenue', 'average_revenue'
    ]


def test_main_propagates_missing_input_file(tmp_path):
    with pytest.raises(FileNotFoundError):
        app.main('2026-09-02', 'completed', tmp_path / 'missing.csv')


def test_main_propagates_schema_error(tmp_path):
    path = tmp_path / 'invalid.csv'
    pd.DataFrame({'order_id': ['A1']}).to_csv(path, index=False)

    with pytest.raises(ValueError, match='Missing required columns'):
        app.main('2026-09-02', 'completed', path)
