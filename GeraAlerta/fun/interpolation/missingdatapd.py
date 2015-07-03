#!/usr/bin/env python3
#coding:utf8
'''
Interpolate and extrapolate data with missing values.
Uses function smoothdata to smooth contigous intervals from input data.
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

Example:
python missingdata.py sampledata/missingdata_sampledata3.csv -w 3 -xc 1 -yc 2 -s , -d .
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


def shift_left(dfin):
    '''
    Shift DataFrame indexes to the left and drop first row.
    '''

    last_index = dfin.index[[-1]]
    dfout = dfin.rename(index={v:v-1 for v in
                               dfin.index})

    dfout.drop(dfout.index[[0]], inplace=True)
    dfout = dfout.append(pd.DataFrame({k:np.nan for k in dfout.columns},
                                      index=[last_index])).ix[:, dfout.columns]
    # ix[:, dfout.columns] necessary to avoid flipping columns in output...
    return dfout

def replace_nan(dfa, dfb, col):
    '''
    Replace dfa rows with null values in column col
    using same index rows from dfb.
    Change is made inplace.
    '''

    dfa.loc[dfa[col].isnull() == True] = dfb[dfa[col].isnull() == True]


def smoothdata(df, win):
    '''
    Smooth data entries, using moving average with given window.
    Particularities:
    - Returns a DataFrame with size len(df.index)-1 if window is even, or
    with size len(data)-1 if window is even.
    - Populates the extremes with smaller sized windows, respecting
    original choice of odd or even window, combining original rows
    and previously smoothed ones.
    - If window is odd, first(last) entry is obtained from the average
    over first(last) entry and it's smoothed neighbor.
    '''

    emptyvals = ['NA','na',
                 'Null','null',
                 'none','None',None]

    xlbl, ylbl = df.columns
    dfwork = df.replace(to_replace={ylbl:emptyvals}, value=np.nan)

    # Check if xcol is datetime and convert to float:
    if dfwork[xlbl].dtype == 'datetime64[ns]':
        dfwork['date_delta'] = (dfwork[xlbl] - dfwork[xlbl].min())/np.timedelta64(1, 'D')
        dfwork.drop(xlbl, axis=1, inplace=True)
        dfwork.rename(columns={'date_delta':xlbl},inplace=True)
    

    dfwork_win = pd.rolling_mean(dfwork, window=win, center=True)

    # Calculate moving average with lower window,
    # based on previously smoothed data and
    # original values on extremes
    window = win - 2
    if win%2 != 0:
        # Odd window
        while window > 1:
            dfwork_win_lower = pd.rolling_mean(dfwork_win.combine_first(dfwork),
                                            window=window, center=True)
            
            # Update smoothed data
            replace_nan(dfwork_win, dfwork_win_lower, ylbl)

            # Update window size:
            wold = window
            window -= 2

        # Clean up:
        if win > 3:
            del dfwork_win_lower

    else:
        # Even window
        dfwork_win_left = shift_left(dfwork_win)
        replace_nan(dfwork_win, dfwork_win_left, ylbl)
        
        while window > 2:
            dfwork_win_right = pd.rolling_mean(dfwork_win.combine_fisrt(dfwork),
                                            window=window, center=True)
            dfwork_win_left = shift_left(dfwork_win_right)

            # Update smoothed data
            replace_nan(dfwork_win, dfwork_win_right, ylbl)
            replace_nan(dfwork_win, dfwork_win_left, ylbl)

            # Update window size:
            wold = window
            window -= 2
        
        # Clean up:
        del dfwork_win_left


    # Finally, populate imediate neighbors of NaNs with
    # mov ave of size 2:
    if win > 2:
        window = 2
        dfwork_win_right = pd.rolling_mean(dfwork_win.combine_first(dfwork),
                                        window=window, center=True)
        dfwork_win_left = shift_left(dfwork_win_right)
  
        replace_nan(dfwork_win, dfwork_win_right, ylbl)
        replace_nan(dfwork_win, dfwork_win_left, ylbl)

        # Clean up
        del dfwork_win_left, dfwork_win_right
    
    
    # Finally, single entry between two NaNs
    # are kept as is, since mov ave is not possible
    replace_nan(dfwork_win, dfwork, ylbl)

    # If win is even, remove duplicates from shift:
    if win%2 == 0:
        dfwork_win.drop_duplicates(inplace=True)

    # Clean up
    del dfwork

    return dfwork_win


def fill_missingdata(df, win):
    '''
    Fill missing data in df whenever df[df.index[1]].isnull() == True
    Uses smoothdata function

    Input:
    :df: pandas DataFrmae
    :win: window used for data smoothing. 
          Check smoothdata function for documentation.
    
    Output:
    :df_filled: DataFrame with originally empty values substituted
            by estimated values.
    :df_smoothed: DataFrame used for (extra)interpolation
    '''

    xlbl, ylbl = df.columns
    dfwork = df.copy()
    df_smoothed = smoothdata(dfwork, win)

    # Extract x and y for interpolator:
    x = []
    y = []
    missing = {'index':[], xlbl:[]}
    for row_index, row_data in df_smoothed.iterrows():
         xi, yi = row_data.tolist()
         if np.isnan(yi):
             missing['index'].append(row_index)
             missing[xlbl].append(xi)
         else:
             x.append(xi)
             y.append(yi)

    f = Akima1DInterpolator(np.array(x), np.array(y))
    dfwork.ix[missing['index'], ylbl] = f(missing[xlbl], extrapolate=True)

    # Clean up:
    del x, y, missing

    return dfwork, df_smoothed

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

    df = pd.read_csv(fname, sep=sep, decimal=dec,
                     na_values=emptyvals, keep_default_na=True,
                     usecols=[xcol,ycol])

    filled_df, smoothed_df = fill_missingdata(df, win)

    print('Smoothed data')
    print(smoothed_df)
    print('Filled data')
    print(filled_df)
    
    
    

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
    main(args.fname, int(args.window), args.xcolumn, args.ycolumn,
         args.separator, args.decimal)
