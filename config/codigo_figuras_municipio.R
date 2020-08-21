#### codigo das figuras dos boletins municipais ##
### Infodengue 2020  
### autora: claudia codeco 


figuras_municipio <- function(obj, param, nome, tsdur=104){
  
  # obj é cbind(ale[[1]]$data, ale[[1]]$indice) 
  
  cid <- obj$CID10[1]
  if(cid == "A90") titulo <- "Dengue"
  if(cid == "A92.0") titulo <- "Chikungunya"
  if(cid == "A92.8") titulo <- "Zika"
  
  # cidade
  geoc <- obj$cidade[1]
  
  print("Figuras: # fitting tweet lm (so plota se for significativa a associacao)")
  sig.tw <- FALSE
  if(sum(obj$tweet, na.rm = TRUE) != 0){
    mod <- lm(casos ~ tweet, data = obj)
    sig.tw <- ifelse(confint(mod)[2,1] > 0, TRUE, FALSE) # true se  tweet tem relacao com casos 
  } 
  
  totcasos <- sum(obj$casos, na.rm = TRUE)  
  semmax <- obj$sem[nrow(obj)] 
  
  # calculando e plotando receptividade")
  
  p1 <- obj %>%
    group_by(sem) %>%
    summarise(
      n = length(!is.na(nytrue)),
      recept = sum(nytrue==3, na.rm = TRUE)/n*100) %>%
    mutate(
      nrecept = 100 - recept) %>% 
    ggplot(aes(x=sem, y=recept)) + 
    geom_rect(aes(xmin=min(sem), xmax=max(sem), ymin=0, ymax=100), 
              fill="grey", alpha=1/10) +
    geom_bar(stat = "identity", fill = "yellow2", width = 1.2) +
    annotate("segment", x = semmax, xend = semmax, y = 0, yend = 10, colour = "blue", size=1, alpha=0.6, arrow=arrow()) +
    xlab(NULL) + 
    ylab("receptividade histórica") +
    labs(title = "", 
         subtitle = "(A) Perfil de receptividade climática") 
  
   # perfil Rt")
  p2 <- obj %>%
    mutate(se = SE - floor(SE/100)*100) %>%
    group_by(se) %>%
    summarise(
      no = length(!is.na(notrue)),
      p1 = sum(p1 > 0.9, na.rm = TRUE)/no * 100,
      Rtmean = mean(Rt, na.rm = TRUE)
    ) %>% ggplot(aes(x=se, y=Rtmean)) + 
    geom_bar(stat = "identity", fill = "darkorange", width = 1.2) +
    annotate("segment", x = semmax, xend = semmax, y = 0, yend = 0.2, colour = "blue", size=1, alpha=0.6, arrow=arrow()) +
    geom_hline(aes(yintercept = 1), colour = "red") +
    xlab(NULL) + 
    ylab("Rt médio") +
    labs(title = "", 
         subtitle = "(B) Perfil de transmissibilidade")
  
   # perfil casos")
  
  p3 <- obj %>%
    mutate(
      data = ifelse(ano == max(ano), "esse ano", "passado"),
      ano = as.factor(ano)) %>%
    ggplot( aes(x=sem, y=inc, group=ano,colour = data)) +
    geom_line(aes(colour = data)) + 
    scale_color_manual(values=c('red','grey70'))+
    scale_size_manual(values=c(0.8, 1.5)) +
    xlab(paste("semana epidemiológica de", max(obj$ano) )) +
    ylab("incidência")+
    theme(legend.position="bottom",
          legend.title = element_blank())+
    labs(title = "", 
         subtitle = paste("(C) Incidência de", titulo))
  
  
  
  ## ------------------------
   # series temporais")
  
  obj <- obj %>%
    mutate(
      niveis = case_when(
        level == 1 ~ "baixo risco",
        level == 2 ~ "receptivo",
        level == 3 ~ "transmissão",
        level == 4 ~ "alta atividade")
    )  
  
  obj$niveis <- factor(obj$niveis, ordered = TRUE, 
                      levels = c("baixo risco","receptivo","transmissão","alta atividade"))
  
  # Subfigura do topo (serie temporal de casos e tweets) -------------
  objc <- obj[(nrow(obj)-tsdur): nrow(obj), ]
  
  p4 <- objc %>%
    ggplot_waterfall('data','casos') +
    scale_color_manual(
      breaks = c("", "", "."),
      values = c("grey", "red", "darkgreen") 
    ) +
    theme_light() +
    theme(legend.position="none") +
    xlab(NULL) +
    labs(y="casos", 
         x="",
         title = "",
         subtitle = paste("(A) Série temporal de ", titulo)) 
  
  # colocar tweet, se dengue e significativo
  p5 <- ggplot(objc, aes(x=data, y=casos)) +
    geom_rect(aes(xmin=min(data), xmax=max(data), ymin=0, 
                  ymax=param$limiar_preseason*pop/1e5), 
              fill="green", alpha=1/10) +
    geom_rect(aes(xmin=min(data), xmax=max(data), ymin=param$limiar_preseason*pop/1e5, 
                  ymax=param$limiar_epidemico*pop/1e5), 
              fill="yellow", alpha=1/10) +
    geom_rect(aes(xmin=min(data), xmax=max(data), ymin=param$limiar_epidemico*pop/1e5, 
                  ymax=max(casos)), 
              fill="firebrick3", alpha=1/10) +
    geom_segment( aes(x=data, xend=data, y=0, yend=casos), color="grey") +
    geom_point() +
    theme_light() +
    theme(
      panel.grid.major.x = element_blank(),
      panel.border = element_blank(),
      axis.ticks.x = element_blank()
    ) +
    labs(y="casos", 
         x="",
         title = "",
         subtitle = paste("(B) Faixas de incidência baixa, média e alta")) 
  
  if(cid == "A90" & sig.tw) {
    objc$tw_pred <- predict(mod, newdata = objc)
    p5 <- p5 + geom_line(data = objc, aes(x = data, y = tw_pred),color="darkblue") 
  }
  
  
   # subfigura de alerta colorido")
  
  p6 <- ggplot(objc, aes(x=data, y=inc, fill = niveis)) +
    geom_bar(stat = "identity", width=3) +
    scale_fill_manual(values = c("darkgreen", "yellow", "orange2","red") ) +
    theme(legend.position="none") +
    ylab("Incidência (casos por 100 mil)") +
    xlab(NULL)  
  
  ## figuras
  png(paste0(nome,"1.png"), width = 12, height = 18, units = "cm", res=200)
  fig <- grid.arrange(p1, p2, p3, nrow=3)
  dev.off()
  
  png(paste0(nome,"2.png"), width = 16, height = 14, units = "cm", res=200)
  fig2 <- grid.arrange(p4, p5, nrow = 2)
  dev.off()
  
  png(paste0(nome,"3.png"), width = 16, height = 10, units = "cm", res=200)
  print(p6)
  dev.off()
  
  return("figuras feitas")
}
