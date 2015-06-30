#!/usr/bin/env python3
#coding:utf8
'''
Interpolate and extrapolate data with missing values.
Uses function smoothdata.py to smooth contigous intervals from input data.
Fill missing values using scipy.interpolate.Akima1DInterpolator

Can be used with input file or calling the function fill_missingdata(xy, window)
from another script.

usage: missingdata.py [-h] [--window WINDOW] [--xcolumn XCOLUMN]
                       [--ycolumn YCOLUMN] [--separator SEPARATOR]
                       [--decimal DECIMAL]
                       fname

Interpolate and extrapolate data with missing values, using Akima interpolator and smoothing function to avoid fluctuations.

positional arguments:
  fname                 Caminho para o arquivo com os dados

optional arguments:
  -h, --help            show this help message and exit
  --window WINDOW, -w WINDOW
                        Tamanho da janela para média móvel
  --xcolumn XCOLUMN, -xc XCOLUMN
                        Coluna com os dados relevantes para x
  --ycolumn YCOLUMN, -yc YCOLUMN
                        Coluna com os dados relevantes para y
  --separator SEPARATOR, -s SEPARATOR
                        Separador utilizado no arquivo de dados
  --decimal DECIMAL, -d DECIMAL
                        Separador decimal

Example 1:
python missingdata.py missingdata_sampledata.csv -w 3 -xc 1 -yc 2 -s , -d .

Example 2:
python missingdata.py missingdata_sampledata2.csv -w 3 -xc 1 -yc 2 -s , -d .
Compare output with file smoothdata_sampledata.csv from smoothdata.py package

Copyright 2015 by Marcelo F C Gomes
license: GPL v3
'''

import argparse
import csv
import numpy as np
from scipy.interpolate import Akima1DInterpolator
from smoothdata import smooth

def fill_missingdata(xy,window):
    '''
    Fill missing data in y whenever xy[i][1] = NA or None
    Uses smooth function from smoothdata.py
    Assumes evenly-spaced values of first dimension, i.e.,
    xy[i+1][0]-xy[i][0] = constant

    Input:
    :xy: list of 2d tuples
    :window: window used for data smoothing. 
             Check smoothdata.py for documentation.
    
    Output:
    :xy: list of tuples with originally empty y values substituted
         by estimated values.
    :xnew: list of smoothed x-values used for (extra)interpolation
    :ynew: list of smoothed y-values used for (extra)interpolation
    '''
    emptyvals = ['NA','na',
                 'Null','null',
                 'none','None',None]
    yaux = []
    xaux = []
    xnew = []
    ynew = []
    missingvals_index = []
    last_empty = True
    for i in range(len(xy)):
        if xy[i][1] not in emptyvals:
            # Grab range of consecutive points:
            yaux.append(float(xy[i][1]))
            xaux.append(float(xy[i][0]))
            last_empty = False
        else:
            # Empty value found.
            missingvals_index.append(i)
            #print 'xy'
            #print xy[i]
            #print 'xaux,yaux'
            #print xaux,yaux

            # Smooth out previous consecutive range.
            # If previous value was also empty, fall back.
            if last_empty: continue

            last_empty = True
            sz = len(yaux)
            #print sz, len(xaux)
            if sz == 1:
                # If single value, store as is
                xnew.append(xaux[0])
                ynew.append(yaux[0])
            elif sz == 2:
                # If couple of values,
                # take the average on both dimensions
                xi = .5*(xaux[0]+xaux[1])
                yi = .5*(yaux[0]+yaux[1])
                xnew.append(xi)
                ynew.append(yi)
            else:
                yi = yaux[0]
                yf = yaux[-1]
                #print xaux, yaux
                yaux = smooth(yaux,window)
                #print len(yaux), len(xaux)
                #print xaux, yaux
                if window%2 != 0:
                    # Odd window

                    # For odd windows, take the average of
                    # first and last two entries to smooth
                    # out the extremes (xi,yi) & (xf,yf)
                    xi = .5*(xaux[0]+xaux[1])
                    yi = .5*(yi+yaux[0])
                    xf = .5*(xaux[-2]+xaux[-1])
                    yf = .5*(yaux[-1]+yf)

                    xnew.append(xi)
                    ynew.append(yi)
                    for i in range(len(yaux)):
                        xnew.append(xaux[i+1])
                        ynew.append(yaux[i])
                    xnew.append(xf)
                    ynew.append(yf)
                else:
                    # Even window
                    for i in range(len(yaux)):
                        # For even windows, smoothed values
                        # corresponds to central point between
                        # consecutive x values.
                        xi = .5*(xaux[i]+xaux[i+1])
                        xnew.append(xi)
                        ynew.append(yaux[i])

            # Clear auxiliary lists:
            xaux = []
            yaux = []
            
            #print 'xnew,ynew'
            #print xnew, ynew

    if not last_empty:
        sz = len(yaux)
        if sz == 1:
            # If single value, store as is
            xnew.append(xaux[0])
            ynew.append(yaux[0])
        elif sz == 2:
            # If couple of values,
            # take the average on both dimensions
            xi = .5*(xaux[0]+xaux[1])
            yi = .5*(yaux[0]+yaux[1])
            xnew.append(xi)
            ynew.append(yi)
        else:
            yi = yaux[0]
            yf = yaux[-1]
            yaux = smooth(yaux,window)
            if window%2 != 0:
                # Odd window
                
                # For odd windows, take the average of
                # first and last two entries to smooth
                # out the extremes (xi,yi) & (xf,yf)
                xi = .5*(xaux[0]+xaux[1])
                yi = .5*(yi+yaux[0])
                xf = .5*(xaux[-2]+xaux[-1])
                yf = .5*(yaux[-1]+yf)
                
                xnew.append(xi)
                ynew.append(yi)
                for i in range(len(yaux)):
                    xnew.append(xaux[i+1])
                    ynew.append(yaux[i])
                xnew.append(xf)
                ynew.append(yf)
            else:
                # Even window
                for i in range(len(yaux)):
                    # For even windows, smoothed values
                    # corresponds to central point between
                    # consecutive x values.
                    xi = .5*(xaux[i]+xaux[i+1])
                    xnew.append(xi)
                    ynew.append(yaux[i])
        
        # Clear auxiliary lists:
        xaux = []
        yaux = []
        
    # Generate (extra)interpolator from list of smoothed values
    # to estimate empty ones
    #print xnew
    #print ynew
    f = Akima1DInterpolator(np.array(xnew),np.array(ynew))
    for i in missingvals_index:
        x = float(xy[i][0])
        xy[i] = (x,float(f(x,extrapolate=True)))

    return xy, xnew, ynew

