## Code to obtain \alpha*100% confidence intervals for R_{t}
## Copyleft (or the one to blame): Carvalho, LMF (2014)
## It's all quite simple: we have the conditional distribution of R_{t}:
## p(R_{t}| J_{t}, J_{t + 1}) = (R_{t}*J_{t})^J_{t + 1} * exp(- R_{t}*J_{t} )
## Lets just sample analytically from it, since its a(n unnormalised) Gamma distribution
## Thanks to Dr. Leo Bastos (Fiocruz) for insightful suggestions
source("../CODE/Rt.r")

dat <- read.csv("../DATA/dadojuntos_201433.csv", header=TRUE)
N <- length(unique(dat$SE))
casos <- rowSums(matrix(dat$casos, nrow = N))
M <- matrix(dat$casos, nrow = N) # 'matrix' of cases, each column is a HPA (APS)
matplot(M, lty = 1,  type = "l", ylab = "Notifications", xlab = "Time(weeks)")
legend(x="topright", legend = paste(unique(dat$APS)), 
       col = 1:ncol(M), lty = 1, cex = .7, bty = "n" )
####################################################
Rtb <- Rt.beta(casos)
# plot(Rtb$Rt, type = "l", lwd = 1,
#      ylab = expression(R[t]),
#      xlab = "Time (weeks)")
# lines(Rtb$lwr, lwd = 1, col = 3, lty = 2)
# lines(Rtb$upr, lwd = 1, col = 3, lty = 2)
# legend(x = "topleft", legend = c("Mean", "95% quantiles"),
#        col = c(1, 3), lty = 1:2, lwd = 2:1, cex = .7, bty="n")
#########################################
Rtb <- Rt.beta(casos)
Rtg <- Rt.gamma(casos)
plot(Rtg$Rt, type = "l", lwd = 2, ylim = c(0.5, 2.5))
lines(Rtg$lwr, lty = 2, lwd = 1, col = 2)
lines(Rtg$upr, lty = 2, lwd = 1, col = 2)
lines(Rtb$lwr, lwd = 1, col = 3, lty = 2)
lines(Rtb$upr, lwd = 1, col = 3, lty = 2)
legend(x = "topleft", legend = c("Mean", "95% quantiles"),
       col = 1, lty = 1:2, lwd=2:1, cex = .7, bty="n")

plot(Rtg$p1, type = "l", lwd = 2,
     ylab = expression(Pr(R[t]>1)), xlab = "Time (weeks)")
lines(Rtb$p1, lwd = 2, col = 2)
abline(h = .70, lwd = 2, lty = 2, col = "gray")