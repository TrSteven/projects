import statsmodels.api as sm
import statsmodels.formula.api as smf

#####################
# Survival function #
#####################

lung = sm.datasets.get_rdataset("lung", "survival").data

# https://bioconnector.github.io/workshops/r-survival.html
# sex: male = 1, female = 2
# status: censoring status 1 = censored, 2 = dead

lung["sex"] = lung["sex"].replace([1, 2], ["M", "F"])
# SurvfuncRight uses 1 for event and 0 for censoring
lung["status"] = lung["status"].replace([1, 2], [0, 1])

sf = sm.SurvfuncRight(lung["time"], lung["status"])
sf.summary().head()
sf.plot()

stat, pvalue = sm.duration.survdiff(lung.time, lung.status, lung.sex)
pvalue
    
##################
# Cox regression #
##################
cox_reg = smf.phreg('time ~ sex + age', data = lung, 
                    status = lung["status"].values, ties = "efron")

cox_reg_fit = cox_reg.fit()
print(cox_reg_fit.summary())
