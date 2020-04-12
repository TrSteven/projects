library(tidyverse)
library(data.table)

################
# One function #
################
data(warpbreaks)

aggr.1.a <- aggregate(breaks ~ wool + tension, 
                      data = warpbreaks, FUN = sum)
aggr.1.a

# Convert to table format
aggr.1.b <- xtabs(breaks ~ wool + tension, data = aggr.1.a)
aggr.1.b

# Convert back to data frame
as.data.frame(aggr.1.b)

# Construct barplot
# Base R
barplot(aggr.1.b, beside=TRUE, legend.text=rownames(aggr.1.b), 
        col=c("beige","orange"), ylab="Total of breaks")

# ggplot2
myplot <- ggplot(aggr.1.a, aes(x=tension, y=breaks, fill=wool)) + 
  geom_bar(stat="identity", position=position_dodge())
myplot

# tidyverse
aggr.2 <- warpbreaks %>% group_by(wool, tension) %>% summarise_at("breaks", sum)

# datatable
dt <- data.table(warpbreaks)
aggr.3 <- dt[, list(breaks = sum(breaks)), by = list(wool, tension)]

######################
# Multiple functions #
######################
n <- 1e3
df_1 <- tibble(col1 = sample(c("a", "b", "c"), n, replace = TRUE),
               col2 = sample(c("a", "b", "c"), n, replace = TRUE),
               col3 = rnorm(n),
               col4 = rnorm(n))

leftconf <- function(a) t.test(a)$conf.int[1]
rightconf <- function(a) t.test(a)$conf.int[2]

aggregate(cbind(col3, col4) ~ col1 + col2, 
          data = df_1, 
          FUN = function(a) c(mean = mean(a), 
                              count = length(a),
                              leftconf = leftconf(a),
                              rightconf = rightconf(a)))

aggregate(list(col3 = df_1$col3, col4 = df_1$col4),
          by = list(df_1$col1, df_1$col2),
          FUN = function(a) c(mean = mean(a), 
                              count = length(a),
                              leftconf = leftconf(a),
                              rightconf = rightconf(a)))

df_1 %>% 
  group_by(col1, col2) %>% 
  summarise_at(vars(col3, col4), 
               list(mean = mean, count = length, leftconf = leftconf, rightconf = rightconf))

############
# Counting #
############
df <- data.frame(x = sample(letters[1:3], 1000, replace = TRUE),
                 y = sample(letters[1:3], 1000, replace = TRUE),
                 z = sample(letters[1:3], 1000, replace = TRUE))

res1 <- with(df, aggregate(list(count = x), by = list(x = x, y = y, z = z), FUN = length))
res2 <- df %>% group_by(x, y, z) %>% summarise(count = n()) # Or: df %>% group_by(x, y, z) %>% tally()
res3 <- with(df, tapply(x, list(x, y, z), FUN = length))
res4 <- with(df, table(x, y, z))

res1
res2
res3
res4

# Convert to table:
xtabs(count ~ x + y + z, data = res1)

