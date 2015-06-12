#!/usr/bin/env python
#coding:utf8
'''
Interpolate and extrapolate data with missing values.
Uses function smoothdata.py to smooth contigous intervals from input data.
Fill missing values using scipy.interpolate.PchipInterpolator

#### WARNING ####
Work in progress!
Still has pending issues
#################

Copyright 2015 by Marcelo F C Gomes
license: GPL v3
'''

import numpy as np
from scipy.interpolate import PchipInterpolator
from smoothdata import smooth

def fill_missingdata(xy,window):
    '''
    Fill missing data in y whenever xy[i][1] = NA or None
    Uses smooth function from smoothdata.py
    Input:
    xy: list of 2d tuples
    window: window used for data smoothing. 
            Check smoothdata.py for documentation.
    
    Output:
    list of tuples with same lenght as xy, with empty y values substituted
    by (extra)interpolated values.
    '''
    emptyvals = ['NA','na',
                 'Null','null',
                 'none','None',None]
    yaux = []
    for i in len(range(xy)):
        if xy[i][1] not in emptyvals:
            yaux.append(xy[i][1])
