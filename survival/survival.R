library(dplyr)
library(survival)
library(survminer) # for better plots

# Source:
# https://bioconnector.github.io/workshops/r-survival.html

################
# lung dataset #
################
lung <- as_tibble(lung)
lung$s <- Surv(time = lung$time, event = lung$status)
lung$sex <- factor(lung$sex, levels = c(1, 2), labels = c("M", "F"))

sfit <- survfit(s ~ 1, data = lung)
sfit_sex <- survfit(s ~ sex, data = lung)

summary(sfit_sex, times = seq(0, 1000, 100))

ggsurvplot(sfit)
ggsurvplot(sfit_sex, conf.int = TRUE, pval = TRUE, risk.table = TRUE, 
           legend.labs = c("Male", "Female"), legend.title="Sex",  
           palette = c("dodgerblue2", "orchid2"), 
           title = "Kaplan-Meier Curve for Lung Cancer Survival", 
           risk.table.height=.15)

lung$agecat_1 <- cut(lung$age, breaks = c(0, 62, Inf), labels = c("young", "old"))
lung$agecat_2 <- cut(lung$age, breaks = c(0, 70, Inf), labels = c("young", "old"))

ggsurvplot(survfit(s ~ agecat_1, data = lung), pval = TRUE) # Not significant !
ggsurvplot(survfit(s ~ agecat_2, data = lung), pval = TRUE) # Significant !

# Better to treat age continuous with cox regression

# Regression model is asking: 
# “What is the effect of age on survival?”

# While the log-rank test and the KM plot is asking:
# “Are there differences in survival between those less than 70 and those greater than 70 years old?”

##################
# Cox regression #
##################
# HR=1: No effect
# HR>1: Increase in hazard
# HR<1: Reduction in hazard (protective)

fit_1 <- coxph(s ~ sex, data = lung, ties = "efron")
summary(fit_1)
# Going from male (baseline) to female results in 41.2% reduction in hazard.

fit_2 <- coxph(s ~ sex + age, data = lung)
summary(fit_2)

