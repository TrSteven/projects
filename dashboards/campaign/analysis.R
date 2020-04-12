library(tidyverse)
library(lubridate)
library(plotly)
theme_set(theme_classic())


# Read in the data, and merge
gifts <- read_tsv("gifts.txt")
gifts$date <- as.Date(gifts$date, format = "%d/%m/%Y")
time_interval <- "year"
gifts$rounded_date <- as.Date(cut(gifts$date, breaks = time_interval))
gifts$campaign <- factor(gifts$campaign, levels=paste("campaign", 1:12), ordered=TRUE)

donors <- read_tsv("donors.txt")

merged_data <- left_join(gifts, donors, by = "donor_id")

# Evolution of total of donations per campaign and per year
aggr_date_campaign <- gifts %>%
  group_by(rounded_date, campaign) %>%
  summarise(total_amount = sum(amount))

plot_aggr_date_campaign <- ggplot(data = aggr_date_campaign) +
  aes(x = rounded_date, y = total_amount, colour = campaign, group = campaign,
      text = paste('Total amount: ', total_amount, 
                   '<br>Date: ', as.Date(rounded_date),
                   '<br>Campaign: ', campaign)) +
  geom_line() + geom_point() + xlab("Date") + ylab("Total amount")

plot_aggr_date_campaign

# Evolution of the average amount per donation
plot_date_campaign_smooth <- ggplot(data = gifts) + 
  aes(x = date, y = amount, colour = campaign) + 
  geom_smooth(span = 2, se = FALSE,size = 0.5) + xlab("Date") + ylab("Average amount")

plot_date_campaign_smooth

# Total donations per gender and per campaign
aggr_gen_camp <- merged_data %>% 
  group_by(gender, campaign) %>% 
  summarise(total_amount = sum(amount))

plot_gen_camp <- ggplot(data = aggr_gen_camp) + 
  aes(y = total_amount, x = campaign, fill = gender, text = paste('Total amount: ', total_amount)) + 
  geom_col(position = "dodge") + ylab("Total amount") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

plot_gen_camp

# Top 20 donors
top_20_donors <- gifts %>% 
  group_by(donor_id) %>% 
  summarise(total_amount = sum(amount)) %>%
  arrange(desc(total_amount)) %>% 
  head(20) %>% 
  left_join(donors, by = "donor_id") %>% 
  select(-name)

top_20_donors

# Gender of donors
aggr_gender <- donors %>% group_by(gender) %>% summarise(count = n())

barplot_aggr_gender <- ggplot(data = aggr_gender) +aes(x = gender, y = count) + geom_col(fill = "#7CAE00")
barplot_aggr_gender

# Pie chart
plot_ly(aggr_gender, labels = ~gender, values = ~count, type = 'pie') %>% 
  layout(title = "Donors by Gender",  showlegend = TRUE)