def main(fname, win, xcol, ycol, sep, dec):
    '''
    Prints filled values of a given column col from file fname,
    assuming sep as field separator and dec as decimal separator
    '''
    
    emptyvals = ['NA','na',
                 'Null','null',
                 'none','None',None]

    fin = csv.reader(open(fname,'r'), delimiter=sep)
    data = []

    if dec == ".":
        for row in fin:
            x = float(row[xcol-1])
            y = row[ycol-1]
            if y not in emptyvals:
                data.append((x, float(y)))
            else:
                data.append((x, y))
                
    else:
        for row in fin:
            x = float(row[xcol-1].replace(',','.'))
            y = row[ycol-1].replace(',','.')
            if y not in emptyvals:
                data.append((x, float(y)))
            else:
                data.append((x, y))

    filleddata, xsmooth, ysmooth = fill_missingdata(data, win)
    
    print 'Smooth entries'
    for i in range(len(xsmooth)):
        print xsmooth[i], ysmooth[i]

    print 'Filled list'
    for i in range(len(filleddata)):
        print filleddata[i]
        
if __name__=="__main__":
    parser = argparse.ArgumentParser(description="Interpolate and extrapolate data with missing values, using Akima interpolator and smoothing function to avoid fluctuations.")
    parser.add_argument("fname", help="Caminho para o arquivo com os dados")
    parser.add_argument("--window", "-w", default=3,
                        help="Tamanho da janela para média móvel")
    parser.add_argument("--xcolumn", "-xc", default=1,
                        help="Coluna com os dados relevantes para x")
    parser.add_argument("--ycolumn", "-yc", default=2,
                        help="Coluna com os dados relevantes para y")
    parser.add_argument("--separator", "-s", default=",",
                        help="Separador utilizado no arquivo de dados")
    parser.add_argument("--decimal", "-d", default=".",
                        help="Separador decimal")
    args = parser.parse_args()
    main(args.fname, int(args.window), int(args.xcolumn), int(args.ycolumn),
         args.separator, args.decimal)
