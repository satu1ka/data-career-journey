import json
import pandas as pd

def load_config(config_path):
    with open(config_path, encoding='utf-8') as config_file:
        pipeline_config = json.load(config_file)

    return pipeline_config

def validate_config(config):
    required_keys = [
        'process_date',
        'target_status',
        'input_file',
        'log_file'
    ]

    missing_keys = []

    for item in required_keys:
        if item not in config:
            missing_keys.append(item)

    if missing_keys:
        raise ValueError(f'Missing required keys: {missing_keys}')

    for item in required_keys:
        if not isinstance(config[item], str):
            raise ValueError(f'Config value for {item} must be str')        
    try:
        pd.to_datetime(config['process_date'], format='%Y-%m-%d')
    except ValueError:
        raise ValueError(f'Invalid process_date: {config['process_date']}'
    ) from None

    return config