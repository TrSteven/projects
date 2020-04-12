import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


# Set style of seaborn plots
sns.set(style="darkgrid")

# Read in the data
gift = pd.read_csv("data/gifts.txt", sep='\t', parse_dates=['date'])
persoons = pd.read_csv("data/donors.txt", sep='\t')

# Left join of the data
df = pd.merge(gift, persoons, how='left', on=['donor_id'])
df['year'] = df['date'].dt.year
df.dtypes

# Aggregate by year and campaign, and make line plot
groupby_year_campaign = df.groupby(['year','campaign'])
sum_year_campaign = groupby_year_campaign[['amount']].sum().reset_index()
plot1 = sns.pointplot(x='year', y='amount', hue='campaign',
                      data=sum_year_campaign)
plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)

# Aggregate by gender and campaign, and make bar plot
groupby_gender_campaign = df.groupby(['gender','campaign'])
sum_gender_campaign = groupby_gender_campaign[['amount']].sum().reset_index()
plot2 = sns.catplot(x='campaign', y='amount', hue='gender',
                       data=sum_gender_campaign, kind='bar', height=4, aspect=2)
plot2.set_xticklabels(rotation=45)
sum_gender_campaign

plt.show()
