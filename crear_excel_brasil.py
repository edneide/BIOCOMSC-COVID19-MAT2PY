"""

Code by Renato Pessoa e Melo Neto

Returns:
    [String] -- [formated excel path]
"""

import pandas as pd
from pandas import ExcelWriter
import sys
pathToBrasil = "https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv"

def run_crear_excel_brasil():
    dados = pd.read_csv(pathToBrasil)
    print('Data obtained from: ', pathToBrasil)
    dados_semTotal = dados[dados['state'] != 'TOTAL']

    #print(dados_semTotal)

    #dados_semTotal.set_index('date', inplace=True)

    dados_semTotal.set_index('date', 'state', inplace=True)
    #print(dados_semTotal)

    siglasEstados=[ "AC","AL","AP","AM","BA","CE",
                    "DF","ES","GO","MA","MT","MS",
                    "MG","PA","PB","PR","PE","PI","RJ",
                    "RN","RS","RO","RR","SC","SP","SE","TO" ]

    unique_dates = dados_semTotal.index.get_level_values('date').unique()
    #print(unique_dates)
    
    dfByTotalCases = dataFramePorColuna('totalCases', unique_dates, siglasEstados, dados_semTotal)
    #print(dfByTotalCases)

    dfByTotalDeaths = dataFramePorColuna('deaths', unique_dates, siglasEstados, dados_semTotal)
    #print(dfByTotalDeaths)
    
    
    with ExcelWriter('data/Data_Brasil.xlsx') as writer:
        
        dfByTotalCases.to_excel(writer, sheet_name='Cases')
        dfByTotalDeaths.to_excel(writer, sheet_name='Deaths')



def dataFramePorColuna(coluna, unique_dates, siglasEstados, dados_semTotal):

    resul = pd.DataFrame(index=unique_dates, columns = siglasEstados)
    #print(resul)

    for estado in siglasEstados :
        test = dados_semTotal.query('state == @estado ')
        resul[estado] = test[coluna]

    resul.fillna(0, inplace=True)
    #print(resul)
    resul['Total'] = resul.sum(axis=1)
    return resul


