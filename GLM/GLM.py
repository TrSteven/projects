import pandas as pd
import statsmodels.formula.api as smf
import statsmodels.api as sm
from patsy import dmatrices

# Interpretation of linear, logistic and Poisson regression
# Dataset: http://users.stat.ufl.edu/~aa/cda/data/Crabs.dat
# Agresti - An Introduction to Categorical Data Analysis (Third Edition)
# Section 3.3.3

# color = color (1, medium light; 2, medium; 3, medium dark; 4, dark)
# spine = spine condition (1, both good; 2, one broken; 3, both broken)
# width = shell width (cm)
# weight = weight (kg)
# sat = number of satellites

df = pd.read_csv('crabs.txt', sep='\s+')
df = df.replace({'color': {1: 'Medium Light', 2: 'Medium', 3: 'Medium Dark', 4: 'Dark'}})
df = df.replace({'spine': {1: 'Both Good', 2: 'One Broken', 3: 'Both Broken'}})
df = df.replace({'y': {0: 'No', 1: 'Yes'}})
df = df.drop('crab', 1)

#####################
# Linear regression #
#####################

lin_reg = smf.ols(formula = 'sat ~ width + weight + color + spine', data=df).fit()
lin_reg.summary()

# A unit increase of the width is associated with an increase of 0.023 in the number of satellites

# Crabs with a medium color are associated with an increase of 0.61 in the number of satellites 
# compared to crabs with a dark color

#######################
# Logistic regression #
#######################
y, X = dmatrices('y ~ width + weight + color + spine', data=df, return_type='dataframe')
log_reg = sm.Logit(y['y[Yes]'], X, data=df).fit()
log_reg.summary()

# A unit increase in the weight increases the odds 
# (that female crabs atleast have one satellite) 
# multiplicatively by exp(0.83) = 2.29
# Or: increases the odds with (2.29 - 1) * 100% = 129%

# Or use:
log_reg_2 = sm.GLM(y['y[Yes]'], X, data=df, 
                   family=sm.families.Binomial(link=sm.families.links.logit)).fit()
log_reg_2.summary()

# Or use:
log_reg_3 = smf.glm('y ~ width + weight + color + spine', data=df, family=sm.families.Binomial()).fit()
log_reg_3.summary()

######################
# Poisson regression #
######################
y_2, X_2 = dmatrices('sat ~ width + weight + color + spine', data=df, return_type='dataframe')
poisson_reg = sm.GLM(y_2, X_2, data=df,
                     family=sm.families.Poisson(link=sm.families.links.log)).fit()
poisson_reg.summary()

# Or use:
poisson_reg_2 = smf.glm('sat ~ width + weight + color + spine', data=df,
                         family=sm.families.Poisson(link=sm.families.links.log)).fit()
poisson_reg_2.summary()

# x = predictor and B = coefficient of the predictor
# For a unit change in x, the expected count changes by a factor of exp(B) 
# (holding all other variables constant, or adjusting for the other variables).

# Alternatively, the percentage change in the expected count for a unit change in x,
# can be computed as 100 * (exp(B) - 1) %

# A unit increase in the weight score increase the expected count 
# multiplicatively by exp(0.50) = 1.65
# Or: increases the expected count with (1.65 - 1) * 100% = 65%

# Also, see Agresti - An Introduction to Categorical Data Analysis (Third Edition)
# Section 3.3.3 (only one predictor)