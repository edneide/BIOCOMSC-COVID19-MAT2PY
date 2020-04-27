from informe import generate_data
from datetime import date
import pandas as pd
import os
import numpy as np

Spain = ['Andalucia', 'Aragon', 'Asturias', 'Baleares', 'Canarias', 'Cantabria',
         'Castilla-La Mancha', 'Castilla y Leon', 'Catalunya', 'Ceuta', 'Comunitat Valenciana',
         'Extremadura', 'Galicia', 'Madrid', 'Melilla', 'Murcia', 'Navarra', 'Euskadi', 'La Rioja', 'Total']
population = [8414240, 1319291, 1022800, 1149460, 2153389, 581078, 2032863, 2399548, 7675217, 84777,
              5003769, 1067710, 2699499, 6663394, 86487, 1493898, 654214, 2207776, 316798, 47026208]
guardar = True
txt = True
filename = './covid19/data/Data_Spain_v2.xlsx'
DATA = pd.read_excel(filename, sheet_name='Cases')
DEATHS = pd.read_excel(filename, sheet_name='Deaths')

DATA['Dia'] = pd.to_datetime(DATA['Dia']).dt.strftime('%d/%m/%Y')
DATA['DiaReverse'] = pd.to_datetime(DATA['Dia']).dt.strftime('%Y/%m/%d')

names = DATA.columns

Avec = DATA['Dia']
Avec = Avec.to_numpy()

AvecReverse = DATA['DiaReverse']
AvecReverse = AvecReverse.to_numpy()

A = np.zeros((len(Avec), 1))

for i in range(len(Avec)):
    y, m, d = map(int, AvecReverse[i].split('/'))
    if not np.char.isnumeric(Avec[i]):

        dateNum = date.toordinal(date(y, m, d))
        A[i] = dateNum
    else:
        A[i] = Avec[i]
lastDate = Avec[len(Avec) - 1]
lastDate = np.char.replace(lastDate, '/', '_')
outLastDate = np.array_str(lastDate)
yF = 'Reports_Spain/' + outLastDate + '_GitHub'
path = os.getcwd()
path = path + '/' + yF
try:
    os.makedirs(path, exist_ok=True)
except OSError:
    print("Creation of the directory %s failed" % path)
else:
    print("Successfully created the directory %s " % path)

id = np.full((len(Spain), 4), 0)

for ID in range(len(Spain)):
    data = DATA[Spain[ID]]
    data = data.to_numpy()

    deaths = DEATHS[Spain[ID]]
    deaths = deaths.to_numpy()
    generate_data(A, data, deaths, Spain[ID], population[ID], guardar, yF)
    break

'''
    print("-----------------------------------------------------------")
    print(Spain[ID])
    print("-----------------------------------------------------------")
    print("Cases")
    print(data)
    print("Deaths")
    print(deaths)
    #xp, yp, ep =
'''
