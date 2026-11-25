# Python Core — Session 21 | CSV Processing, Part 2
import csv

# Quest 14 — реализуем Schema Validation
# Quest 16 — Empty File Handling
def process_csv(file_path):
    clean_rows = []
    quarantine_rows = []
    # делаем сэт с нужным набором колонок
    required_columns = {'name', 'rows', 'failed_rows'}

    with open(file_path, 'r') as file:
        reader = csv.DictReader(file)
        # проверяем пустоту пришедшего csv
        if reader.fieldnames is None:
            raise ValueError('We have empty file')
        # делаем сет с набором колонок, которые к нам пришли
        fieldnames_check = set(reader.fieldnames)
        # проверяем разность сетов
        difference = required_columns - fieldnames_check
        # проверяем, является ли разность существующей, если да, то выбрасываем ошибку
        if difference:
            raise ValueError(f'We have missing colums: {difference}')

        for line in reader:
            try:
                
                rows = int(line['rows'])
                failed_rows = int(line['failed_rows'])
                if rows < 0 or failed_rows < 0 or failed_rows > rows:
                    quarantine_rows.append(line)
                else:
                    line['rows'] = rows
                    line['failed_rows'] = failed_rows
                    clean_rows.append(line)
            except (ValueError, TypeError):
                quarantine_rows.append(line)

    return clean_rows, quarantine_rows

# with open('clean_pipelines.csv', 'w', newline='') as file:
#     writer = csv.DictWriter(file, fieldnames=['name', 'rows', 'failed_rows'])
#     writer.writeheader()
#     writer.writerows(clean_rows)

# # Quest 10 — Reusable CSV Writer
# columns = ['name', 'rows', 'failed_rows']

def write_csv(file_path, rows, fieldnames):
    with open(file_path, 'w', newline='') as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

# # Можно не объявлять переменную, потому что функция не делает ретурна, а выполняет действие
# write_csv('clean_pipelines.csv', clean_rows, columns)
# write_csv('quarantine_pipelines.csv', quarantine_rows, columns)

# # Quest 11 — Pipeline Orchestration
# def main(file_path):
#     columns = ['name', 'rows', 'failed_rows']
#     clean_rows, quarantine_rows = process_csv(file_path)
#     write_csv('clean_pipelines.csv', clean_rows, columns)
#     write_csv('quarantine_pipelines.csv', quarantine_rows, columns)
#     print('Pipeline completed')
#     print(f'Total rows: {len(clean_rows) + len(quarantine_rows)}')
#     print(f'Clean rows: {len(clean_rows)}')
#     print(f'Quarantine rows: {len(quarantine_rows)}')

# main('pipelines.csv')

# Quest 12 — Failure Handling
def main(file_path):
    columns = ['name', 'rows', 'failed_rows']
    try:
        clean_rows, quarantine_rows = process_csv(file_path)
        write_csv('clean_pipelines.csv', clean_rows, columns)
        write_csv('quarantine_pipelines.csv', quarantine_rows, columns)
        print('Pipeline completed')
        print(f'Total rows: {len(clean_rows) + len(quarantine_rows)}')
        print(f'Clean rows: {len(clean_rows)}')
        print(f'Quarantine rows: {len(quarantine_rows)}')
    except FileNotFoundError as error:
        print(error)
    except ValueError as error:
        print(error)

main('pipelines.csv')

# Quest 21 — Final Practice
pipeline = {
    'name': 'orders',
    'rows': 5000,
    'status': 'completed'
}

def validate_pipeline(pipeline):
    required_keys = {'name', 'rows', 'status'}
    pipeline_set = set(pipeline.keys())
    difference = required_keys - pipeline_set
    if difference:
        raise ValueError(f'We lost: {difference}')
    elif pipeline.get('rows') is None:
        return False
    else:
        return True


pl = validate_pipeline(pipeline)
print(pl)