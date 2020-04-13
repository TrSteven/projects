from sklearn.datasets import fetch_openml
from sklearn import preprocessing
from sklearn.impute import SimpleImputer
from sklearn.compose import ColumnTransformer
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import GridSearchCV
from sklearn.svm import SVC
from sklearn.inspection import permutation_importance

import matplotlib.pyplot as plt
import pandas as pd

# Pipeline + feature importance
# Pipeline is needed to determine importance of categorical features, see:
# https://scikit-learn.org/stable/auto_examples/inspection/plot_permutation_importance.html
# We do not want the importance of every level of a categorical feature (e.g. gender_male, gender_female),
# but the importance of a categorical feature in total (e.g. gender)

#############
# Read data #
#############
# Get data from openml
X, y = fetch_openml("titanic", version=1, as_frame=True, return_X_y=True)

# Write data to disk
X.join(y).to_csv('data/titanic.csv', index = False)

# Selected categorical and numeric predictors
predictors_cat = ['pclass', 'sex', 'embarked']
predictors_num = ['age', 'sibsp', 'parch', 'fare']
predictors = predictors_num + predictors_cat
X = X[predictors]

# Split in train and test
X_train, X_test, y_train, y_test = train_test_split(
    X, y, stratify=y, random_state=100, test_size=0.2)

# Check if dataset has missing values
pd.isnull(X).sum()

# Create scaler and fit on training set, 
# so scaling parameters of training set are used on test set
scaler = preprocessing.StandardScaler().fit(X_train[predictors_num])

# Create pipeline for categorical and numerical predictors
categorical_pipe = Pipeline([
    ('imputer', SimpleImputer(strategy='constant', fill_value='missing')),
    ('onehot', OneHotEncoder(handle_unknown='ignore'))
])

numerical_pipe = Pipeline([
    ('imputer', SimpleImputer(strategy='mean')),
    ('scaler', scaler)
])

# Preprocessing
preprocessing = ColumnTransformer(
    [('cat', categorical_pipe, predictors_cat),
     ('num', numerical_pipe, predictors_num)])

# Note that preprocessing can be used on the data as:
X_train_2 = preprocessing.fit_transform(X_train)
X_test_2 = preprocessing.fit_transform(X_test)

# Add column names to X_train_2 with:
# preprocessing.get_feature_names()
# But that gives an error
# See: https://github.com/scikit-learn/scikit-learn/issues/12525
# and https://github.com/scikit-learn/scikit-learn/issues/6425

##########################
# Permutation importance #
##########################
def plot_importance(model, X_test, y_test, n_repeats=10, n_jobs=2):
    result = permutation_importance(model, X_test, y_test, 
                                    n_repeats=n_repeats, n_jobs=n_jobs)
    sorted_idx = result.importances_mean.argsort()
    fig, ax = plt.subplots()
    ax.boxplot(result.importances[sorted_idx].T,
               vert=False, labels=X_test.columns[sorted_idx])
    ax.set_title("Permutation Importances (test set)")
    fig.tight_layout()
    plt.show()
    
#####################
# Random forest fit #
#####################
pipeline_rf = Pipeline(steps=[
    ('preprocess', preprocessing),
    ('classifier', RandomForestClassifier(random_state=0, n_estimators=100))
])

rf = pipeline_rf.fit(X_train, y_train)

# Accuracy
print("RF train accuracy: %0.3f" % rf.score(X_train, y_train))
print("RF test accuracy: %0.3f" % rf.score(X_test, y_test))

plot_importance(rf, X_test, y_test, n_repeats=10, n_jobs=2)

###############################
# SVM + hyperparameter tuning #
###############################

# Pipeline with Gridsearch
# https://scikit-learn.org/stable/tutorial/statistical_inference/putting_together.html
# Parameters of pipelines can be set using a ‘__’ separated parameter
# https://stackoverflow.com/q/43366561

svc_pipeline = Pipeline(steps=[
    ('preprocess', preprocessing),
    ('classifier', SVC(random_state=0))
])

param_grid_svc = [
  {'classifier__C': [1, 10, 100], 'classifier__kernel': ['linear']},
  {'classifier__C': [1, 10, 100], 'classifier__gamma': [0.1, 0.01], 'classifier__kernel': ['rbf']},
]

svc_gridsearch = GridSearchCV(svc_pipeline, param_grid_svc, scoring = 'accuracy').fit(X_train, y_train)

print("Best parameter (CV score=%0.3f):" % svc_gridsearch.best_score_)
print(svc_gridsearch.best_params_)

svc_pipeline_best = Pipeline(steps=[
    ('preprocess', preprocessing),
    ('classifier', SVC(random_state=0, C=1, gamma=0.1, kernel='rbf'))
])

svc_best = svc_pipeline_best.fit(X_train, y_train)

# Accuracy
print("SVM train accuracy: %0.3f" % svc_best.score(X_train, y_train))
print("SVM test accuracy: %0.3f" % svc_best.score(X_test, y_test))

plot_importance(svc_best, X_test, y_test, n_repeats=10, n_jobs=2)
