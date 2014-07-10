#!/usr/bin/env python3
#coding:utf8
"""
Este script baixa os dados de tweets de dengue da API da UFMG para qualquer número de cidades
identificadas pelo geocódigo do IBGE
"""
import requests
import datetime

base_url = "http://observatorio.inweb.org.br/dengueapp/api/1.0/totais"
token = "XXXXX"



def faz_request(inicio, fim, cidades=['330455', '310620', '410690']):
    """
    Faz a consulta
    """
    params = "cidade=" + "&cidade=".join(cidades) + "&inicio="+inicio + "&fim=" + fim + "&token=" + token
    resp = requests.get('?'.join([base_url, params]))
    return resp

def salva(fname, data):
    """
    salva para o arquivo indicado
    """
    with open(fname,'w') as f:
        f.write(data)

if __name__ == "__main__":
    hoje = datetime.datetime.today()  # Dia de Hoje
    menos7 = hoje - datetime.timedelta(7)  # 7 dias atrás
    ini = menos7.strftime('%Y-%m-%d') 
    fim = hoje.strftime('%Y-%m-%d')
    response = faz_request(inicio=ini, fim=fim)
    print (response.url)
    # print(response.text)
    salva("tweets_teste.csv",response.text)

