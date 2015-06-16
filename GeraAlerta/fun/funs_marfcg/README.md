# Missing values estimation
The scripts in this folder provide functions to perform estimation for missing data.
The process is divided in two main steps:
- Smooth out raw data

This is done in order to minimize the effect of fluctuations, generating the main trend from provided data.
- (Extra)Interpolation

Using the smoothed out information, generates an Akima (extra)interpolator to estimate missing values.

## Smooth function
Main code:
smoothdata.py

Example input data:
smoothdata_sampledata.csv

Necessary python libraries:
csv, warnings, argparse, numpy

Can be used as stand-alone code or calling smooth(x,window) function.

Prints(returns) smoothed values of an array, using moving averages with user-defined window and populating the extremes with smaller windows.

For example, if window=5, the second entry and the second last entry will be smoothed out using window=3. This process is done preserving user-defined parity. That is, if window=4, then the extremes will be dealt with window=2.

Returns a list with size len(data)-2 if window is odd (provided (len(data),win)>=3),
or with size len(data)-1 if window is even (provided len(data)>1).

'''
usage: smoothdata.py [-h] [--window WINDOW] [--column COLUMN]
                     [--separator SEPARATOR] [--decimal DECIMAL]
                     fname
positional arguments:
  fname                 Path to data file

optional arguments:
  -h, --help            show this help message and exit.
  --window WINDOW, -w WINDOW
                        Moving average window size (in number of points).
  --column COLUMN, -c COLUMN
                        Column with data to be smoothed. Default=1
  --separator SEPARATOR, -s SEPARATOR
                        Field separator. Default=","
  --decimal DECIMAL, -d DECIMAL
                        DEcimal separator. Default="."
'''

Example:
'''
python smoothdata.py smoothdata_sampledata.csv -w 3 -c 2 -s , -d .
'''

Copyright 2015 by Marcelo F C Gomes
license: GPL v3

## Interpolator
Main code:
missingdata.py

Uses:
smoothdata.py

Necessary python libraries:
csv, warnings, argparse, numpy, scipy(>=0.14)

Interpolate and extrapolate data with missing values, using Akima interpolator.
Uses function smoothdata.py to smooth contigous intervals from input data.
Fill missing values using scipy.interpolate.Akima1DInterpolator function.

Can be used with input file or calling the function fill_missingdata(xy, window)
from another script.

'''
usage: missingdata.py [-h] [--window WINDOW] [--xcolumn XCOLUMN]
                       [--ycolumn YCOLUMN] [--separator SEPARATOR]
                       [--decimal DECIMAL]
                       fname

Interpolate and extrapolate data with missing values, using Akima interpolator
and smoothing function to avoid fluctuations.

positional arguments:
  fname                 Path to data file

optional arguments:
  -h, --help            show this help message and exit
  --window WINDOW, -w WINDOW
                        Moving average window size (in number of points).
			Default=3
  --xcolumn XCOLUMN, -xc XCOLUMN
                        Column with independent variable values (X)
			Default=1
  --ycolumn YCOLUMN, -yc YCOLUMN
                        Column with dependent variable values (Y)
			Default=2
  --separator SEPARATOR, -s SEPARATOR
                        Separador utilizado no arquivo de dados
			Default=","
  --decimal DECIMAL, -d DECIMAL
                        Separador decimal
			Deafult="."
'''

Example 1:
'''
python missingdata.py missingdata_sampledata.csv -w 3 -xc 1 -yc 2 -s , -d .
'''

Example 2:
'''
python missingdata.py missingdata_sampledata2.csv -w 3 -xc 1 -yc 2 -s , -d .
'''
Compare output with file smoothdata_sampledata.csv from smoothdata.py package

Copyright 2015 by Marcelo F C Gomes
license: GPL v3
