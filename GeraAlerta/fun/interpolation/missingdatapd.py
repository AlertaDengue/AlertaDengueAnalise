#!/usr/bin/env python3
#coding:utf8
'''
Interpolate and extrapolate data with missing values.
Uses function smoothdata to smooth contigous intervals from input data.
Fill missing values using scipy.interpolate.Akima1DInterpolator

Can be used with input file or calling the function fill_missingdata(df, window)
from another script.

usage: missingdatapd.py [-h] [--window WINDOW] [--xcolumn XCOLUMN]
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


Standalone function fill_missingdata(df, window) receives DataFrame and moving averages window.
Returns filled DataFrame and smoothed version used for interpolation.
    Input:
    :df: pandas DataFrame with 2 columns. Assumes first column is the independent variable.
    :win: window used for data smoothing. 
          Check smoothdata function for documentation.
    
    Output:
    :df_filled: DataFrame with originally empty values substituted
                by estimated values. Preserves column labels and indexes.
    :df_smoothed: DataFrame used to generate interpolator.

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
    Assumes indexes are int.
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
    - If x-column (1st column) dtype==datetime, changes to float64
    using np.timedelta64

    Input:
    :df: pandas DataFrame with 2 columns. Assumes first column is the independent variable.
    :win: window for moving average.

    Output:
    :dfwork: DataFrame with smoothed entries in both columns.
    '''

    emptyvals = ['NA','na',
                 'Null','null',
                 'none','None',None]

    xlbl, ylbl = df.columns
    dfwork = df.replace(to_replace={ylbl:emptyvals}, value=np.nan)

    # Check if xcol is datetime and convert to float:
    if dfwork[xlbl].dtype == 'datetime64[ns]':
        dfwork['date_delta'] = (dfwork[xlbl] - dfwork[xlbl].min())/np.timedelta64(1, 'D')
        dfwork = dfwork[['date_delta',ylbl]]
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

    # Remove possible duplicates from shifts:
    dfwork_win.drop_duplicates(inplace=True)


    # Clean up
    del dfwork

    return dfwork_win.ix[:,[xlbl,ylbl]]


def fill_missingdata(df, win):
    '''
    Fill missing data in df whenever df[df.index[1]].isnull() == True
    Uses smoothdata function

    Input:
    :df: pandas DataFrame with 2 columns. Assumes first column is the independent variable.
    :win: window used for data smoothing. 
          Check smoothdata function for documentation.
    
    Output:
    :df_filled: DataFrame with originally empty values substituted
            by estimated values.
    :df_smoothed: DataFrame used for (extra)interpolation
    '''

    emptyvals = ['NA','na',
                 'Null','null',
                 'none','None',None]
    xlbl, ylbl = df.columns
    dfwork = df.replace(to_replace={ylbl:emptyvals}, value=np.nan)

    # Check if xcol is datetime and convert to float:
    dateflag = False
    if dfwork[xlbl].dtype == 'datetime64[ns]':
        dateflag = True
        dfwork['date_delta'] = (dfwork[xlbl] - dfwork[xlbl].min())/np.timedelta64(1, 'D')
        dfwork = dfwork[['date_delta',ylbl]]
        dfwork.rename(columns={'date_delta':xlbl},inplace=True)

    df_smoothed = smoothdata(dfwork, win)

    # Extract x and y for interpolator:
    x = []
    y = []
    for row_index, row_data in df_smoothed.iterrows():
         xi, yi = row_data.tolist()
         if np.isfinite(yi):
             x.append(xi)
             y.append(yi)

    missing = {'index':[], xlbl:[]}
    for row_index, row_data in dfwork.iterrows():
         xi, yi = row_data.tolist()
         if np.isnan(yi):
             missing['index'].append(row_index)
             missing[xlbl].append(xi)

    f = Akima1DInterpolator(np.array(x), np.array(y))
    dfwork.ix[missing['index'], ylbl] = f(missing[xlbl], extrapolate=True)

    # Restore original xcolumn, if needed:
    if dateflag:
        dfwork.ix[:,xlbl] = df.ix[:,xlbl]

    # Clean up:
    del x, y, missing

    return dfwork, df_smoothed


def interpolatenans(df):
    '''
    Uses Akima interpolator to fill nan entries
    Same idea as of fill_missingdata, only without
    smoothing the data first

    Input:
    :df: pandas DataFrame with 2 columns. Assumes first column is the independent variable.
    
    Output:
    :df_filled: DataFrame with originally empty values substituted
            by estimated values.
    '''
    
    xlbl, ylbl = df.columns
    dfwork = df.copy()

    # Check if xcol is datetime and convert to float:
    if dfwork[xlbl].dtype == 'datetime64[ns]':
        dfwork['date_delta'] = (dfwork[xlbl] - dfwork[xlbl].min())/np.timedelta64(1, 'D')
        dfwork = dfwork[['date_delta',ylbl]]
        dfwork.rename(columns={'date_delta':xlbl},inplace=True)

    # Extract x and y for interpolator:
    x = []
    y = []
    missing = {'index':[], xlbl:[]}
    for row_index, row_data in dfwork.iterrows():
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

    return dfwork

    
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

    smoothed_df = smooth(df, win)
    filled_df = fill_missingdata(smoothed_df, win)

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
