import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt
from scipy.stats.distributions import  t
import scipy.stats
import datetime
from datetime import date

xx_ = 0
yy_ = 0
time = []

def model_ml(x, k, a):
    return k * np.exp(- np.log(k / yy_[0]) * np.exp(- a * (x - xx_[0])))

def mat_numpy_logical(t, j):
    aux = []
    for i in range(len(t)):
        if t[i]:
            aux.append(j[i])
    np.asarray(aux)
    return aux
def predband(x, xd, yd, p, func, conf=0.95):
    '''
        Function by: https://apmonitor.com/che263/index.php/Main/PythonRegressionStatistics
    '''
    # x = requested points
    # xd = x data
    # yd = y data
    # p = parameters
    # func = function name
    #p[0] = round(p[0], 0)
    #p[1] = round(p[1], 4)
    alpha = 1.0 - conf    # significance
    N = xd.size        # data sample size
    var_n = len(p)  # number of parameters
    # Quantile of Student's t distribution for p=(1-alpha/2)
    q = scipy.stats.t.ppf(1.0 - alpha / 2.0, N - var_n)
    # Stdev of an individual measurement
    se = np.sqrt(1. / (N - var_n) * \
                 np.sum((yd - func(xd, *p)) ** 2))
    # Auxiliary definitions
    sx = (x - xd.mean()) ** 2
    sxd = np.sum((xd - xd.mean()) ** 2)
    # Predicted values (best-fit model)
    yp = func(x, *p)
    for i in range(len(yp)): yp[i] = round(yp[i], 1)
    # Prediction band
    dy = q * se * np.sqrt(1.0+ (1.0/N) + (sx/sxd))
    # Upper & lower prediction bands.
    lpb, upb = yp - dy, yp + dy
    return yp, lpb, upb


def generate_data(A, data, deaths, name, pop, guardar, yF):

    x = np.arange(start=0, stop=len(data), step=1)
    y = data
    z = deaths
   

    if sum(y > 100) > 3 and max(y) > 200:
        temp_x_y = np.logical_or(y > 100, None)
        xx = mat_numpy_logical(temp_x_y, x)
        yy = mat_numpy_logical(temp_x_y, y)
        temp_t0 = np.where(y > 50)
        T0 = np.asarray(temp_t0)
        T0 = (T0.item(0) + 1) - 10

        if len(xx) > 15:
            xx = xx[len(xx) - 15:len(xx)]
            yy = yy[len(yy) - 15:len(yy)]
        
       
        global xx_, yy_, time
        xx_, yy_ = xx, yy
     
        for i in range(len(xx)): time.append(i)

        x0 = np.array([max(yy[(len(yy) - 1)], 1000), 0.2])

        try:
            popt, pcov = curve_fit(model_ml, x, yy, x0, method='lm')
        except:
            popt, pcov = curve_fit(model_ml, xx, yy, x0, method='trf')
    
        alpha = 0.05
        n = len(yy)
        p = len(popt)

        dof = max(0, n - p)

        tval = t.ppf(1.0-alpha/2., dof)

        for i, p,var in zip(range(n), popt, np.diag(pcov)):
            sigma = var**0.5
            print('p{0}: {1} [{2}  {3}]' .format(i, p,
                                        p - sigma*tval,
                                        p + sigma*tval))
        xp = [len(x)]

        if len(xx) > 6:
            xp.append((len(x) - 1) + 2)
            if len(xx) > 9:
                xp.append((len(x) - 1)  + 3)
                if len(xx) > 12:
                    xp.append((len(x) - 1)  + 4)
                    if len(xx) > 15:
                        xp.append((len(x) - 1) + 5)
        Npred = len(xp)
        dateNum = []
        dateNumPred = []

        for i in range(len(A)): 
            convertData = date.fromordinal(A[i])
            dateNum.append(convertData.strftime("%d-%m-%Y"))
        
        convertDataLast = date.fromordinal(A[len(A) - 1])

        for k in range(Npred): 
            convertDataLast += datetime.timedelta(days=1)
            dateNumPred.append(convertDataLast.strftime("%d-%m-%Y"))


                
        xx_nd = np.asarray(xx)
        yy_nd = np.asarray(yy)
        yp, lep, uep = predband(xp, xx_nd, yy_nd, popt, model_ml, conf=.998018)
        #print('yp_pre = ', yp)
        print('ep_low = ',lep, '\nep_upp = ',uep)
        for i in range(len(yp)): 
                yp[i] = max(yp[i], y[len(y) - 1])
        np_ = [yp[0] - yy[len(yy) - 1]]
        en = [uep[0] - yp[0]]  
        for i in range(len(lep)): 
            lep[i] = round(lep[i], 1)
            uep[i] = round(uep[i], 1)
        print('ep_low = ',lep, '\nep_upp = ',uep)
        for ii in range(1, len(xp)):
            np_.append(yp[ii] - yp[ii - 1])
            en = np.append(en, np.sqrt((uep[ii] - yp[ii])**2+(uep[ii - 1]-yp[ii - 1])**2))
        print('np = ', np_)
        print('en = ', en)

        fig, ax1 = plt.subplots()
        
        xfit = np.arange(0.0, len(x) + len(xp), 0.01)
        yfit = model_ml(xfit, popt[0], popt[1])
        ax1.plot(xfit,yfit, 'r--')#, label='fit params: k=%d, a=%2f' % tuple(popt))
        ax1.plot(dateNum,y,'b. ', label = 'Number of cases')
        ax1.set_xticks(np.arange(0,  len(dateNum) - 1, 8))
        ax1.errorbar(xp, yp, 
                    fmt='r.',
                    yerr=en,
                    elinewidth=0.5,
                    capsize=5, 
                    capthick=0.5,
                    ecolor='xkcd:red', 
                    label = 'Predictions')
        ax1.set_ylabel('Cumulative confirmed cases')
        ax1.set_xlabel('Time (day)')
        ax1.legend()

        ax2 = ax1.twinx()
        ax2.set_ylabel('Cumulative cases per 10^5')
        ax1_y_lim = ax1.get_ylim()
        limlim = ax1_y_lim[1]/pop*1e5
        ax2.set_ylim(0, limlim)

        ax3 = ax1.twinx()
        ax3.axis('off')
        table_data=[]

        ep = np.stack((lep, uep))
        ep = np.transpose(ep)
        ep = np.around(ep)
        ep = ep.astype(int)
        for i in range(len(xp)):
            if i == 0:
                diference =  yp[i] - yy[(len(yy) - 1)]
                diference = round(diference)
                table_data.append([dateNumPred[i], "{} +({})".format(int(yp[i]), int(diference)), ep[i]])
            else:
                diference = yp[i] - yp[i - 1] 
                diference = round(diference)
                table_data.append([dateNumPred[i], "{} +({})".format(int(yp[i]), int(diference)), ep[i]])
        table = ax3.table(cellText=table_data, 
                          loc='center left', 
                          zorder=3, 
                          cellLoc = 'center',
                          bbox = [0.015, 0.5, 0.56, 0.3],
                          colWidths = [0.2, 0.2, 0.3], 
                          colLabels = ['Day', 'Prediction', 'Interval'])
        fig.tight_layout()
        plt.show()