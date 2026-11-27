# Python Core — Day 23 | Reliable JSON Pipeline

# Quest 2 — Root Structure Validation
import json

# try:
#     with open('pipelines.json', 'r') as file:
#         data = json.load(file)

#     if not isinstance(data, list):
#         raise ValueError('Our JSON supposed to be LIST')

#     total_rows = 0
#     total_failed_rows = 0
#     clean_pipelines = []
#     quarantine_pipelines = []
#     required_keys = {'name', 'rows', 'failed_rows', 'active'}

#     for pipeline in data: 
#         if not isinstance(pipeline, dict):
#             quarantine_pipelines.append(pipeline)
#             continue   
#         columns_name = set(pipeline)
#         difference = required_keys - columns_name
#         if difference:
#             quarantine_pipelines.append(pipeline)
#             continue
#         if (
#             type(pipeline['rows']) is not int
#             or type(pipeline['failed_rows']) is not int
#         ):
#             quarantine_pipelines.append(pipeline)
#             continue
#         if (
#             pipeline['rows'] < 0 
#             or pipeline['failed_rows'] < 0
#             or pipeline['failed_rows'] > pipeline['rows']
#         ):
#             quarantine_pipelines.append(pipeline)
#             continue
#         clean_pipelines.append(pipeline)
#         total_rows += pipeline['rows']
#         total_failed_rows += pipeline['failed_rows']

#     # print(f'Total rows: {total_rows}')
#     # print(f'Total failed rows: {total_failed_rows}')
#     # print(f'Clean records: {len(clean_pipelines)}')
#     # print(f'Quarantine records: {len(quarantine_pipelines)}')
#     # print(clean_pipelines)
#     # print(quarantine_pipelines)

# except FileNotFoundError:
#     print('we dont have file to ope')
# except json.JSONDecodeError as error:
#     print(f'we have an error: {error}')
# except ValueError as error:
#     print(f'Validation error: {error}')

# # Quest 8 — Writing JSON
# with open('clean_pipelines.json', 'w') as file:
#     json.dump(clean_pipelines, file, indent=4)

# with open('quarantine_pipelines.json', 'w') as file:
#     json.dump(quarantine_pipelines, file, indent=4)

# Quest 9 — Refactoring: Reusable Functions
def read_json(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)

    if not isinstance(data, list):
        raise ValueError('Our JSON supposed to be LIST')

    return data

# Quest 10 — Refactoring: Validation Layer
def validate_pipeline(pipeline):
    required_keys = {'name', 'rows', 'failed_rows', 'active'}

    if not isinstance(pipeline, dict):
        return False   
    columns_name = set(pipeline)
    difference = required_keys - columns_name
    if difference:
        return False 

    if (
        type(pipeline['rows']) is not int
        or type(pipeline['failed_rows']) is not int
    ):
        return False 

    if (
        pipeline['rows'] < 0 
        or pipeline['failed_rows'] < 0
        or pipeline['failed_rows'] > pipeline['rows']
    ):
        return False

    return True

# # Quest 11 — использовать validate_pipeline() в основном цикле
# total_rows = 0
# total_failed_rows = 0
# clean_pipelines = []
# quarantine_pipelines = []

# for pipeline in data: 
#     if validate_pipeline(pipeline):
#         clean_pipelines.append(pipeline)
#         total_rows += pipeline['rows']
#         total_failed_rows += pipeline['failed_rows']
#     else:
#         quarantine_pipelines.append(pipeline)

# print(f'Total rows: {total_rows}')
# print(f'Total failed rows: {total_failed_rows}')
# print(f'Clean records: {len(clean_pipelines)}')
# print(f'Quarantine records: {len(quarantine_pipelines)}')

# Quest 12 — Refactoring: Processing Layer
def process_pipelines(data):
    total_rows = 0
    total_failed_rows = 0
    clean_pipelines = []
    quarantine_pipelines = []

    for pipeline in data: 
        if validate_pipeline(pipeline):
            clean_pipelines.append(pipeline)
            total_rows += pipeline['rows']
            total_failed_rows += pipeline['failed_rows']
        else:
            quarantine_pipelines.append(pipeline)

    return total_rows, total_failed_rows, clean_pipelines, quarantine_pipelines

# Quest 13 — Refactoring: Output Layer
def write_json(file_path, data):
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=4)

# Quest 14 — Orchestration через main()
def main(file_path):
    try:
        data = read_json(file_path)

        total_rows, total_failed_rows, clean_pipelines, quarantine_pipelines = process_pipelines(data)

        write_json('clean_pipelines.json', clean_pipelines)
        write_json('quarantine_pipelines.json', quarantine_pipelines)
        
        print(f'Total rows: {total_rows}')
        print(f'Total failed rows: {total_failed_rows}')
        print(f'Clean records: {len(clean_pipelines)}')
        print(f'Quarantine records: {len(quarantine_pipelines)}')

    except FileNotFoundError:
        print('we dont have file to ope')
    except json.JSONDecodeError as error:
        print(f'we have an error: {error}')
    except ValueError as error:
        print(f'Validation error: {error}')

main('pipelines.json')