#!/usr/bin/env python
#coding:utf8
'''
Prints smoothed values of an array, using moving averages with user-defined
window and populating the extremes with smaller windows.
Returns a list with size len(data)-2 if window is odd (provided (len(data),win)>=3),
or with size len(data)-1 if window is even (provided len(data)>1).

Copyright 2015 by Marcelo F C Gomes
license: GPL v3
'''

import csv
import warnings
import argparse
import numpy as np
from numpy import convolve
from scipy.interpolate import PchipInterpolator

def movave(val,win):
    '''
    Generate moving average of array val, with window win.
    Discard first and last entries that do not fit in window.
    '''
    w = np.repeat(1.0, win)/win
    ma = np.convolve(val, w, "valid")
    return ma

def smooth(data, window):
    '''
    Smooth data entries, using moving average with given window.
    Particularities:
    - Returns a list with size len(data)-2 if window is odd, or
    with size len(data)-1 if window is even.
    - Populates the extremes with smaller sized windows, respecting
    original choice of odd or even window.
    - If window is odd, first(last) entry is obtained from the average
    over first(last) entry and it's smoothed neighbor.
    If 
    '''
    if window == 1 or len(data) == 1:
        outdata = data
    elif len(data) == 2:
        outdata = [.5*(data[0]+data[1])]
    else:
        threshold = min(window,len(data))
        maflag = False
        ma = []
        if window == threshold:
            ma = [v for v in movave(data, window)]
            maflag = True
        else:
            # If window > len(data), it is not possible to use it.
            warnings.warn('Window for smooth function is smaller than data.\n'+
                          'window=%s, data length=%s'%(window,threshold))

        rightdata = []
        outdata = []

        if window%2 != 0:  # Odd window
            leftdata = []

            # Use smaller odd windows to populate up to first entry
            # feasible with original window
            if window == 3 and ma:
                leftdata.append(ma[0])
                rightdata.append(ma[-1])
            else:
                win = 3
                while win < threshold:
                    
                    # Calculate left entry:
                    xaux = data[:win]
                    ma_aux = movave(xaux, win)
                    leftdata.append(ma_aux[0])
                    
                    # Calculate right entry:
                    xaux = data[-win:]
                    ma_aux = movave(xaux, win)
                    rightdata.append(ma_aux[0])
                    
                    # Update window:
                    win += 2
                    
                    # Invert entries in rightdata:
                    rightdata.reverse()
            
            # Populate complete entry:
            if window > 3 and threshold > 2:
                outdata.extend(leftdata)

            if maflag: outdata.extend(ma)

            if window > 3 and threshold > 2:
                outdata.extend(rightdata)

        else:  # Even window

            # Use smaller odd windows to populate up to first entry
            # feasible with original window
            win = 2
            while win < threshold:

                # Calculate left entry:
                xaux = data[:win]
                ma_aux = movave(xaux, win)
                outdata.append(ma_aux[0])

                # Calculate right entry:
                xaux = data[-win:]
                ma_aux = movave(xaux, win)
                rightdata.append(ma_aux[0])
                
                # Update window:
                win += 2
                
            # Invert entries in rightdata:
            rightdata.reverse()

            # Populate complete entry:
            if maflag: outdata.extend(ma)
            outdata.extend(rightdata)
    
    return outdata

def main(fname, win, col, sep, dec):
    '''
    Prints smoothed values of a given column col from file fname,
    assuming sep as field separator and dec as decimal separator
    '''
    
    fin = csv.reader(open(fname,'r'), delimiter=sep)
    data = []

    if dec == ".":
        for row in fin:
            data.append(float(row[col-1]))
    else:
        for row in fin:
            data.append(float(row[col-1].replace(',','.')))

    smoothdata = smooth(data, win)
    
    for i in range(len(smoothdata)):
        print i,smoothdata[i]
        
if __name__=="__main__":
    parser = argparse.ArgumentParser(description="Suaviza um conjunto de dados fornecido, utilizando média móvel e povoando os extremos de maneira conveniente.")
    parser.add_argument("fname", help="Caminho para o arquivo com os dados")
    parser.add_argument("--window", "-w", default=3,
                        help="Tamanho da janela para média móvel")
    parser.add_argument("--column", "-c", default=1,
                        help="Coluna com os dados relevantes")
    parser.add_argument("--separator", "-s", default=",",
                        help="Separador utilizado no arquivo de dados")
    parser.add_argument("--decimal", "-d", default=".",
                        help="Separador decimal")
    args = parser.parse_args()
    main(args.fname, int(args.window), int(args.column), args.separator, args.decimal)
