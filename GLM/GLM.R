# Interpretation of linear, logistic and Poisson regression
# Dataset: http://users.stat.ufl.edu/~aa/cda/data/Crabs.dat
# Agresti - An Introduction to Categorical Data Analysis (Third Edition)
# Section 3.3.3

# color = color (1, medium light; 2, medium; 3, medium dark; 4, dark)
# spine = spine condition (1, both good; 2, one broken; 3, both broken)
# width = shell width (cm)
# weight = weight (kg)
# sat = number of satellites
df <- read.table("crabs.txt", sep = "", header = TRUE)
df$color <- factor(df$color, levels = 1:4,
                   labels = c("Medium Light", "Medium", "Medium Dark", "Dark"))
df$spine <- factor(df$spine, levels = 1:3,
                   labels = c("Both Good", "One Broken", "Both Broken"))
df$y <- factor(df$y, levels = 0:1, labels = c("No", "Yes"))
df$crab <- NULL

#####################
# Linear regression #
#####################
lin_reg <- lm(sat ~ width + weight + color + spine, data = df)
summary(lin_reg)
coef(lin_reg)

# A unit increase of the width is associated with an increase of 0.023 in the number of satellites

# Crabs with a medium color are associated with a decrease of 0.70 in the number of satellites 
# compared to crabs with a medium light color

#######################
# Logistic regression #
#######################
log_reg <- glm(y ~ width + weight + color + spine, family = binomial(link='logit'), data = df)
summary(log_reg)
coef(log_reg)

# A unit increase in the weight increases the odds (that female crabs atleast have one satellite) 
# multiplicatively by exp(0.83) = 2.29
# Or: increases the odds with (2.29 - 1) * 100% = 129%

# The estimated odds (that female crabs atleast have one satellite) is exp(-0.103) = 0.90 times lower 
# (or (0.90 - 1) * 100 % = 10 % lower)
# for crabs with a medium color compared to crabs with a medium light color

# Also, see Agresti - An Introduction to Categorical Data Analysis (Third Edition)
# Section 4.1.3 (only one predictor)
coef(glm(y ~ width, family = binomial(link='logit'), data = df))
# Since B = 0.497, the estimated odds of a satellite multiply by exp(B) = exp(0.497) =
# 1.64 for each 1-cm increase in width; that is, there is a 64% increase.

######################
# Poisson regression #
######################
pos_reg <- glm(sat ~ width + weight + color + spine, family=poisson(link=log), data=df)
summary(pos_reg)
coef(pos_reg)

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
coef(glm(sat ~ width, family=poisson(link=log), data=df))
# For this model, exp(B) = exp(0.164) = 1.178 represents the multiplicative effect on the
# fitted value for each 1-cm increase in x ... A 1-cm increase in the
# shell width has an 17.8% increase in the estimated mean number of satellites.
