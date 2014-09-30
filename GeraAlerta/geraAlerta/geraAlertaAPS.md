Alerta de Dengue a nivel de APS - Rio de Janeiro
======================
versao 0.1






**Hoje e' dia 2014-07-02 , SE 201427**




**Curvas epidemicas da dengue por APS**


![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.png) 

**Casos de dengue**



Os ultimos casos de dengue se referem a'semana 201425:


```
##   AP1 AP2.1 AP2.2 AP3.1 AP3.2 AP3.3   AP4 AP5.1 AP5.2 AP5.3 
##     0     3     0     0     0     0     0     1     0     0
```







**Tweet e Rt(tweet) na cidade**



Os ultimos disponiveis de tweet sao da semana 201425:


```
##          SE tweets
## 2655 201420    105
## 2656 201421     41
## 2657 201422     80
## 2658 201423     54
## 2659 201424     49
## 2660 201425     55
```

![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 




**Temperatura**






Os ultimos disponiveis de temperatura minima sao da semana 201425. 


```
##   AP1 AP2.1 AP2.2 AP3.1 AP3.2 AP3.3   AP4 AP5.1 AP5.2 AP5.3 
##    19    19    19    19    19    19    19    19    19    19
```

      

Modelo de alerta com 3 indicadores
========

- Rt > 1 
- Casos > Media + 1.96dp
- Temperatura mi'nima semanal > 24 graus 

**1. Estimando Rt (dengue) a partir dos dados de tweet e clima**

- preto = serie observada de Rt(dengue)
- vermelha = serie predita pelo modelo Rt(dengue) = Rt(tweet)*temp.min




![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-16.png) 










**Serie de casos estimados**

(últimas 70 semanas)

- preto = serie observada de casos de dengue
- vermelha = serie reconstruida de casos de dengue a partir do modelo casos(SE+1)=casos(SE)*Rt_est(dengue)


![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20.png) 





**Alerta por APS**





```
## [1] "AP1"
##          SE APS alertaTemp alertaRt1 alertaCasos
## 2861 201420 AP1          0         0           0
## 2871 201421 AP1          0         0           0
## 2881 201422 AP1          0         0           0
## 2891 201423 AP1          0         0           0
## 2901 201424 AP1          0         0           0
## 2911 201425 AP1          0         0           0
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-231.png) 

```
## [1] "AP2.1"
##          SE   APS alertaTemp alertaRt1 alertaCasos
## 2862 201420 AP2.1          0         0           0
## 2872 201421 AP2.1          0         0           0
## 2882 201422 AP2.1          0         0           0
## 2892 201423 AP2.1          0         1           0
## 2902 201424 AP2.1          0         0           0
## 2912 201425 AP2.1          0         0           0
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-232.png) 

```
## [1] "AP2.2"
##          SE   APS alertaTemp alertaRt1 alertaCasos
## 2863 201420 AP2.2          0         0           0
## 2873 201421 AP2.2          0         0           0
## 2883 201422 AP2.2          0         0           0
## 2893 201423 AP2.2          0         1           0
## 2903 201424 AP2.2          0         0           0
## 2913 201425 AP2.2          0         0           0
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-233.png) 

```
## [1] "AP3.1"
##          SE   APS alertaTemp alertaRt1 alertaCasos
## 2864 201420 AP3.1          0         0           0
## 2874 201421 AP3.1          0         0           0
## 2884 201422 AP3.1          0         0           0
## 2894 201423 AP3.1          0         0           0
## 2904 201424 AP3.1          0         0           0
## 2914 201425 AP3.1          0         0           0
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-234.png) 

```
## [1] "AP3.2"
##          SE   APS alertaTemp alertaRt1 alertaCasos
## 2865 201420 AP3.2          0         0           0
## 2875 201421 AP3.2          0         0           0
## 2885 201422 AP3.2          0         0           0
## 2895 201423 AP3.2          0         0           0
## 2905 201424 AP3.2          0         0           0
## 2915 201425 AP3.2          0         0           0
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-235.png) 

```
## [1] "AP3.3"
##          SE   APS alertaTemp alertaRt1 alertaCasos
## 2866 201420 AP3.3          0         0           0
## 2876 201421 AP3.3          0         0           0
## 2886 201422 AP3.3          0         0           0
## 2896 201423 AP3.3          0         0           0
## 2906 201424 AP3.3          0         0           0
## 2916 201425 AP3.3          0         0           0
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-236.png) 

```
## [1] "AP4"
##          SE APS alertaTemp alertaRt1 alertaCasos
## 2867 201420 AP4          0         0           0
## 2877 201421 AP4          0         0           0
## 2887 201422 AP4          0         0           0
## 2897 201423 AP4          0         0           0
## 2907 201424 AP4          0         0           0
## 2917 201425 AP4          0         0           0
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-237.png) 

```
## [1] "AP5.1"
##          SE   APS alertaTemp alertaRt1 alertaCasos
## 2868 201420 AP5.1          0         0           0
## 2878 201421 AP5.1          0         0           0
## 2888 201422 AP5.1          0         0           0
## 2898 201423 AP5.1          0         0           0
## 2908 201424 AP5.1          0         0           0
## 2918 201425 AP5.1          0         0           0
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-238.png) 

```
## [1] "AP5.2"
##          SE   APS alertaTemp alertaRt1 alertaCasos
## 2869 201420 AP5.2          0         0           0
## 2879 201421 AP5.2          0         0           0
## 2889 201422 AP5.2          0         0           0
## 2899 201423 AP5.2          0         0           0
## 2909 201424 AP5.2          0         0           0
## 2919 201425 AP5.2          0         0           0
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-239.png) 

```
## [1] "AP5.3"
##          SE   APS alertaTemp alertaRt1 alertaCasos
## 2870 201420 AP5.3          0         0           0
## 2880 201421 AP5.3          0         0           0
## 2890 201422 AP5.3          0         0           0
## 2900 201423 AP5.3          0         0           0
## 2910 201424 AP5.3          0         0           0
## 2920 201425 AP5.3          0         0           0
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-2310.png) 
**Salvar**






- **Data do alerta: 201425**
- Arquivo de saida: ../alerta/alertaAPS_201425.csv  


