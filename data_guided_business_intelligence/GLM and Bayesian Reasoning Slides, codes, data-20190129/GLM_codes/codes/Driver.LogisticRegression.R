# Use of logistic regression for
# the data on infidelity

install.packages("AER")
library(AER)

data(Affairs, package="AER")
summary(Affairs)
names(Affairs)
dim(Affairs)
t(Affairs[1,])

table(Affairs$affairs)

Affairs$ynaffair[Affairs$affairs > 0] <- 1
Affairs$ynaffair[Affairs$affairs == 0] <- 0
Affairs$ynaffair <- factor(Affairs$ynaffair,
                           levels = c(0,1),
                           labels = c("No","Yes"))

table(Affairs$ynaffair)

fit.full <- glm (ynaffair ~ 
                   gender + 
                   age + 
                   yearsmarried +
                   children +
                   religiousness +
                   education +
                   occupation +
                   rating, 
                 data = Affairs, 
                 family = binomial(link="logit")
            )
summary(fit.full)

fit.reduced <- glm (ynaffair ~ 
                   age + 
                   yearsmarried +
                   religiousness +
                   rating, 
                 data = Affairs, 
                 family = binomial(link="logit")
)
summary(fit.reduced)

# Because two models are nested 
# (fit.reduced is a subset of fit.full), 
# use anova() function to compare with 
# chi-square version of the test.
# Insignificant p-value (>=0.05) 
# will indicate that the reduce model
# fits as well as the full model

anova(fit.reduced, fit.full, test = "Chisq")

# Examine model parameters:
# regression coefficients
options (digits=3)
coef(fit.reduced)

# In logistic regression, response is 
# modeled as the log(odds) that Y=1.
# The regression coefficients give 
# the change in log(odds) in the response of 
# a unit change in the predictor variable, 
# holding all the other predictors constant.

# log(odds) are hard to interpret;
# put results on an odd scale 
# by exponentiating the coefficient values

exp(coef(fit.reduced))

# Use predict() function to observe 
# the impact of varying the levels of 
# a predictor variable on 
# the probability of the outcome 

test.data <- data.frame(rating=c(1,2,3,4,5),
                        age = mean(Affairs$age),
                        yearsmarried = mean(Affairs$yearsmarried),
                        religiousness = mean(Affairs$religiousness))

test.data

test.data$prob <- predict(fit.reduced,
                          newdata = test.data,
                          type = "response")
test.data


