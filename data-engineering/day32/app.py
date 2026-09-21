from pathlib import Path
import logging
import json

from . import config_utils
from . import pipeline
from . import transformations

script_dir = Path(__file__).resolve().parent.parent

config_dir = script_dir / 'config'
config_path = config_dir / 'config.json'

logs_dir = script_dir /'logs'
data_dir = script_dir / 'data'

startup_log_path = logs_dir / 'startup.log'

def setup_startup_logging():
    logs_dir.mkdir(exist_ok=True)

    logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s | %(levelname)s | %(message)s',
    handlers=[
        logging.FileHandler(startup_log_path),
        logging.StreamHandler()
    ]
)

def setup_pipeline_logging(log_path):
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s | %(levelname)s | %(message)s',
        handlers=[
            logging.FileHandler(log_path),
            logging.StreamHandler()
        ], 
        force=True
)

def main(process_date, target_status, csv_path):
    try:
        logging.info('Pipeline started')
        table = pipeline.load_data(csv_path)
        logging.info('Data loaded successfully')
        table = pipeline.validate_schema(table)
        table = pipeline.select_required_columns(table)
        table = pipeline.convert_data_types(table)

        clean_orders, quarantine_orders, dq_metrics = pipeline.validate_data(table)

        if dq_metrics['quarantine_orders'] > 0:
            logging.warning(f'There are {dq_metrics['quarantine_orders']} quarantine orders after data validation')

        logging.info(
            f'Data validation completed: '
            f'Raw records: {dq_metrics['raw_records']} | '
            f'Clean records: {dq_metrics['clean_records']} | '
            f'Quarantine records: {dq_metrics['quarantine_orders']} | '
            f'Clean rate: {dq_metrics['clean_rate']}'
        )

        table_filtered_by_date = transformations.filter_by_date(clean_orders, process_date)

        if table_filtered_by_date.empty:
            logging.warning(f'No clean orders found for process date {process_date}')
        else:
            business_orders = transformations.business_filtering(table_filtered_by_date, target_status)
            if business_orders.empty:
                logging.warning(f'No {target_status} orders found for process date {process_date}')
            else:
                enriched_revenue_orders = transformations.enrich_revenue(business_orders)
                enriched_time_orders = transformations.enrich_time_data(enriched_revenue_orders)
                daily_summary = transformations.build_daily_summary(enriched_time_orders)     
    
    except ValueError as error:
        logging.exception(f'We lost something: {error}')
    except FileNotFoundError as error:
        logging.exception(f"Can't continue, cause: {error}")

    else:
        logging.info('Pipeline completed successfully')

    finally:
        logging.info('Pipeline execution finished') 

def run():     
    setup_startup_logging()
    try:
        pipeline_config = config_utils.load_config(config_path)
        pipeline_config = config_utils.validate_config(pipeline_config)

    except FileNotFoundError as error:
        logging.exception(f'Config file not found: {error}')
        raise

    except json.JSONDecodeError as error:
        logging.exception(f'Invalid JSON config: {error}')
        raise

    except ValueError as error:
        logging.exception(f'Invalid pipeline configuration {error}')
        raise

    csv_path = data_dir / pipeline_config['input_file']
    log_path = logs_dir / pipeline_config['log_file']

    setup_pipeline_logging(log_path)

    main(pipeline_config['process_date'], pipeline_config['target_status'], csv_path)

if __name__ == '__main__':
    run()