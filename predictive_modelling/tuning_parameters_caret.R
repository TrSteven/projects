library(caret)
library(mlbench)

# See also: 
# https://machinelearningmastery.com/tuning-machine-learning-models-using-the-caret-r-package/

# Available models
names(getModelInfo())

# Get tunable parameters
modelLookup("lvq")
modelLookup("rf")

# Use the Sonar dataset from the mlbench package
# Predict if vehicle is a van or not
data(Sonar)
str(Sonar[, 1:10])
table(Sonar$Class)

# Split in training and test set
set.seed(998)
inTraining <- createDataPartition(Sonar$Class, p = .75, list = FALSE)
training <- Sonar[ inTraining,]
testing  <- Sonar[-inTraining,]

####################
# Parameter tuning #
####################
# Use repeated 10-fold CV
fitControl <- trainControl(method = "repeatedcv", number = 10, repeats = 3)

#############################################################
# Automatic grid search of the size and k attributes of LVQ #
# with 5 (tuneLength=5) values of each (25 total models)    #
#############################################################
model_1 <- train(Class ~ ., data = training, method="lvq", metric = "Kappa", 
  preProcess = c("center", "scale"), trControl = fitControl, tuneLength = 5)

# Note, it is also possible to not use the preProcess argument in the train function,
# but to preprocess the data before training, see:
# https://topepo.github.io/caret/pre-processing.html#centering-and-scaling
# preProcValues <- preProcess(training, method = c("center", "scale"))
# trainTransformed <- predict(preProcValues, training)
# testTransformed <- predict(preProcValues, testing)

model_1
plot(model_1)
plot(varImp(model_1))
model_1_pred <- predict(model_1, newdata = testing)
confusionMatrix(data = model_1_pred, reference = testing$Class)

#################################################
# Or: manually design the parameter tuning grid #
#################################################
grid <- expand.grid(size = c(5,10,20,50), k = c(1,2,3,4,5))

model_2 <- train(Class ~ ., data = training, method="lvq", metric = "Kappa", 
  preProcess = c("center", "scale"), trControl = fitControl, tuneGrid = grid)
model_2
plot(model_2)
plot(varImp(model_2))
model_2_pred <- predict(model_2, newdata = testing)
confusionMatrix(data = model_2_pred, reference = testing$Class)
