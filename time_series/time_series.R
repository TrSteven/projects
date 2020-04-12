#################
# Load packages #
#################
library(forecast)

#############
# Visualize #
#############
Amtrak.data <- read.csv("amtrak_data.csv")
ridership.ts <- ts(Amtrak.data$Ridership, start = c(1991,1), end = c(2004, 3), freq = 12)
plot(ridership.ts, xlab = "Time", ylab = "Ridership", ylim = c(1300, 2300), bty = "l")

# Aggregate to year level
ridership.annual.ts <- aggregate(ridership.ts)
plot(ridership.annual.ts, xlab = "Time", ylab = "Ridership", bty = "l")

# Ridership boxplot for every month
boxplot(ridership.ts ~ cycle(ridership.ts))

# Decomposition
plot(decompose(ridership.ts, type = "additive"))
plot(decompose(ridership.ts, type = "multiplicative"))

#############
# Modelling #
#############
# Training + validation
nValid <- 36
nTrain <- length(ridership.ts) - nValid
train.ts <- window(ridership.ts, start = c(1991, 1), end = c(1991, nTrain))
valid.ts <- window(ridership.ts, start = c(1991, nTrain + 1),
                   end = c(1991, nTrain + nValid))

# Fitting
naive.pred <- naive(train.ts, h = nValid, level = 0.9)
snaive.pred <- snaive(train.ts, h = nValid, level = 0.9)

ridership.lm <- tslm(train.ts ~ trend + I(trend^2))
ridership.lm.pred <- forecast(ridership.lm, h = nValid, level = 0.9)

ridership.lm.season <- tslm(train.ts ~ season)
ridership.lm.season.pred <- forecast(ridership.lm.season, h = nValid, level = 0.9)

ridership.lm.trend.season <- tslm(train.ts ~ trend + I(trend^2) + season)
ridership.lm.trend.season.pred <- forecast(ridership.lm.trend.season, h = nValid, level = 0.9)

ridership.lm.sin.cos <- tslm(train.ts ~ trend + I(trend^2) + 
                               I(sin(2*pi*trend/12))+ I(cos(2*pi*trend/12)))
ridership.lm.sin.cos.pred <- forecast(ridership.lm.sin.cos, h = nValid, level = 0.9)

ridership.ets <- ets(train.ts, model = "ZZZ")
summary(ridership.ets) # Model is ETS(A,N,A) 
ridership.ets.pred <- forecast(ridership.ets, h = nValid, level = 0.9)

ridership.arima <- auto.arima(train.ts)
ridership.arima.pred <- forecast(ridership.arima, h = nValid, level = 0.9)

plot(naive.pred)
lines(valid.ts, lty = 3)
accuracy(naive.pred, valid.ts)
         
plot(snaive.pred)
lines(valid.ts, lty = 3)
accuracy(snaive.pred, valid.ts)

plot(ridership.lm.pred)
lines(valid.ts, lty = 3)
accuracy(ridership.lm.pred, valid.ts)

plot(ridership.lm.season.pred)
lines(valid.ts, lty = 3)
accuracy(ridership.lm.season.pred, valid.ts)

plot(ridership.lm.trend.season.pred)
lines(valid.ts, lty = 3)
accuracy(ridership.lm.trend.season.pred, valid.ts)

plot(ridership.lm.sin.cos.pred)
lines(valid.ts, lty = 3)
accuracy(ridership.lm.sin.cos.pred, valid.ts)

plot(ridership.ets.pred)
lines(valid.ts, lty = 3)
accuracy(ridership.ets.pred, valid.ts)

plot(ridership.arima.pred)
lines(valid.ts, lty = 3)
accuracy(ridership.arima.pred, valid.ts)

###################
# Autocorrelation #
###################
summary(ridership.arima)

acf(ridership.ts)
pacf(ridership.ts)

diff.1 <- diff(ridership.ts, lag = 1)
diff.1.12 <- diff(diff.1, lag = 12)

acf(diff.1)
pacf(diff.1)

acf(diff.1.12)
pacf(diff.1.12)

acf(ridership.arima.pred$residuals)
pacf(ridership.arima.pred$residuals)

####################
# Rolling forecast #
####################
fixed.nValid <- 36
fixed.nTrain <- length(ridership.ts) - fixed.nValid
stepsAhead <- 2
error <- rep(0, fixed.nValid - stepsAhead + 1)
percent.error <- rep(0, fixed.nValid - stepsAhead + 1)
for(j in fixed.nTrain:(fixed.nTrain + fixed.nValid - stepsAhead)) {
  train.ts <- window(ridership.ts, start = c(1991, 1), end = c(1991, j))
  valid.ts <- window(ridership.ts, start = c(1991, j + stepsAhead), end = c(1991, j + stepsAhead))
  naive.pred <- naive(train.ts, h = stepsAhead)
  error[j - fixed.nTrain + 1] <- valid.ts - naive.pred$mean[stepsAhead]
}
mean(abs(error))
sqrt(mean(error^2))

# Or use build in function
error_tsCV <- tsCV(ridership.ts, forecastfunction = naive, h = stepsAhead, 
                   window = NULL, initial = fixed.nTrain - 1)
error_tsCV <- error_tsCV[, stepsAhead]
error_tsCV <- error_tsCV[!is.na(error_tsCV)]
error_tsCV - error

