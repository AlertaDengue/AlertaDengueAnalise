#!/usr/bin/env python
#coding:utf8
"""
Este script captura series de clima de estações do Rio de Janeiro
a partir do Weather underground

Copyright 2014 by Flávio Codeço Coelho
license: GPL v3
"""
import requests
import re
import pandas as pd
from cStringIO import StringIO
import argparse
import datetime
from dateutil.parser import parse
import time
import numpy as np
from pymongo import MongoClient, ASCENDING
from pymongo.errors import DuplicateKeyError

codes = ['SBRJ', # santos dumont
         'SBJR', # Jacarepagua
         'SBGL', # Galeão
         'IRIODEJA30', # Cachambi, Meier
         'IRIODEJA14', # Pepino
         'SBAF', # Campo dos Afonsos
         'IRIODEJA5', # Recreio 
         ] 
 


def parse_page(url):
    """
    Parses the resulting CSV and 
    """
    page = requests.get(url)
    csv = re.subn("<br />", "", page.content)[0]
    csvf = StringIO(csv)
    #print csvf.readline()
    df = pd.read_csv(csvf, sep=',', header=0, skiprows=1, parse_dates=True)
    summary = df.describe()
    return df, summary
    

def captura(start, end, code):
    """
    Fetches each day.
    """
    mongo = MongoClient()
    db = mongo.clima
    coll = db[code]
    coll.create_index([("DateUTC", ASCENDING),], unique=True, dropDups=True)
    
    
    while start != end:
        data = {}
        start = datetime.datetime.fromordinal(start.toordinal())
        if coll.find({"DateUTC":start}).count() > 0:
            start = start + datetime.timedelta(1)
            continue
        y,m,d = start.year, start.month, start.day
        # Open wunderground.com url
        url = "http://www.wunderground.com/history/airport/{}/{}/{}/{}/DailyHistory.html??format=1&format=1".format(code,y,m,d)
        df, summ = parse_page(url)
        try:
            dateutc = parse(df.DateUTC[0]).date()
            dateutc = datetime.datetime.fromordinal(dateutc.toordinal())
        except AttributeError:
            start = start + datetime.timedelta(1)
            continue
        print "Fetching climate for {} on {}".format(code, start)
        try:
            data["DateUTC"] = dateutc
        except AttributeError:
            data["DateUTC"] = np.nan
        try:
            data["Tmin"] = summ.TemperatureC.ix['min']
        except AttributeError:
            data["Tmin"] = np.nan
        try:
            data["Tmed"] = summ.TemperatureC.ix['mean']
        except AttributeError:
            data["Tmed"] = np.nan
        try:
            data["Tmax"] = summ.TemperatureC.ix['max']
        except AttributeError:
            data["Tmax"] = np.nan
        try:
            data["Umid_min"] = summ.Humidity.ix['min']
        except AttributeError:
            data["Umid_min"] = np.nan
        try:
            data["Umid_med"] = summ.Humidity.ix['mean']
        except AttributeError:
            data["Umid_med"] = np.nan
        try:
            data["Umid_max"] = summ.Humidity.ix['max']
        except AttributeError:
            data["Umid_max"] = np.nan
        try:
            data["Pressao_min"] = summ['Sea Level PressurehPa'].ix['min']
        except KeyError:
            data["Pressao_min"] = np.nan
        try:
            data["Pressao_med"] = summ['Sea Level PressurehPa'].ix['mean']
        except KeyError:
            data["Pressao_med"] = np.nan
        try:
            data["Pressao_max"] = summ['Sea Level PressurehPa'].ix['max']
        except KeyError:
            data["Pressao_max"] = np.nan
        try:
            db[code].insert(data, w=1)
        except DuplicateKeyError as e:
            print e
            print "{} already in the database.".format(start)
        time.sleep(1)
        start = start + datetime.timedelta(1)


if __name__=="__main__":
    parser = argparse.ArgumentParser(description="Pega séries de Clima do servidor da Weather Underground em um período determinado")
    parser.add_argument("--inicio", "-i", help="Data inicial de captura: yyyy-mm-dd")
    parser.add_argument("--fim", "-f", help="Data final de captura: yyyy-mm-dd")
    parser.add_argument("--codigo", "-c", choices=codes, help="Codigo da estação" )
    args = parser.parse_args()
    ini = datetime.datetime.strptime(args.inicio, "%Y-%m-%d")
    fim = datetime.datetime.strptime(args.fim, "%Y-%m-%d")

    captura(ini, fim, args.codigo)
    
