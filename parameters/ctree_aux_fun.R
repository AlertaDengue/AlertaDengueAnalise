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


# odds - ratio (nao vou usar, fica a memoria)
#The odds ratio (OR) is a measure of how strongly an event is associated 
#with exposure. The odds ratio is a ratio of two sets of odds: the odds of the 
#event occurring in an exposed group versus the odds of the event occurring in 
#a non-exposed group.  
# odds(exposed) = (receptivo com Rt1)/(receptivo sem Rt1) 
#nu <- cumsum(x$nRt1)/cumsum((x$n - x$nRt1))
#nu <- x$nRt1/(x$n - x$nRt1)
# odds(non-exposed) = (naoreceptivo com Rt1)/(naoreceptivo sem Rt1)
#de <- (sum(x$n) - cumsum(x$nRt1))/(sum(x$n) - cumsum((x$n - x$nRt1)))
#de <- (x$n - x$nRt1)/(x$n - (x$n - x$nRt1))
#nu/de
