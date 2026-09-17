# Quest 1 — Build the startup layer
# Нужно сделать startup-часть, которая:
# 1. Находит директорию текущего Python-файла
# 2. Строит путь:
#    config/config.json
# 3. Создаёт logs/ при необходимости
# 4. Создаёт startup.log
# 5. Загружает JSON config
# 6. Проверяет наличие обязательных ключей:
#    process_date
#    target_status
#    input_file
#    log_file
# 7. Проверяет, что все четыре значения — str
# 8. Проверяет, что process_date действительно является датой
# 9. Если config некорректный:
#    → записать exception в startup.log
#    → остановить программу

from pathlib import Path
import json
import logging
import pandas as pd
# 1
script_dir = Path(__file__).resolve().parent
# 3
# задаем директории для логов
logs_dir = script_dir / 'logs'
logs_dir.mkdir(exist_ok=True)
# 4
startup_log_path = logs_dir / 'startup.log'
# задаем формат логов
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s | %(levelname)s | %(message)s',
    handlers=[
        logging.FileHandler(startup_log_path)
    ]
)
# 2
# задаем директории для конфига
config_dir = script_dir / 'config'
config_path = config_dir / 'config.json'
# заводим функцию, которая валидирует наш конфиг
# 6
def validate_config(config):
    required_keys = [
        'process_date',
        'target_status',
        'input_file',
        'log_file'
    ]

    missing_keys = []
    # проверяем наличие всех нужных ключей
    for key in required_keys:
        if key not in config:
            missing_keys.append(key)
    # выдаем ошибку, если ключей не хватает
    if missing_keys:
        raise ValueError(f'Missing required keys: {missing_keys}')
    # 7
    # проверяем, что значения ключей являются строками
    for key in required_keys:
        if not isinstance(config[key], str):
            raise ValueError(f'Config value for {key} must be str')
    # 8
    # проверяем, можно ли распарсить строку в process_date как дату
    try:
        pd.to_datetime(config['process_date'])
    except ValueError:
        raise ValueError(f'Invalid process_date: {config["process_date"]}'
    ) from None

    return config
# 5
# загружаем конфиг
try:
    with open(config_path, encoding='utf-8') as config_file:
        pipeline_config = json.load(config_file)

    pipeline_config = validate_config(pipeline_config)
# 9
# выкидываем ошибку, если конфиг внутри файла некорректен
except json.JSONDecodeError as error:
    logging.exception(f'Invalid JSON config: {error}')
    raise

except ValueError as error:
    logging.exception(f'Invalid pipeline configuration: {error}')
    raise

# Quest 2 — Data loading + schema + types
# 1. Построить путь к входному CSV:
#    data/<input_file из config>
# 2. Загрузить CSV в DataFrame.
# 3. Проверить наличие колонок:
#    order_id
#    product
#    category
#    price
#    quantity
#    status
#    store
#    created_at
# 4. Если обязательной колонки нет → ValueError.
# 5. После schema validation оставить только required columns.
# 6. Преобразовать:
#    created_at → datetime
#    price      → numeric
#    quantity   → numeric
#    Некорректные значения должны превращаться в NaN/NaT,
#    а не ломать pipeline.

# 1
data_dir = script_dir / 'data'
csv_path = data_dir / pipeline_config['input_file']
# 2
def load_data(csv_path):
    table = pd.read_csv(csv_path)

    return table
# 3
def validate_schema(table):
    required_columns = [
        'order_id',
        'product',
        'category',
        'price',
        'quantity',
        'status',
        'store',
        'created_at'
    ]

    missing_columns = []

    for column in required_columns:
        if column not in table.columns:
            missing_columns.append(column)
    # 4
    if missing_columns:
        raise ValueError(f'Missing required columns: {missing_columns}')

    return table
# 5
def select_required_columns(table):
    required_columns = [
        'order_id',
        'product',
        'category',
        'price',
        'quantity',
        'status',
        'store',
        'created_at'
    ]

    table = table[required_columns].copy()

    return table
# 6
def convert_data_types(table):
    table = table.copy()

    table['created_at'] = pd.to_datetime(
        table['created_at'],
        errors='coerce'
    )
    table['price'] = pd.to_numeric(
        table['price'],
        errors='coerce'
    )
    table['quantity'] = pd.to_numeric(
        table['quantity'],
        errors='coerce'
    )

    return table

# Quest 3 — Data Quality + clean/quarantine
# Нужно сделать функцию:
# validate_data(table)
# Требования:
# 1. Невалидная строка, если:
#    price is NaN
#    OR quantity is NaN
#    OR created_at is NaT
# 2. Разделить данные на:
#    clean_orders
#    quarantine_orders
# 3. Посчитать метрики:
#    raw_orders
#    clean_orders
#    quarantine_orders
#    clean_rate
# 4. clean_rate в процентах, с округлением до 2 знаков.
# 5. Вернуть:
#    clean_orders,
#    quarantine_orders,
#    dq_metrics
# Формат dq_metrics:
# {
#     'raw_orders': ...,
#     'clean_orders': ...,
#     'quarantine_orders': ...,
#     'clean_rate': ...
# }

def validate_data(table):
    # 1
    invalid_price_condition = (
        table['price'].isna()
    )
    invalid_quantity_condition = (
        table['quantity'].isna()
    )
    invalid_date = (
        table['created_at'].isna()
    )

    invalid_condition = (
        invalid_price_condition |
        invalid_quantity_condition |
        invalid_date
    )
    # 2
    clean_orders = table[
        ~invalid_condition
    ].copy()

    quarantine_orders = table[
        invalid_condition
    ].copy()
    # 3
    raw_orders_count = len(table)
    clean_orders_count = len(clean_orders)
    quarantine_orders_count = len(quarantine_orders)
    if raw_orders_count == 0:
        clean_rate = 0
    else:
        clean_rate = round(clean_orders_count / raw_orders_count * 100, 2)
    # 4
    dq_metrics = {
        'raw_orders': raw_orders_count,
        'clean_orders': clean_orders_count,
        'quarantine_orders': quarantine_orders_count,
        'clean_rate': clean_rate
    }
    # 5
    return clean_orders, quarantine_orders, dq_metrics

