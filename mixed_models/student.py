import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt

# New window for plotting: 'auto' instead of 'inline'
from IPython import get_ipython
get_ipython().run_line_magic('matplotlib', 'inline')

# Load data
students_lang = pd.read_csv("student/student-por.csv", sep = ";")
students_lang.head()

# Linear regression
lang_linear = smf.ols('G3 ~ sex + age + absences + school', data = students_lang).fit()

# Inspect the results
print(lang_linear.summary())
    
fig = plt.figure(figsize=(12,8))
fig = sm.graphics.plot_partregress_grid(lang_linear, fig = fig)

plt.scatter(students_lang.G3, lang_linear.fittedvalues)
plt.title('Observed vs. fitted')
plt.xlabel('Observed')
plt.ylabel('Fitted')
plt.show()

# Mixed model
lang_mixed = smf.mixedlm("G3 ~ sex + age + absences", data = students_lang, 
                         groups = students_lang["school"]).fit(method = 'cg', maxiter = 1e3)

# Inspect the results
print(lang_mixed.summary())

plt.scatter(students_lang.G3, lang_mixed.fittedvalues)
plt.title('Mixed model')
plt.xlabel('Observed')
plt.ylabel('Fitted')
plt.show()


# Check attributes of model
dir(lang_linear)
lang_linear.fittedvalues
students_lang.G3

# Give AIC
def calc_AIC(model, df):
    return 2*df - 2*model.llf

# Likelihood
lang_linear.llf
lang_mixed.llf

# AIC
lang_linear.aic
calc_AIC(lang_linear, 5)
calc_AIC(lang_linear, 6) # R uses extra degree of freedom in AIC calculation (i.e. variance)
# See: https://github.com/statsmodels/statsmodels/issues/1802

lang_mixed.aic
calc_AIC(lang_mixed, 5)
calc_AIC(lang_mixed, 6) # R uses extra degree of freedom in AIC calculation (i.e. variance)
