library(mlr)
library(mlbench)

# Use the vehicle dataset from the mlbench package
# Predict if vehicle is a van or not
data(Vehicle)
mydata <- Vehicle
names(mydata)[names(mydata)=="Class"] <- "outcome"
table(mydata$outcome)
mydata$outcome <- as.factor(ifelse(mydata$outcome=="van", 
                                   "pos", "neg"))
table(mydata$outcome)

# Split in training and test set
n <- nrow(mydata)
set.seed(3)
train.id <- sample(n, size = 1/2*n)
train.set = mydata[train.id, ]
test.set = mydata[-train.id, ]

# Define the task
task.vehicle <- makeClassifTask(data = train.set, target = "outcome", positive = "pos")

#######################
# Tune the parameters #
#######################

# Create 2 SVM learners (one with linear kernel, other with radial kernel)
# Linear kernel:
lrn.linear <- makeLearner("classif.ksvm", par.vals = list(kernel = "vanilladot"))

# Radial kernel:
lrn.radial <- makeLearner("classif.ksvm", par.vals = list(kernel = "rbfdot"))

# Create a search space for linear kernel:
ps.linear <- makeParamSet(
  makeNumericParam("C", lower = -10, upper = 10, trafo = function(x) 10^x)
)

# Create a search space for radial kernel:
ps.radial <- makeParamSet(
  makeNumericParam("C", lower = -10, upper = 10, trafo = function(x) 10^x),
  makeNumericParam("sigma", lower = -10, upper = 10, trafo = function(x) 10^x)
)

# Use grid to find optimal parameter values
ctrl <- makeTuneControlGrid(resolution = 10)

# Use 3-fold cross-validation
rdesc <- makeResampleDesc("CV", iters = 3)

# Tune parameters
res.linear <- tuneParams(lrn.linear, task = task.vehicle, resampling = rdesc,
                         par.set = ps.linear, control = ctrl, measures = acc)
res.radial <- tuneParams(lrn.radial, task = task.vehicle, resampling = rdesc,
                         par.set = ps.radial, control = ctrl, measures = acc)
# Optimal parameters
res.linear
res.radial

# Make learner with tuned parameters
lrn.linear.tuned <- setHyperPars(lrn.linear, par.vals = res.linear$x)
lrn.radial.tuned <- setHyperPars(lrn.radial, par.vals = res.radial$x)

# Check hyperparameters
getHyperPars(lrn.linear.tuned)
getHyperPars(lrn.radial.tuned)

# Change prediction type, to calculate ROC curve
lrn.linear.tuned = setPredictType(lrn.linear.tuned, "prob")
lrn.radial.tuned = setPredictType(lrn.radial.tuned, "prob")

# Train learner with tuned parameters
model.linear <- train(lrn.linear.tuned, task.vehicle)
model.radial <- train(lrn.radial.tuned, task.vehicle)

###############################
# Performance on training set #
###############################
pred.train.linear <- predict(model.linear, task = task.vehicle)
pred.train.radial <- predict(model.radial, task = task.vehicle)

# Construct ROC curves
df.train.linear <- generateThreshVsPerfData(pred.train.linear, measures = list(fpr, tpr))
df.train.radial <- generateThreshVsPerfData(pred.train.radial, measures = list(fpr, tpr))
plotROCCurves(df.train.linear)
plotROCCurves(df.train.radial)

# AUC and accuracy for training set
ms = list("auc" = auc, "acc" = acc)
performance(pred.train.linear, measures = ms)
performance(pred.train.radial, measures = ms)

###########################
# Performance on test set #
###########################
pred.test.linear <- predict(model.linear, newdata = test.set)
pred.test.radial <- predict(model.radial, newdata = test.set)

# Construct ROC curves
df.test.linear <- generateThreshVsPerfData(pred.test.linear, measures = list(fpr, tpr))
df.test.radial <- generateThreshVsPerfData(pred.test.radial, measures = list(fpr, tpr))
plotROCCurves(df.test.linear)
plotROCCurves(df.test.radial)

# AUC and accuracy for training set
ms = list("auc" = auc, "acc" = acc)
performance(pred.test.linear, measures = ms)
performance(pred.test.radial, measures = ms)

# SVM with radial kernel performs better than SVM with linear kernel
