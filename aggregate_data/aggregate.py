import pandas as pd

# New window for plotting: 'auto' instead of 'inline'
from IPython import get_ipython
get_ipython().run_line_magic('matplotlib', 'auto')

# Sourc: https://jamesrledoux.com/code/group-by-aggregate-pandas
data = {"Team": ["Red Sox", "Red Sox", "Red Sox", "Red Sox", "Red Sox", "Red Sox", "Yankees", "Yankees", "Yankees", "Yankees", "Yankees", "Yankees"],
		"Pos": ["Pitcher", "Pitcher", "Pitcher", "Not Pitcher", "Not Pitcher", "Not Pitcher", "Pitcher", "Pitcher", "Pitcher", "Not Pitcher", "Not Pitcher", "Not Pitcher"],
		"Age": [24, 28, 40, 22, 29, 33, 31, 26, 21, 36, 25, 31]}
df = pd.DataFrame(data)
print(df)

# custom aggregate function
def my_mean(x):
    return x.sum() / x.size

#####################
# group by 1 column #
#####################
    
# group by Team, get mean, min, and max value of Age for each value of Team.
grouped_single = df.groupby('Team').agg({'Age': ['mean', my_mean, 'min', 'max']})
print(grouped_single)
grouped_single.plot.bar(rot = 0, subplots = True)

# remove multi index
grouped_single.columns = ['age_mean', 'age_my_mean', 'age_min', 'age_max']
print(grouped_single)

# reset index to get grouped columns back
grouped_single = grouped_single.reset_index()
print(grouped_single)

#############################
# group by multiple columns #
#############################
grouped_multiple = df.groupby(['Team', 'Pos']).agg({'Age': ['mean', my_mean, 'min', 'max']})
print(grouped_multiple)
grouped_multiple.plot.bar(rot = 0, subplots = True)
 
# remove multi index
grouped_multiple.columns = ['age_mean', 'age_my_mean', 'age_min', 'age_max']
print(grouped_multiple)

# reset index to get grouped columns back
grouped_multiple = grouped_multiple.reset_index()
print(grouped_multiple)

