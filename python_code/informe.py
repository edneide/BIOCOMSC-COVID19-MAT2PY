import numpy as np
from scipy.optimize import curve_fit
import pylab as plt

xx_ = 0
yy_ = 0


def model_ml(x, k, a):
    return k * np.exp(- np.log(k // yy_[1]) * np.exp(- a * (x - xx_[1])))


def mat_numpy_logical(t, j):
    aux = []
    for i in range(len(t)):
        if t[i]:
            aux.append(j[i])
    np.asarray(aux)
    return aux


def generate_data(A, data, deaths, name, pop, guardar, yF):
    x = np.arange(start=1, stop=len(data) + 1, step=1)
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

        global xx_, yy_
        xx_, yy_ = xx, yy

        x0 = np.array([max(y[(len(y) - 1)], 1000), 0.2])

        try:

            popt, pcov = curve_fit(model_ml, x, y, x0, method='lm')

        except:

            popt, pcov = curve_fit(model_ml, x, y, x0, method='trf')

        '''

        plt.plot(x, y, 'bo', label='experimental-data')
        xFit = np.arange(0.0, len(x), 0.01)
        plt.plot(xFit, model_ml(xFit, *popt), 'r', label='fit params: k=%5.3f, a=%5.3f' % tuple(popt))
        print(popt)
        plt.xlabel('Days')
        plt.ylabel('Cases')
        plt.legend()
        plt.show()
        '''
        xp = [len(x) + 1]

        if len(xx) > 6:
            xp.append(len(x) + 2)
            if len(xx) > 9:
                xp.append(len(x) + 3)
                if len(xx) > 12:
                    xp.append(len(x) + 4)
                    if len(xx) > 15:
                        xp.append(len(x) + 5)
        Npred = len(xp)
        yp = model_ml(xp, *popt)
        yp = max(yp)
        #npnp = yp[1] - y[len(y)]
        print(*popt)
        print(*yp)
