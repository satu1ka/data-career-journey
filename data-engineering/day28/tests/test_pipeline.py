import pandas as pd
import pytest

from day28 import pipeline

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