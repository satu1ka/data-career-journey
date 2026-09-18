import pandas as pd
import pytest

from day29 import transformations

def test_business_filtering():
    table = pd.DataFrame({
        'order_id': ['1', '2', '3'],
        'status': ['completed', 'pending', 'completed']
    })

    target_status = 'completed'

    expected = pd.DataFrame({
        'order_id': ['1', '3'],
        'status': ['completed', 'completed']
    }, index=[0, 2])

    result = transformations.business_filtering(table, target_status)

    pd.testing.assert_frame_equal(result, expected)

# Quest 4 - бессмысленный и чисто на рефакторинг был
def test_business_filtering_returns_only_target_status():
    table = pd.DataFrame({
        'order_id': ['1', '2', '3', '4'],
        'status': ['completed', 'cancelled', 'completed', 'pending']
    })

    result = transformations.business_filtering(table, 'completed')
    
    assert len(result) == 2
    assert (result['status'] == 'completed').all()

# Quest 1
def test_filter_by_date():
    table = pd.DataFrame({
        'created_at': ['2026-09-01', '2026-10-01', '2026-09-01']
    })

    table['created_at'] = pd.to_datetime(table['created_at'])

    process_date = '2026-09-01'

    expected = pd.DataFrame({
        'created_at': ['2026-09-01', '2026-09-01']
    }, index=[0, 2])

    expected['created_at'] = pd.to_datetime(expected['created_at'])

    result = transformations.filter_by_date(table, process_date)

    pd.testing.assert_frame_equal(result, expected)

# Quest 5
def test_enrich_time_data():
    table = pd.DataFrame({
        'created_at': ['2026-09-18 14:35:00']
    })

    table['created_at'] = pd.to_datetime(table['created_at'])

    result = transformations.enrich_time_data(table)

    assert result['order_date'].iloc[0] == pd.to_datetime('2026-09-18').date()
    assert result['order_hour'].iloc[0] == 14
    assert result['day_of_week'].iloc[0] == 'Friday'
    assert result['time_of_day'].iloc[0] == 'afternoon'