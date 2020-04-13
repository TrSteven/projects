# See: https://cran.r-project.org/web/packages/lme4/vignettes/lmer.pdf

# Load packages
library(lme4)
library(ggplot2)
library(lattice)

# Sleepstudy data contains  the average reaction time per day for subjects in a sleep deprivation study
# On day 0 the subjects had their normal amount of sleep. 
# Starting that night they were restricted to 3 hours of sleep per night
str(sleepstudy)

# Write to disk for Python analysis
write.csv(sleepstudy, file = "sleepstudy.csv", row.names = FALSE)

# ggplot
sleep_ggplot <- ggplot(sleepstudy) +  
  aes(x = Days, y = Reaction) + 
  geom_point(alpha = 0.5) + 
  facet_wrap(~ Subject, nrow = 3) + 
  geom_smooth(method = "lm", se = FALSE)
sleep_ggplot

# lattice
sleep_lattice <- xyplot(Reaction ~ Days | Subject, data = sleepstudy, type = c("p", "r"))
sleep_lattice

# Each subject’s reaction time increases approximately linearly with the number of sleepdeprived days. 
# Subjects also appear to vary in the slopes and intercepts of these relationships, 
# which suggests a model with random slopes and intercepts.

lmer1 <- lmer(Reaction ~ Days + (1 | Subject), sleepstudy)
summary(lmer1)

lmer2 <- lmer(Reaction ~ Days + (Days | Subject), sleepstudy)
summary(lmer2)

# lmer2, odel with random slopes, has lowest AIC
anova(lmer1, lmer2)

# Estimates of the standard deviations of the random effects for the intercept and the slope
# are 24.74 ms and 5.92 ms/day.
lmer2

# The fixed-effects coefficients are 251.4 ms and 10.47 ms/day
# for the intercept and slope.

lmer_plot <- function(data, model) {
  ggplot(data) + 
    aes(x = Days, y = Reaction) +
    facet_wrap(~ Subject, nrow = 3) +   
    geom_point(alpha = 0.5) +
    geom_line(data = cbind(data, pred = predict(model)), aes(y = pred), size = 0.5)  
}

lmer_plot(sleepstudy, lmer1)
lmer_plot(sleepstudy, lmer2)

# Use re.form = NA to not include random effects in the prediciton
lmer_plot_2 <- function(data, model) {
  ggplot(data) + 
    aes(x = Days, y = Reaction) +   
    geom_point(alpha = 0.5, aes(color = Subject)) +
    geom_line(data = cbind(data, pred = predict(model, re.form = NA)), aes(y = pred), size = 1.0) +
    geom_line(data = cbind(data, pred = predict(model)), aes(y = pred, color = Subject), size = 0.3) + 
    theme(legend.position="bottom") + 
    guides(color = guide_legend(nrow = 3))
}

lmer_plot_2(sleepstudy, lmer1)
lmer_plot_2(sleepstudy, lmer2)

# Conditional modes of the random effects
ranef(lmer1)$Subject
ranef(lmer2)$Subject
