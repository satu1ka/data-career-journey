# Day 12 — Exceptions: закрепление
def parse_rows(pipeline):
    try:
        converted = int(pipeline['rows'])
        
    except TypeError:
        return None, 'Invalid rows type'
    
    except KeyError:
        return None, 'Missing rows'
    
    except ValueError:
        return None, 'Invalid rows value'

    if converted <= 0:
        return None, 'Invalid rows'

    return converted, None

pipelines = [
    {'name': 'orders', 'rows': '5000'},
    {'name': 'users', 'rows': 150},
    {'name': 'products', 'rows': '2500'}
]

print(parse_rows(pipelines[1]))