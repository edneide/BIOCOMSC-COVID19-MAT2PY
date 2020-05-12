import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.colors import ListedColormap
from matplotlib.backends.backend_pdf import PdfPages
from pandas import ExcelWriter
from crear_excel_brasil import run_crear_excel_brasil

def gradient_image(ax, extent, direction=0.3, cmap_range=(0, 1), **kwargs):
    """
    Draw a gradient image based on a colormap.

    Parameters
    ----------
    ax : Axes
        The axes to draw on.
    extent
        The extent of the image as (xmin, xmax, ymin, ymax).
        By default, this is in Axes coordinates but may be
        changed using the *transform* kwarg.
    direction : float
        The direction of the gradient. This is a number in
        range 0 (=vertical) to 1 (=horizontal).
    cmap_range : float, float
        The fraction (cmin, cmax) of the colormap that should be
        used for the gradient, where the complete colormap is (0, 1).
    **kwargs
        Other parameters are passed on to `.Axes.imshow()`.
        In particular useful is *cmap*.
    """
    phi = direction * np.pi / 2
    v = np.array([np.cos(phi), np.sin(phi)])
    X = np.array([[v @ [1, 0], v @ [1, 1]],
                  [v @ [0, 0], v @ [0, 1]]])
    a, b = cmap_range
    X = a + (b - a) / X.max() * X
    im = ax.imshow(X, extent=extent, alpha=0.45, interpolation='bicubic',
                   vmin=0, vmax=1, **kwargs)
    return im

