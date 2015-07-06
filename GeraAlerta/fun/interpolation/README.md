# Version update
- Migrate functions to pandas
- All necessary functions inside single code missingdatapd.py

# Missing values estimation
The scripts in this folder provide functions to perform estimation for missing data.
The process is divided in two main steps:
- Smooth out raw data

This is done in order to minimize the effect of fluctuations, generating the main trend from provided data.
- (Extra)Interpolation

Using the smoothed out information, generates an Akima (extra)interpolator to estimate missing values.

## Smooth function
Main code:
```
missingdatapd.py
```
Function:
```python
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
```
Example input data:
smoothdata_sampledata.csv

Necessary python libraries:
argparse, numpy, scipy(>=0.14), pandas

Returns smoothed values of DataFrame columns, using moving averages with user-defined window and populating the extremes with smaller windows.

For example, if window=5, the second entry and the second last entry will be smoothed out using window=3. This process is done preserving user-defined parity. That is, if window=4, then the extremes will be dealt with window=2.
End-points are always smoothed-out using window=2. If input has NaN, those are preserved and treated as intermediate end-points.

Returns a DataFrame with size len(df)-1 if window is even (provided len(data)>1).


Copyright 2015 by Marcelo F C Gomes
license: GPL v3

## Interpolator
Main code:
```
missingdatapd.py
```

Main function:
```python
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
```
Necessary python libraries:
argparse, numpy, scipy(>=0.14), pandas

Interpolate and extrapolate data with missing values, using Akima interpolator.
Uses function smoothdata.py to smooth contigous intervals from input data.
Fill missing values using scipy.interpolate.Akima1DInterpolator function.

Can be used with input file or calling the function fill_missingdata(df, window)
from another script.

Function fill_missingdata will return DataFrame with original column headers and values, only substituting NaNs
for (extra)interpolated values.

```
usage: missingdatapd.py [-h] [--window WINDOW] [--xcolumn XCOLUMN]
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
                        Column with independent variable values (X).
                        Default=1
  --ycolumn YCOLUMN, -yc YCOLUMN
                        Column with dependent variable values (Y).
                        Default=2
  --separator SEPARATOR, -s SEPARATOR
                        Field separator.
                        Default=","
  --decimal DECIMAL, -d DECIMAL
                        Decimal separator.
                        Default="."
```

Example 1:
```
python missingdatapd.py missingdata_sampledata.csv -w 3 -xc 1 -yc 2 -s , -d .
```

Example 2:
```
python missingdatapd.py missingdata_sampledata3.csv -w 3 -xc 1 -yc 2 -s , -d .
```
Compare output with file smoothdata_sampledata.csv from smoothdata.py package

Copyright 2015 by Marcelo F C Gomes
license: GPL v3
