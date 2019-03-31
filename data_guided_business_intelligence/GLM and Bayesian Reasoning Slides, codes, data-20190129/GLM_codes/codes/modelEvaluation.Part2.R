#
# @author: Nagiza Samatova
#

# make sure that the file is in working dir getwd()
getwd()
source("scoringEvalFunctions.R")

#-----------------------------------------------
# Ex.1: Fitting linear model into non-linear data
#		results in over-predicting for some ranges of x
#		and under-predicting for other ranges of x 
#-----------------------------------------------
d <- data.frame(y=(1:10)^2, x=1:10)
d
lmodel <- lm (y~x, data=d)
summary(lmodel)
# Model: y = -22 + 11 * x

d$prediction <- predict(lmodel, newdata=d)

names(d)

library('ggplot2')

ggplot(data=d) + geom_point(aes(x=x,y=y)) +
  geom_line(aes(x=x,y=prediction), color='blue') +
  geom_segment(aes(x=x, y=prediction, yend=y,xend=x), color='red') +
  scale_y_continuous('')

# Residuals: the difference between model prediction 
#             and actual value of the response
lmodel$residuals
# For which values of x, the model over-predicts?
# For which values of x, the model under-predicts?

#-----------------------------------------------
# Ex.2: Computing Performance Measures 
#-----------------------------------------------
d <- data.frame(y=(1:10)^2, x=1:10)
lmodel <- lm (y~x, data=d)
d$prediction <- predict(lmodel, newdata=d)

RMSE <- rmse(d$y,d$prediction)
Rsquared <- rsq(d$y, d$prediction)

# Correlation between the predicted and 
# the actual values of the response
help(cor)

# Pearson: linear correlation
pCor <- cor(d$prediction, d$y, method="pearson")

# Spearman: rank order correlation
sCor <- cor(d$prediction, d$y, method="spearman")

# Report the performance metrics
data.frame(RMSE=RMSE, Rsquared=Rsquared,
           Pearson=pCor, Spearman=sCor)


#-----------------------------------------------
# Ex.3: Adjusting for model complexity
# R-squared/RMSE can be over-optimistic: 
# More input vars may lead to higher R-squared/smaller RMSE
#       ==> Adjusted R-squared
#       ==> Residual Standard Error (RSE)
#-----------------------------------------------
# Let's explore relationships between
# a state's murder rate and other chars:
# illitracy rate, avg income, # of days below freezing
states <- as.data.frame(
  state.x77[,c("Murder","Population",
               "Illiteracy", "Income", "Frost")])
dim(states)
t(states[1,])
dtrain <- states[1:25,]
dtest <- states[26:50,]
murderModel <- lm (Murder ~ Population + Illiteracy 
             + Income + Frost, data=dtrain)
summary (murderModel)
# Based on Multiple R-squared: How much (%) predictor variables 
# account for the variance in murder rates 

summary(murderModel)$coefficients
# Which predictors are statistically significant?
# Holding all the other predictors constant,
# how much the increase in 1% of Illitreacy contributes
# to the increase/decrease in the Murder rate (%-wise)?

dim(summary(murderModel)$coefficients)[1]
dim(dtrain)[1]
dfm <- df(dtrain, murderModel)
# How many degrees of freedom does the model have?
# What is the adjusted R-squared?

rse(murderModel,dfm)
# How is RSE compared to RMSE values for the model?
summary(murderModel)

#---------------------------------------
# Ex.4: When vs. Where model over-under-predicts
#--------------------------------------
dtrain$prediction <- predict(murderModel,newdata=dtrain)
dtest$prediction <- predict(murderModel,newdata=dtest)
names(dtest)


ggplot(data=dtest, aes(x=prediction,y=Murder)) +
  geom_point(alpha=0.5,color="black") +
  geom_smooth(aes(x=prediction,y=Murder,color="black")) +
  geom_line(aes(x=Murder,y=Murder,color="blue"))
# blue line: ideal relation: Murder = prediction
# smoothing line: average relation between prediction
# and actual Murder rate

# How are your conclusions different
# for the training data?
ggplot(data=dtrain, aes(x=prediction,y=Murder)) +
  geom_point(alpha=0.5,color="black") +
  geom_smooth(aes(x=prediction,y=Murder,color="black")) +
  geom_line(aes(x=Murder,y=Murder,color="blue"))

# On average, are the predictions correct?
# Is smoothing line along the line of perfect fit?

# Plot residuals as a function of predicted values
# When the model is over- or under- predicting?
# based on the model's output?
ggplot(data=dtest, aes(x=prediction,y=prediction-Murder)) +
  geom_point(alpha=0.5,color="black") +
  geom_smooth(aes(x=prediction,y=prediction-Murder,color="black")) 

# Plot residuals as a function of actual values
# Where the model is over- or under- predicting
# based on the actual outcome?
ggplot(data=dtest, aes(x=Murder,y=prediction-Murder)) +
  geom_point(alpha=0.5,color="black") +
  geom_smooth(aes(x=Murder,y=prediction-Murder,color="black")) 

# What is the difference between 
# the RMSE and R-squared metrics for 
# training and test data
rmse(dtrain$Murder,dtrain$prediction)
rmse(dtest$Murder,dtest$prediction)

rsq(dtrain$Murder,dtrain$prediction)
rsq(dtest$Murder,dtest$prediction)

# How much (%) predictor variables 
# account for the variance in murder rates
# for the TEST data? How does it compare
# with the TRAINING data?

summary(murderModel)
# Build the model including ONLY significant predictors
murderModelReduced <- lm (
  Murder ~ Population + Illiteracy, data=dtrain)
summary(murderModelReduced)

dtrain$prediction <- predict(murderModelReduced,newdata=dtrain)
dtest$prediction <- predict(murderModelReduced,newdata=dtest)

# How performance measures for the reduced model
# change compared to the original model?
# Does it make sence to use reduced model? Why?
rsq(dtrain$Murder,dtrain$prediction)
rsq(dtest$Murder,dtest$prediction)
#----------------------------------
# Ex.5: Inflation due to outlier matching
# Perfect prediction of a few OUTLIERS 
# produces INFLATED Correlation/R-squared
#-----------------------------------
y <- c(1,2,3,4,5,9,10)
ypred <- c(0.5, 0.5, 0.5, 0.5, 0.5, 9, 10)
cor(y,ypred)

#----------------------------------
# Ex.6: Inflation due to Multi-collinearity
#-----------------------------------

# Detect if multicollinearity is present in the data
library(car)

# Test Variance Inflation Factor (vif) statistics
vifstats <- vif (murderModel)

sqrt(vifstats) > 2.0 # problem with a predictor var?

# Look at a different data set
data(mtcars)
dim(mtcars)
names(mtcars)

# horse power and weight
fit <- lm(mpg ~ hp + wt, data=mtcars)
mpgpred <- predict(fit, newdata=mtcars)
rmse(mtcars$mpg, mpgpred)
rsq(mtcars$mpg, mpgpred)

vifstats <- vif (fit)
sqrt(vifstats) > 2.0 # problem with a predictor var?

# horse power, weight, interaction between hp and wt
fit <- lm(mpg ~ hp + wt + hp:wt, data=mtcars)
mpgpred <- predict(fit, newdata=mtcars)
rmse(mtcars$mpg, mpgpred)
rsq(mtcars$mpg, mpgpred)

vifstats <- vif (fit)
sqrt(vifstats) > 2.0 # problem with a predictor var?