# Quest 4 — Date filter + business filter + enrichment
# Нужно собрать три отдельные функции:
# 1. filter_by_date(table, process_date)
# 2. business_filtering(table, target_status)
# 3. enrich_time_data(table)
# Требования:
# filter_by_date
# → оставить только строки, где created_at соответствует process_date
# business_filtering
# → оставить только строки, где status == target_status
# enrich_time_data
# → добавить:
#    order_date
#    order_hour
#    day_of_week
#    revenue
#    time_of_day
# Для time_of_day правила такие:
# 00:00–11:59 → Morning
# 12:00–17:59 → Afternoon
# 18:00–23:59 → Evening

# 1
def filter_by_date(table, process_date):
    our_date = pd.to_datetime(process_date).date()
    table_condition = (table['created_at'].dt.date == our_date)

    our_table = table[
        table_condition
    ].copy()

    return our_table
# 2
def business_filtering(table, target_status):
    business_table = table[
        table['status'] == target_status
    ].copy()

    return business_table
# 3
def enrich_time_data(table):
    table = table.copy()
    table['order_date'] = table['created_at'].dt.date
    table['order_hour'] = table['created_at'].dt.hour
    table['day_of_week'] = table['created_at'].dt.day_name()
    table['revenue'] = table['price'] * table['quantity']

    table.loc[
        table['order_hour'] < 12,
        'time_of_day'
    ] = 'Morning'
    table.loc[
        (table['order_hour'] >= 12) & (table['order_hour'] < 18),
        'time_of_day'
    ] = 'Afternoon'
    table.loc[
        table['order_hour'] >= 18,
        'time_of_day'
    ] = 'Evening'

    return table

# Quest 5 — Aggregation + reporting
# Нужно построить:
# build_daily_summary(table)
# Требования к результату — одна строка на order_date с колонками:
# order_date
# orders_count
# total_revenue
# average_order_revenue

def build_daily_summary(table):
    orders_count = table.groupby('order_date')['order_id'].count()
    total_revenue = table.groupby('order_date')['revenue'].sum()
    average_order_revenue = table.groupby('order_date')['revenue'].mean()

    daily_summary = pd.DataFrame({
        'orders_count': orders_count,
        'total_revenue': total_revenue,
        'average_order_revenue': average_order_revenue
    }).reset_index()

    return daily_summary

# Quest 6 — Orchestration / main()
# Нужно написать:
# main(process_date, target_status, csv_path)
# Требования:
# 1. Логируем старт pipeline.
# 2. Загружаем данные.
# 3. Schema validation.
# 4. Оставляем required columns.
# 5. Приводим типы.
# 6. DQ:
#    → clean_orders
#    → quarantine_orders
#    → dq_metrics
# 7. Если quarantine_orders > 0:
#    → WARNING
# 8. Логируем DQ metrics.
# 9. Фильтруем clean_orders по process_date.
# 10. Если после date filter пусто:
#     → WARNING
#     → дальше business/enrichment/summary не выполнять.
# 11. Иначе фильтруем по target_status.
# 12. Если business_orders пуст:
#     → WARNING
#     → enrichment/summary не выполнять.
# 13. Иначе:
#     → enrich_time_data
#     → build_daily_summary
# 14. Ошибки:
#     ValueError
#     FileNotFoundError
#     → logging.exception()
# 15. Если ошибок не было:
#     → INFO Pipeline completed successfully
# 16. В любом случае:
#     → INFO Pipeline execution finished

def main(process_date, target_status, csv_path):
    try:
        # 1
        logging.info('Pipeline started')
        # 2
        table = load_data(csv_path)
        # 3
        table = validate_schema(table)
        # 4
        table = select_required_columns(table)
        # 5
        table = convert_data_types(table)
        # 6
        clean_orders, quarantine_orders, dq_metrics = validate_data(table)
        # 7
        if dq_metrics['quarantine_orders'] > 0:
            logging.warning(f"Take a look, we got quarantine orders! And there is {dq_metrics['quarantine_orders']} of them!")
        # 8
        logging.info(
            f'Raw records: {dq_metrics["raw_orders"]} |'
            f'Clean records: {dq_metrics["clean_orders"]} |'
            f'Quarantine records: {dq_metrics["quarantine_orders"]} |'
            f'Clean rate: {dq_metrics["clean_rate"]}'
        )
        # 9
        table = filter_by_date(clean_orders, process_date)
        # 10
        if table.empty:
            logging.warning(f'No clean orders found for process date {process_date}')
        # 11
        else:
            table = business_filtering(table, target_status)
            # 12
            if table.empty:
                logging.warning(f'No {target_status} orders found for process date {process_date}')
            # 13
            else:
                enriched_orders = enrich_time_data(table)
                daily_summary = build_daily_summary(enriched_orders)
    # 14
    except ValueError as error:
        logging.exception(f'We got an error: {error}')
    except FileNotFoundError as error:
        logging.exception(f"We can't continue, cause: {error}")
    # 15
    else:
        logging.info('Pipeline completed successfully')
    # 16
    finally:
        logging.info('Pipeline execution finished')

main(pipeline_config['process_date'], pipeline_config['target_status'], csv_path)