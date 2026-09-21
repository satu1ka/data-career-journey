import pytest
from day28 import config_utils

def test_validate_config_valid():
    config = {
        'process_date': '2026-09-17',
        'target_status': 'completed',
        'input_file': 'daily_sales.csv',
        'log_file': 'pipeline.log'
    }

    result = config_utils.validate_config(config)

    assert result == config

def test_validate_config_missing_key():
    config = {
        'process_date': '2026-09-17',
        'target_status': 'completed',
        'input_file': 'daily_sales.csv'
    }

    with pytest.raises(ValueError):
        config_utils.validate_config(config)

def test_validate_config_invalid_value_type():
    config = {
        'process_date': 20260917,
        'target_status': 'completed',
        'input_file': 'daily_sales.csv',
        'log_file': 'pipeline.log'
    }

    with pytest.raises(ValueError):
        config_utils.validate_config(config)

def test_validate_config_invalid_date_format():
    config = {
        'process_date': '17-09-2026',
        'target_status': 'completed',
        'input_file': 'daily_sales.csv',
        'log_file': 'pipeline.log'
    }

    with pytest.raises(ValueError):
        config_utils.validate_config(config)