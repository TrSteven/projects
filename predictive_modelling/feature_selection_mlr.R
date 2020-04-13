library(mlr)
library(mlbench)
set.seed(5)

# See: https://mlr-org.github.io/mlr-tutorial/release/html/feature_selection/index.html

# Use BostonHousing data
data(BostonHousing)

# Define the task
regr.task = makeRegrTask(id = "bh", data = BostonHousing, target = "medv")

# Search algorithm
## sfs: Sequential Forward Search
## sbs: Sequential Backward Search
## sffs: Sequential Floating Forward Search
## sfbs: Sequential Floating Backward Search
# Search is stopped if improvement is smaller than alpha
ctrl = makeFeatSelControlSequential(method = "sfs", alpha = 0.02)

# Use cross-validation with 10 iterations
rdesc = makeResampleDesc("CV", iters = 10)

# Use linear regression
sfeats = selectFeatures(learner = "regr.lm", task = regr.task, resampling = rdesc, control = ctrl,
                        show.info = FALSE)

analyzeFeatSelResult(sfeats)
sfeats$x
# crim, zn, chas, nox, rm, dis, rad, tax, ptratio, b, lstat
