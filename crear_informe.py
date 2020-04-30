from informe import generate_data
from progress.bar import IncrementalBar
from datetime import date
import pandas as pd
import os
import numpy as np
import sys

def main():
    
    filename = sys.argv[1]
    DATA = pd.read_excel(filename, sheet_name='Cases')
    DEATHS = pd.read_excel(filename, sheet_name='Deaths')
    POP = pd.read_excel(filename, sheet_name='Population')
    Region = POP.columns
    Population = POP.loc[0]

    DATA['Dia'] = pd.to_datetime(DATA['Dia']).dt.strftime('%d/%m/%Y')
    DATA['DiaReverse'] = pd.to_datetime(DATA['Dia']).dt.strftime('%Y/%m/%d')

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

    bar = IncrementalBar('Processing', max=len(Region))
    for ID in range(len(Region)):
        data = DATA[Region[ID]]
        data = data.to_numpy()
        deaths = DEATHS[Region[ID]]
        deaths = deaths.to_numpy()
        
        generate_data(A, data, deaths, Region[ID], Population[ID])
        bar.next()
    bar.finish()

if __name__ == "__main__":
    main()