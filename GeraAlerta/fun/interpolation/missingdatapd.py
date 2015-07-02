#!/usr/bin/env python3
#coding:utf8
'''
########## WARNING!!! ##########
WORK IN PROGRESS
CODE NOT READY TO USE
################################

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
python missingdata.py sampledata/missingdata_sampledata.csv -w 3 -xc 1 -yc 2 -s , -d .

Example 2:
python missingdata.py sampledata/missingdata_sampledata2.csv -w 3 -xc 1 -yc 2 -s , -d .
Compare output with file sampledata/smoothdata_sampledata.csv from smoothdata.py package


Copyright 2015 by Marcelo F C Gomes
license: GPL v3
'''

import argparse
import csv
import numpy as np
import copy as cp
import pandas as pd
from scipy.interpolate import Akima1DInterpolator
from smoothdata import smooth

def fill_missingdata(df, win):
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
    :xynew: list of tuples with originally empty y values substituted
         by estimated values.
    :xnew: list of smoothed x-values used for (extra)interpolation
    :ynew: list of smoothed y-values used for (extra)interpolation
    '''

    emptyvals = ['NA','na',
                 'Null','null',
                 'none','None',None]

    xlbl, ylbl = df.columns
    dfwork = df.replace(to_replace{ylbl:emptyvals}, value=np.nan)

    # Check if xcol is datetime and convert to float:
    if dfwork[xlbl].dtype == 'datetime64[ns]':
        dfwork['date_delta'] = (dfwork[xlbl] - dfwork[xlbl].min())/np.timedelta64(1, 'D')
        dfwork = dfwork.ix[:, [xlbl, ylbl]]
    
    dfwork_win = rolling_mean(dfwork, window=win, center=True)
    window = win
    if win%2 != 0:
        wold = window
        window -= 2
        while window > 1:
            # Calculate moving average win lower window,
            # based on previously smoothed data and
            # original values on extremes
            dfwork_win_lower = rolling_mean(dfwork_win.combine_first(dfwork),
                                            window=window, center=True)

            # Update smoothed data
            dfwork_win.loc[dfwork_win[ylbl].isnull() == True] = dfwork_win_lower[dfwork_win['tmin'].isnull() == True]

            # Update window size:
            wold = window
            window -= 2
    
        # Finally, populate imediate neighbors of NaNs with
        # mov ave of size 2:
        window = 2
        dfwork_win_right = rolling_mean(dfwork_win.combine_first(dfwork),
                                        window=window, center=True)
        dfwork_win_left = dfwork_win_right.rename(index={v:v-1 for v in
                                                         dfwork_win_right.index})
        dfwork_win.loc[dfwork_win[ylbl].isnull() == True] = dfwork_win_right[dfwork_win['tmin'].isnull() == True]
        dfwork_win.loc[dfwork_win[ylbl].isnull() == True] = dfwork_win_left[dfwork_win['tmin'].isnull() == True]

        # Clean up
        del(dfwork_win_left)
        del(dfwork_win_right)

    # Places where mov ave was not possible are kept as is
    # E.g., single entry between two NaNs
    dfwork_win.loc[dfwork_win[ylbl].isnull() == True] = dfwork[dfwork_win['tmin'].isnull() == True]

    # Clean up
    del(dfwork)

    return dfwork_win

def main(fname, win, xcol, ycol, sep, dec):
    '''
    Prints filled values of a given column col from file fname,
    assuming sep as field separator and dec as decimal separator
    '''
    
    emptyvals = ['NA','na',
                 'Null','null',
                 'none','None',None]

    # Check if columns passed as numerical position or label
    try:
        xcol = int(xcol)-1
    except:
        xcol = xcol
    try:
        ycol = int(ycol)-1
    except:
        ycol = ycol

    df = pd.read_csv(fname, sep=sep, sep=sep, decimal=dec,
                     na_values=emptyvals, keep_defualt_na=True,
                     usecols=[xcol,ycol])

    filled_df = fill_missingdata(df, win)

    
    
    

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