def main():
    try:
        filename = sys.argv[1]
    except:
        print('Error! Usage: python3 risk_diagrams.py brasil')
        sys.exit()
        
    if filename == 'brasil':
        brasil = True
        pt = True
        try:
            run_crear_excel_brasil()
            filename =  'data/Data_Brasil.xlsx'
            filename_population = 'data/pop_Brasil_v2.xlsx'

        except AttributeError:
            print('Error! Not found file or could not download!')
        
        DATA = pd.read_excel(filename, sheet_name='Cases')
        POPULATION = pd.read_excel(filename_population)
        DIA  = pd.to_datetime(DATA['date']).dt.strftime('%d/%m/%Y')
        dia = DIA.to_numpy()
        Region = POPULATION.columns
        brasil_region = 27
        for ID in range(len(Region)):
            #ID = 6 
            cumulative_cases = DATA[Region[ID]] # Region for ALL
            cumulative_cases = cumulative_cases.to_numpy()
            new_cases = np.zeros((len(cumulative_cases)), dtype=np.int)
            for i in range(len(cumulative_cases)):
                if i != 0: new_cases[i] = cumulative_cases[i] - cumulative_cases[i - 1]
        
            p = np.zeros((len(new_cases)), dtype=np.float)
            for i in range(7, len(new_cases)): 
                div = 0
                aux = new_cases[i-5]+ new_cases[i-6] + new_cases[i-7]
                if aux == 0:
                    div = 1
                else:
                    div = aux
                p[i] = min((new_cases[i]+new_cases[i-1]+new_cases[i-2])/div, 4)
                
            p_seven = np.zeros((len(new_cases)), dtype=np.float)
            n_14_days = np.zeros((len(new_cases)), dtype=np.float)
            a_14_days = np.zeros((len(new_cases)), dtype=np.float)
            risk = np.zeros((len(new_cases)), dtype=np.float)
            risk_per_10 = np.zeros((len(new_cases)), dtype=np.float)
            for i in range(13, len(new_cases)): 
                p_seven[i] = np.average(p[i - 6:i + 1])
                n_14_days[i] = np.sum(new_cases[i - 13: i + 1])
                pop = POPULATION[Region[ID]] #204449000
                #pop *= 1000
                a_14_days[i] = n_14_days[i] / pop * 100000
                risk[i] = n_14_days[i]  * p_seven[i]
                risk_per_10[i] = a_14_days[i]  * p_seven[i]
                #print(dia[i], cumulative_cases[i], new_cases[i], p[i], p_seven[i], n_14_days[i], a_14_days[i], risk[i], risk_per_10[i])
            first_day = dia[13]
            last_day = dia[len(dia) - 1]
            first_day = first_day.replace('/','-')
            last_day = last_day.replace('/','-')
            if brasil and not pt:
                savePath = 'reports_pdf/brasil/risk/'+last_day+'-'+Region[ID]+'.pdf'
            elif brasil and pt:
                savePath = 'reports_pdf/brasil/risk-pt/'+last_day+'-'+Region[ID]+'.pdf'
            else:
                savePath = 'reports_pdf/risk/'+last_day+'-'+Region[ID]+'.pdf'
            with PdfPages(savePath) as pdf:
                fig1, ax1 = plt.subplots()
                ax1.plot(a_14_days, p_seven, 'ko--', fillstyle='none', linewidth=0.5)
                lim = ax1.get_xlim()
                x = np.ones(int(lim[1]))
                ax1.plot(x, 'k-', fillstyle='none', linewidth=0.5)
                ax1.set_ylim(0, 4)
                #ax1.set_xlim(0, len(x))
                if brasil and pt:
                    ax1.set_ylabel('$\u03C1$ (média dos últimos 7 dias)')
                    ax1.set_xlabel('Taxa de ataque por $10^5$ hab. (últimos 14 dias)')
                else:
                    ax1.set_ylabel('$\u03C1$ (mean of the last 7 days)')
                    ax1.set_xlabel('Attack rate per $10^5$ inh. (last 14 days)')
                ax1.annotate(first_day,
                                xy=(a_14_days[13], p_seven[13]), xycoords='data',
                                xytext=(len(x) - abs(len(x)/2), 3), textcoords='data',
                                arrowprops=dict(arrowstyle="->",
                                                connectionstyle="arc3", linewidth=0.4),
            )
                ax1.annotate(last_day,
                                xy=(a_14_days[len(a_14_days) - 1], p_seven[len(p_seven) - 1]), xycoords='data',
                                xytext=(len(x) - abs(len(x)/3), 3.5), textcoords='data',
                                arrowprops=dict(arrowstyle="->",
                                                connectionstyle="arc3", linewidth=0.4),
            )
                

                if brasil: 
                    bra_title = Region[ID] + ' - Brasil'
                    plt.title(bra_title)
                else:
                    plt.title(Region[ID])
                color_map = plt.cm.hsv
                cmap = color_map.reversed()
                gradient_image(ax1, direction=0.4, extent=(0, 1, 0, 1), transform=ax1.transAxes,
                cmap=cmap, cmap_range=(0.6, 1.1))
                ax1.set_aspect('auto')
                fig1.tight_layout()
                #plt.show()
                #plt.close()
                if brasil and pt:
                    savePathImg = 'reports_pdf/brasil/risk-pt/'+last_day+'-'+Region[ID]+'.png'
                    plt.savefig(savePathImg, bbox_inches='tight', dpi=300)    
                try:
                    pdf.savefig(fig1)
                    plt.close('all')
                    print("\n\nPrediction for the region of "+Region[ID]+" performed successfully!\nPath:" + savePath)
                except:
                    print("An exception occurred")
            '''
            df = pd.DataFrame({
                                'Day': DIA,
                                'Cumulative cases': cumulative_cases,
                                'New cases': new_cases,
                                'ρ': p,
                                'ρ7': p_seven,
                                'New cases last 14 days (N14)': n_14_days,
                                'New cases last 14 days per 105 inhabitants (A14)': a_14_days,
                                'Risk (N14*ρ7)': risk,
                                'Risk per 105 (A14*ρ7)': risk_per_10,
                                'population':pop 
      
            })
            with ExcelWriter('/home/allissondantas/Matlab/Code/Indexs_Brasil-sp.xlsx') as writer:
                df.to_excel(writer, sheet_name='Alt_Urgell')
            '''
            #break
if __name__ == "__main__":
    sys.argv.append('brasil')
    main()