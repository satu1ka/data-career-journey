import pandas as pd
import pytest

from day29 import pipeline

def test_validate_schema_missing_column():
    table = pd.DataFrame({
        'order_id': [2],
        'product': ['banana'],
        'category': ['fruit'],
        'quantity': [100],
        'status': ['completed'],
        'store': ['A'],
        'created_at': ['2026-12-17']
    })

    with pytest.raises(ValueError):
        pipeline.validate_schema(table)

def test_validate_schema_valid():
    table = pd.DataFrame(columns=[
        'order_id',
        'product',
        'category',
        'price',
        'quantity',
        'status',
        'store',
        'created_at'
    ])

    result = pipeline.validate_schema(table)

    pd.testing.assert_frame_equal(result, table)

# Quest 2
def test_validate_data_price():
    table = pd.DataFrame({
        'order_id': ['1', '2', '3'],
        'price': [123, -3, 321],
        'quantity': [1, 1, 1],
        'created_at': ['2026-09-01 09:15:00', '2026-09-02 09:15:00', '2026-09-03 09:15:00']
    })

    clean, quarantine, dq_metrics = pipeline.validate_data(table)

    assert len(clean) == 2
    assert len(quarantine) == 1
    assert quarantine['order_id'].iloc[0] == '2'

# Quest 3
def test_validate_data_metrics():
    table = pd.DataFrame({
        'order_id': ['1', '2', '3', '4', '5'],
        'price': [123, -3, 321, 12, 34],
        'quantity': [1, 1, 1, 1, -5],
        'created_at': ['2026-09-01 09:15:00', '2026-09-02 09:15:00','2026-09-03 09:15:00', '2026-09-10 09:15:00', '2026-09-06 09:15:00']
    })

    clean, quarantine, dq_metrics = pipeline.validate_data(table)

    assert dq_metrics['clean_records'] == 3
    assert dq_metrics['quarantine_records'] == 2