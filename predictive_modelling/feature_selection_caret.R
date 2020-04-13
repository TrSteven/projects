library(caret)
library(mlbench)
set.seed(5)

# Recursive Feature Elimination
# See also: https://topepo.github.io/caret/recursive-feature-elimination.html#rfe

# Use BostonHousing data
data(BostonHousing)
training <- BostonHousing
x <- BostonHousing[, -14]
y <- BostonHousing[, 14]

# sizes determines the number of most important features the rfe should iterate
sizes <- c(7:13)

# use 10-fold cross validation
ctrl <- rfeControl(functions = rfFuncs,
                   method = "cv",
                   number = 10,
                   verbose = FALSE)

lmProfile <- rfe(x = x, y = y, sizes = sizes, rfeControl = ctrl)
lmProfile
plot(lmProfile)

# Optimal variables:
lmProfile$optVariable

# Not included:
setdiff(colnames(x), lmProfile$optVariable)
