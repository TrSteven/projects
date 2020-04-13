from sklearn.model_selection import train_test_split
from sklearn import preprocessing
from sklearn.linear_model import LogisticRegression
from sklearn.svm import LinearSVC
from sklearn.svm import SVC
from sklearn.ensemble import RandomForestClassifier
from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import GridSearchCV
from sklearn.metrics import confusion_matrix
from sklearn.metrics import accuracy_score
from sklearn.metrics import roc_curve

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# data: 
# https://cran.r-project.org/web/packages/modeldata/modeldata.pdf

#############
# Read data #
#############
churn_df = pd.read_csv('data/churn.csv')
churn_df.dtypes
churn_df.head()

########################
# Descriptive analysis #
########################
# Plot options
# set the background colour of the plot to white
sns.set(style="whitegrid", color_codes=True)

# Create a countplot
sns.countplot(x='area_code', data=churn_df, hue='churn')

# Create barplot
vm_ac_churn = churn_df.groupby(['voice_mail_plan', 'area_code']).agg({'churn': 'count'})
vm_ac_churn.plot.bar(rot = 0)

# Create barplot using pivot table
pivot_churn = churn_df.pivot_table(index='area_code', columns='voice_mail_plan', 
                                   aggfunc='count', values='churn')
pivot_churn.plot.bar(stacked=False, figsize=(10,7))

###################
# Preprocess data #
###################
# Column names of predictors
predictors = churn_df.drop('churn', axis=1).columns.tolist()
predictors_num = churn_df.drop('churn', axis=1).select_dtypes('number').columns.tolist()
predictors_cat = churn_df.drop('churn', axis=1).select_dtypes('object').columns.tolist()

# Create dummy variables
one_hot_encoding = True
churn_df_dummy = pd.get_dummies(churn_df, drop_first = not one_hot_encoding)

# Create train and test
if one_hot_encoding:
    X = churn_df_dummy.drop(['churn_yes', 'churn_no'], axis=1)
else:
    X = churn_df_dummy.drop('churn_yes', axis=1)
    
y = churn_df_dummy['churn_yes']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.8, random_state=0, stratify=y)

# Check if proportion of churn is the same in train and test
sum(y_train)/len(y_train)
sum(y_test)/len(y_test)

# Scale numerical features
scaler = preprocessing.StandardScaler().fit(X_train[predictors_num])
X_train[predictors_num] = scaler.transform(X_train[predictors_num])
X_test[predictors_num] = scaler.transform(X_test[predictors_num])

########################
# Predictive modelling #
########################

def eval_performance(y_true, y_pred):
    tn, fp, fn, tp = confusion_matrix(y_true, y_pred, labels=[0, 1]).ravel()
    sens = tp / (tp + fn)
    acc = accuracy_score(y_test, y_pred)
    return {'tn': tn, 'fp': fp, 'fn': fn, 'tp': tp, 'acc': acc, 'sens': sens}
    
#######################
# Logistic Regression #
#######################
    
clf_lr = LogisticRegression(max_iter=1e4, fit_intercept=not one_hot_encoding, 
                            penalty='none').fit(X_train, y_train)
print(clf_lr.coef_)
print(clf_lr.intercept_)

# Performance
y_test_lr = clf_lr.predict(X_test)
eval_performance(y_test, y_test_lr)
pd.crosstab(y_test, y_test_lr, rownames=['True'], colnames=['Predicted'], margins=True)

##############
# Linear SVM #
##############
    
clf_lin_svc = LinearSVC(random_state=0, max_iter=1e4).fit(X_train, y_train)

# Performance
y_test_lin_svc = clf_lin_svc.predict(X_test)
eval_performance(y_test, y_test_lin_svc)
pd.crosstab(y_test, y_test_lin_svc, rownames=['True'], colnames=['Predicted'], margins=True)

##################################
# SVM with hyperparameter tuning #
##################################

# https://scikit-learn.org/stable/modules/grid_search.html
# Get hyperparameters
SVC().get_params()

param_grid_svc = [
  {'C': [1, 10, 100], 'kernel': ['linear']},
  {'C': [1, 10, 100], 'gamma': [0.1, 0.01], 'kernel': ['rbf']},
 ]

# https://scikit-learn.org/stable/modules/model_evaluation.html#scoring-parameter
search_svc = GridSearchCV(SVC(), param_grid_svc, cv=5, scoring='accuracy')
search_svc_res = search_svc.fit(X_train, y_train)

# summarize the results of the grid search
print(search_svc_res.best_score_)
print(search_svc_res.best_params_)

clf_rbf_svc = SVC(random_state=0, tol=1e-3, max_iter=1e4, 
                  C=10, kernel='rbf', gamma=0.1).fit(X_train, y_train)

# Performance
y_test_rbf_svc = clf_rbf_svc.predict(X_test)
eval_performance(y_test, y_test_rbf_svc)
pd.crosstab(y_test, y_test_rbf_svc, rownames=['True'], colnames=['Predicted'], margins=True)

#################
# Random forest #
#################

clf_rf = RandomForestClassifier(max_depth=None, n_estimators=500, 
                                random_state=0, class_weight=None).fit(X_train, y_train)

# Performance
y_test_rf = clf_rf.predict(X_test)
eval_performance(y_test, y_test_rf)
pd.crosstab(y_test, y_test_rf, rownames=['True'], colnames=['Predicted'], margins=True)

# ROC Curve
y_test_rf_prob = clf_rf.predict_proba(X_test)
fpr, tpr, thresholds = roc_curve(y_test, y_test_rf_prob[:, 1])
plt.plot(fpr, tpr)
plt.plot([0, 1], [0, 1], color='navy', linestyle='--')
plt.xlim([-0.05, 1.0])
plt.ylim([0.0, 1.05])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')

# Variable importance
var_imp = dict(zip(X_train.columns, clf_rf.feature_importances_))
# Sort dictionary https://stackoverflow.com/a/2258273
var_imp = sorted(var_imp.items(), key=lambda x: x[1], reverse=True)
var = [x[0] for x in var_imp]
imp = [x[1] for x in var_imp]
sns.barplot(y=var[0:10], x=imp[0:10], orient = "h")

# See also:
# https://scikit-learn.org/stable/auto_examples/inspection/plot_permutation_importance.html

#############################################
# Neural Network with hyperparameter tuning #
#############################################

# Get hyperparameters
MLPClassifier().get_params()

param_grid_nn = {'hidden_layer_sizes': [(100,), (75,), (50,), (25,), (25,25)],
                 #'activation': ["logistic", "relu"],
                 'alpha': [0.1, 0.01, 0.001, 0.0001]}

search_nn = GridSearchCV(MLPClassifier(max_iter = 10000), param_grid_nn, cv=2, scoring='accuracy')
search_nn_res = search_nn.fit(X_train, y_train)

# summarize the results of the grid search
print(search_nn_res.best_score_)
print(search_nn_res.best_params_)

clf_nn = MLPClassifier(hidden_layer_sizes=(25), alpha=0.1, max_iter=10000).fit(X_train, y_train)

# Performance
y_test_nn = clf_nn.predict(X_test)
eval_performance(y_test, y_test_nn)
pd.crosstab(y_test, y_test_nn, rownames=['True'], colnames=['Predicted'], margins=True)



