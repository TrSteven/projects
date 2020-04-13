# See: https://s3.amazonaws.com/assets.datacamp.com/production/course_9975/slides/chapter2.pdf

# Load packages
library(lme4)
library(tidyverse)

data(BodyWeight, package = "nlme")
bodyweight <- BodyWeight %>%
  rename(Weight = weight) %>%
  mutate(Diet = paste("Diet", Diet, sep = " "))
rm(BodyWeight)

# Write to disk for Python analysis
write.csv(bodyweight, file = "bodyweight.csv", row.names = FALSE)

str(bodyweight)

# ggplot
bodyweight_ggplot <- ggplot(bodyweight) +  
  aes(x = Time, y = Weight, color = Diet) + 
  geom_point(alpha = 0.5) + 
  facet_wrap(~ Rat) + 
  geom_smooth(method = "lm", se = FALSE)
bodyweight_ggplot

ggplot(bodyweight, aes(x = Time, y = Weight)) + 
  geom_line(method = "lm", aes(group = Rat, color = Diet))

# Random effect models

# Random intercept
lmer_ri <- lmer(Weight ~ 1 + Time + (1 | Rat), data = bodyweight)
summary(lmer_ri)

# Random intercept + slope
lmer_ri_rs <- lmer(Weight ~ 1 + Time + (1 + Time | Rat), data = bodyweight)
summary(lmer_ri_rs)

# Add Diet as fixed effect
lmer_ri_Diet <- lmer(Weight ~ 1 + Time + Diet + (1 | Rat), data = bodyweight)
summary(lmer_ri_Diet)

lmer_ri_rs_Diet <- lmer(Weight ~ 1 + Time + Diet + (1 + Time| Rat), data = bodyweight)
summary(lmer_ri_rs_Diet)

# Interpretation of the fixed slope parameter in model with random slope:
# beta_1 is the slope of the average line: 
# the average change (across all groups) in y for a 1 unit change in x_1
# See: http://www.bristol.ac.uk/cmm/learning/videos/random-slopes.html

# Model with random slope and fixed effect Diet has lowest AIC
anova(lmer_ri, lmer_ri_rs, lmer_ri_Diet, lmer_ri_rs_Diet)


lmer_plot <- function(data, model) {
  ggplot(data, aes(x = Time, y = Weight)) +
    facet_wrap(~ Rat) +   
    geom_point(alpha = 0.5, aes(color = Diet)) +
    geom_line(data = cbind(data, pred = predict(model)), aes(y = pred, color = Diet)) + 
    scale_colour_hue(l = 60, c = 160)
}

lmer_plot(bodyweight, lmer_ri_Diet)
lmer_plot(bodyweight, lmer_ri_rs_Diet)

lmer_plot_2 <- function(data, model) {
  ggplot(data, aes(x = Time, y = Weight)) +
    facet_wrap(~ Diet) +   
    geom_point(alpha = 0.5, aes(color = Rat)) +
    geom_line(data = cbind(data, pred = predict(model, re.form = NA)), aes(y = pred), size = 1.0) + 
    geom_line(data = cbind(data, pred = predict(model)), aes(y = pred, color = Rat), size = 0.3) + 
    scale_colour_hue(l = 60, c = 160) + 
    theme(legend.position="bottom") + 
    guides(color = guide_legend(nrow = 2))
}

lmer_plot_2(bodyweight, lmer_ri_Diet)
lmer_plot_2(bodyweight, lmer_ri_rs_Diet)


