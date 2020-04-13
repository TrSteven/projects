import pandas as pd
import statsmodels.formula.api as smf

bodyweight = pd.read_csv('bodyweight.csv')

# Random intercept
mixed_ri = smf.mixedlm('Weight ~ 1 + Time', data = bodyweight, 
                        groups = bodyweight['Rat']).fit()
mixed_ri.summary()

# Random intercept + slope
mixed_rs = smf.mixedlm('Weight ~ 1 + Time', data = bodyweight, re_formula='Time',
                        groups = bodyweight['Rat']).fit()
mixed_rs.summary()
