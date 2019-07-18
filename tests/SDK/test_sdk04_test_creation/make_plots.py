import matplotlib
import matplotlib.pyplot as plt
from matplotlib.pyplot import figure

figure(num=None, figsize=(10, 4), dpi=80, facecolor='w', edgecolor='k')

scales = range(1, 11)

with open('timing.txt', 'r') as f:
    records = f.readlines()

raw_data = {
    'deploy': {scale: [] for scale in scales},
    'testing': {scale: [] for scale in scales},
}

for record in records:
    c = record.split()
    function = c[0][:-1]
    scale = int(c[2][:-1]) 
    time = float(c[4])
    raw_data[function][scale].append(time)

data = {}
for function in ['deploy', 'testing']:
    data[function] = [sum(raw_data[function][scale]) / 10 for scale in scales]


plt.subplot(1, 2, 1)
plt.plot(scales, data['deploy'], 'o-', label='Deployment')
plt.xlabel('Number of IDS instances')
plt.ylabel('time (s)')
plt.title('Service deployment')

plt.subplot(1, 2, 2, autoscalex_on=True)
plt.plot(scales, data['testing'], 'o-', label='Tesing')
plt.xlabel('Number of IDS instances')
plt.ylabel('time (s)')
plt.title('Test execution')

plt.tight_layout()
plt.savefig('plot.png')
