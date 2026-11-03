import pandas as pd
import pytest

from day33 import pipeline

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

# Quest 8 — load_data() happy path
def test_load_data_valid(tmp_path):
    # создаем временный путь
    csv_path = tmp_path / 'sales.csv'
    # создаем временную таблицу
    source = pd.DataFrame({
        'order_id': ['A1', 'A2'],
        'price': [100, 250]
    })
    # сохраняем временную таблицу в csv формате
    source.to_csv(csv_path, index=False)

    result = pipeline.load_data(csv_path)

    pd.testing.assert_frame_equal(result, source)

# Quest 9 — load_data() missing file
def test_load_data_missing_file(tmp_path):
    csv_path = tmp_path / 'missing.csv'

    with pytest.raises(FileNotFoundError):
        pipeline.load_data(csv_path)

# Quest 12 — test для convert_data_types()
def test_convert_data_types():
    table = pd.DataFrame({
        'created_at': ['2026-09-22 10:30:00', 'wrong_date'],
        'price': ['100.5', 'wrong_price'],
        'quantity': ['2', 'wrong_quantity']
    })

    result = pipeline.convert_data_types(table)

    assert result['price'].loc[0] == 100.5
    assert result['quantity'].loc[0] == 2
    assert result['created_at'].loc[0] == pd.Timestamp('2026-09-22 10:30:00')
    assert pd.isna(result['created_at'].loc[1]) 
    assert pd.isna(result['price'].loc[1]) 
    assert pd.isna(result['quantity'].loc[1]) 

# Quest 14 — первый Integration Test
def test_load_and_convert_data_types(tmp_path):
    csv_path = tmp_path / 'table.csv'

    source = pd.DataFrame({
        'order_id': ['A1', 'A2'],
        'created_at': ['2026-09-22 10:30:00', 'wrong_date'],
        'price': ['100.5', 'wrong_price'],
        'quantity': ['2', '3']
    })

    source.to_csv(csv_path, index=False) 

    table = pipeline.load_data(csv_path)
    result = pipeline.convert_data_types(table)

    assert len(result) == 2
    assert result.columns.tolist() == [
        'order_id',
        'created_at',
        'price',
        'quantity'
    ]
    assert result['created_at'].loc[0] == pd.Timestamp('2026-09-22 10:30:00') 
    assert pd.isna(result['created_at'].loc[1])
    assert result['price'].loc[0] == 100.5 
    assert pd.isna(result['price'].loc[1])
    assert result['quantity'].loc[0] == 2

# Quest 18 — select_required_columns()
def test_select_required_columns():
    table = pd.DataFrame({
        'order_id': ['A1'],
        'product': ['Laptop'],
        'category': ['Electronics'],
        'price': [1000],
        'quantity': [2],
        'status': ['completed'],
        'store': ['Store_A'],
        'created_at': ['2026-09-22 10:30:00'],
        'debug_column': ['REMOVE_ME']
    })

    result = pipeline.select_required_columns(table)

    assert result.columns.tolist() == [
        'order_id',
        'product',
        'category',
        'price',
        'quantity',
        'status',
        'store',
        'created_at'
    ]
    assert 'debug_column' not in result.columns

def test_validate_data_empty_input():
    table = pd.DataFrame(columns=['order_id', 'price', 'quantity', 'created_at'])
    clean, quarantine, metrics = pipeline.validate_data(table)

    assert clean.empty
    assert quarantine.empty
    assert metrics == {
        'raw_records': 0,
        'clean_records': 0,
        'quarantine_records': 0,
        'clean_rate': 0.0
    }


def test_validate_data_null_order_id():
    table = pd.DataFrame({
        'order_id': [None, 'A2'],
        'price': [100, 200],
        'quantity': [1, 1],
        'created_at': pd.to_datetime(['2026-09-02', '2026-09-02'])
    })
    clean, quarantine, metrics = pipeline.validate_data(table)

    assert clean['order_id'].tolist() == ['A2']
    assert len(quarantine) == 1
    assert metrics['raw_records'] == 2
    assert metrics['clean_rate'] == 50.0
