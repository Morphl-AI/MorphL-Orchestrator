import datetime
from sys import argv, exit

def get_record(i, num_days_ago, n):
    dt = n - datetime.timedelta(days=num_days_ago)
    return (i, {'asYYYY-MM-DD': dt.strftime('%Y-%m-%d'),
                'as_py_code': dt.__repr__()})

OPTIONS = [5, 10, 30, 60, 120, 180, 270, 365]
opt_len = len(OPTIONS)
valid_inputs = set([str(i+1) for i in range(opt_len)])
n = datetime.datetime.now()
lookup_dict = \
    dict([get_record(i + 1, num_days_ago, n) for (i, num_days_ago) in enumerate(OPTIONS)])
for _ in range(5):
    print('')
print('How much historical data should be loaded?\n')
for (j, num_days_ago) in enumerate(OPTIONS):
    choice = j + 1
    print('{}) {} - present time ({} days worth of data)'.format(choice,
        lookup_dict[choice]['asYYYY-MM-DD'],
        num_days_ago))
print('')
entered_choice = input('Select one of the numerical options 1 thru {}: '.format(opt_len))
print('')
if entered_choice in valid_inputs:
    choice = int(entered_choice)
    with open(argv[1], 'w') as fh:
        fh.write(lookup_dict[choice]['as_py_code'])
else:
    print('No valid choice was selected, aborting.')
    print('')
    exit(1)
