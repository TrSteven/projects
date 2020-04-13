# Load packages
library(caret)
library(modeldata)
data(mlc_churn)

# Write to csv for Python analysis
write.csv(mlc_churn, "data/churn.csv", row.names = FALSE)

trainIndex <- createDataPartition(mlc_churn$churn, p = .8, list = FALSE, times = 1)
churnTrain <- mlc_churn[ trainIndex,]
churnTest  <- mlc_churn[-trainIndex,]

prop.table(table(mlc_churn$churn))
prop.table(table(churnTrain$churn))

# Scaling and centering of features is not necassary for the random forest method 
# Note that this can be done with this code:
# preProcValues <- preProcess(churnTrain, method = c("scale", "center"))
# churnTrain <- predict(preProcValues, churnTrain)
# churnTest <- predict(preProcValues, churnTest)

# Get tunable parameters for randomforest
# mtry: number of randomly Selected Predictors
modelLookup("rf")

# Use repeated 5-fold CV to tune parameter
# Evaluate performace using the twoClassSummary function
# This computes the sensitivity, specificity and area under the ROC curve
# See: https://topepo.github.io/caret/model-training-and-tuning.html#alternate-performance-metrics
# Optimize for ROC metric
fitControl <- trainControl(method = "repeatedcv", number = 5, repeats = 2, 
                           classProbs = TRUE,
                           summaryFunction = twoClassSummary)
# for multiple parameters, use expand.grid(par1 = ..., par2 = ...)
grid <- data.frame(mtry = c(5:20)) 

rf_model <- train(churn ~ ., data = churnTrain, 
                  method="rf", metric = "ROC", ntree = 100,
                  trControl = fitControl, tuneGrid = grid)

# Check final model
rf_model
plot(rf_model)

# Variable Importance
plot(varImp(rf_model))
rf_imp <- varImp(rf_model)$importance  
rf_imp$names <- rownames(rf_imp)
rownames(rf_imp) <- NULL
rf_imp <- rf_imp[order(- rf_imp$Overall), , drop = FALSE]
par(mai=c(0.5, 2.5, 0.5, 0.5))
barplot(rf_imp[1:30, "Overall"], names.arg = rf_imp[1:30, "names"], horiz = TRUE, cex.names=0.8,las=1)

# Plot 2 most important predictors vs churn
boxplot(total_day_minutes ~ churn, data = churnTrain)
boxplot(total_day_charge ~ churn, data = churnTrain)

# Check performance on test set
rf_model_pred <- predict(rf_model, newdata = churnTest)
confusionMatrix(data = rf_model_pred, reference = churnTest$churn)

# method = "none" fits only one model to the entire training set
# See: https://topepo.github.io/caret/model-training-and-tuning.html#notune
# (Note: ntree, or number of trees, is not a tuning parameter, because larger ntree will always be better,
# so ntree should not be in tuneGrid)
rf_no_tuning <- train(churn ~ ., data = churnTrain, 
                           method="rf",
                           ntree = 300,
                           trControl = trainControl(method = "none"), 
                           tuneGrid = data.frame(mtry = 6))

# Balancing the unbalanced data
churn_table <- table(churnTrain$churn)
rf_no_tuning_balanced <- train(churn ~ ., data = churnTrain, 
                               method="rf",
                               ntree = 300,
                               trControl = trainControl(method = "none"), 
                               tuneGrid = data.frame(mtry = 6),
                               strata = churnTrain$churn,
                               sampsize = c("yes" = min(churn_table), 
                                            "no" = min(churn_table)))

cm <- confusionMatrix(data = predict(rf_no_tuning, newdata = churnTest), 
                                reference = churnTest$churn)
cm_balanced <- confusionMatrix(data = predict(rf_no_tuning_balanced, newdata = churnTest), 
                               reference = churnTest$churn)

cm
cm_balanced

cm$table
cm$byClass

cm_balanced$table
cm_balanced$byClass # Sensitivty higher when balanced sampling is used






