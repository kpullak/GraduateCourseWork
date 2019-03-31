# Use of logistic regression for
# the data on siezures

install.packages("robust")
library(robust)

data(breslow.dat, package="robust")
summary(breslow.dat)
names(breslow.dat)
dim(breslow.dat)
t(breslow.dat[1,])

# Observe skewed predictors
# and presence of outliers
opar <- par(no.readonly = TRUE)
par (mfrow = c(1,2))
attach(breslow.dat)
hist(sumY, breaks=20, xlab="Seizure Count",
     main="Distribution of Seizures")
boxplot(sumY ~ Trt, xlab="Treatment",
        main = "Group Comparisons")
par(opar)

fit <- glm(sumY ~ Base + Age + Trt,
           data = breslow.dat, 
           family=poisson(link="log"))
summary(fit)

# interpret model parameters:
# regression coefficients
options(digits=3)
coef(fit)
exp(coef(fit))

# test for overdispersion
# using qcc package
install.packages("qcc")
library(qcc)
qcc.overdispersion.test(breslow.dat$sumY,
                        type = "poisson")

# deal with overdispersion
# by using quasipoisson distribution family
fit.od <- glm(sumY ~ Base + Age + Trt,
           data = breslow.dat, 
           family=quasipoisson())
summary(fit.od)



