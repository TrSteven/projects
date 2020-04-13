import pandas as pd
import statsmodels.formula.api as smf

sleepstudy = pd.read_csv('sleepstudy.csv')

# Random intercept
mixed_ri = smf.mixedlm('Reaction ~ 1 + Days', data = sleepstudy, 
                        groups = sleepstudy['Subject']).fit()
mixed_ri.summary()

# Random intercept + slope
mixed_rs = smf.mixedlm('Reaction ~ 1 + Days', data = sleepstudy, re_formula='Days',
                        groups = sleepstudy['Subject']).fit()
mixed_rs.summary()
