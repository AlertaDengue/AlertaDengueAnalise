# funcao extraida da funcao partykit::bar_plot para extrair prob de Rt1 de cada node

probs_and_n <- function(x) {
  y1 <- x$fitted[["(response)"]]
  if (!is.factor(y1)) {
    if (is.data.frame(y1)) {
      y1 <- t(as.matrix(y1))
    }
    else {
      y1 <- factor(y1, levels = min(y):max(y))
    }
  }
  w <- x$fitted[["(weights)"]]
  if (is.null(w)) 
    w <- rep.int(1L, length(y1))
  sumw <- if (is.factor(y1)) 
    tapply(w, y1, sum)
  else drop(y1 %*% w)
  sumw[is.na(sumw)] <- 0
  prob <- c(sumw/sum(w), sum(w))
  names(prob) <- c(if (is.factor(y1)) levels(y1) else rownames(y1), 
                   "nobs")
  prob
}


# odds - ratio 
#The odds ratio (OR) is a measure of how strongly an event is associated 
#with exposure. The odds ratio is a ratio of two sets of odds: the odds of the 
#event occurring in an exposed group versus the odds of the event occurring in 
#a non-exposed group.  

# acumulado
tree.odds <- function(n, x, acum = TRUE){
  # n = total number of cases in the node
  # x = number of events in the node
  
  if (acum == TRUE){
    a <- cumsum(x)  # # Rt1 [ receptivo]
    c <- max(a)-a   # # Rt1 [nao receptivo]
    b <- cumsum(n - x)  # not Rt1 [receptivo]
    d <- max(b)-b    # not Rt1 [not receptivo]
  } else {
    a <- x  # # Rt1 [ receptivo]
    c <- sum(x)-x   # # Rt1 [nao receptivo]
    b <- n - x  # not Rt1 [receptivo]
    d <- sum(n)-b # not Rt1 [not receptivo]
  }

  odds <- (a * d) / (b * c)
  odds
}

#tree.odds(summ.regras$n, summ.regras$nRt1)
#tree.odds(summ.regras$n, summ.regras$nRt1, acum = FALSE)

#summ.regras <- summ.regras[, 1:8]
#summ.regras$odds <- tree.odds(summ.regras$n, summ.regras$nRt1, acum = FALSE)

# ranking de regras:
#summ.regras <- summ.regras[order(summ.regras$odds, decreasing = TRUE),]
#summ.regras

