#!/usr/bin/env python3
#coding:utf8
"""
Este script baixa os dados de tweets de dengue da API da UFMG para qualquer número de cidades
identificadas pelo geocódigo do IBGE
"""
import requests
import datetime
import argparse

base_url = "http://observatorio.inweb.org.br/dengueapp/api/1.0/totais"
token = "XXXXX"



def faz_request(inicio, fim, cidades=['330455', '310620', '410690']):
    """
    Faz a consulta
    """
    params = "cidade=" + "&cidade=".join(cidades) + "&inicio="+str(inicio) + "&fim=" + str(fim) + "&token=" + token
    resp = requests.get('?'.join([base_url, params]))
    return resp

def salva(fname, data):
    """
    salva para o arquivo indicado
    """
    with open(fname,'w') as f:
        f.write(data)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Pega séries de Tweets do servidor da UFMG em um periodo determinado")
    parser.add_argument("--inicio", "-i", help="Data inicial de captura: yyyy-mm-dd")
    parser.add_argument("--fim", "-f", help="Data final de captura: yyyy-mm-dd")
    args = parser.parse_args()
    ini = datetime.datetime.strptime(args.inicio, "%Y-%m-%d").date()
    fim = datetime.datetime.strptime(args.fim, "%Y-%m-%d").date()

    response = faz_request(inicio=ini, fim=fim)
    print ("==> Solicitando: ", response.url)
    # print(response.text)
    salva("tweets_teste.csv",response.text)

