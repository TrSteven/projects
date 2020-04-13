library("lme4")

# Load data
students_lang <- read.csv("student/student-por.csv", sep = ";")
head(students_lang)

# Linear regression
lang_linear <- lm(G3 ~ sex + age + absences + school, data = students_lang)
summary(lang_linear)

# Mixed model
lang_mixed <- lmer(G3 ~ sex + age + absences + (1|school), data = students_lang)
summary(lang_mixed)

AIC(lang_linear)
AIC(lang_mixed)

logLik(lang_linear)
logLik(lang_mixed)
