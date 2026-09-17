import pandas as pd
import pytest

from day28 import transformations

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

