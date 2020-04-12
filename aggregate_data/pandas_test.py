import pandas as pd
import numpy as np

# New window for plotting: 'auto' instead of 'inline'
# from IPython import get_ipython
# get_ipython().run_line_magic('matplotlib', 'auto')

# Create data set (convert age to int later)
data = {'Gender': ['M', 'F', 'F', 'F', 'M', 'M', 'M'],
        'Country': ['Be', 'UK', 'US', 'US', 'UK', 'UK', 'US'],
        'Age': ["25", "59", "36", "26", "21", "39", "56"],
        'Length': [188.7, 156.3, 142.1, 190.2, 180, 156.3, 177.7],
        'Weight': [74, 72, 69, 60, 92, 89, 70]}

# Create pandas dataframe
df = pd.DataFrame(data)
df.describe(include = 'all')
df.describe(include=[np.number])
df.assign(Age = lambda x: x.Age.astype(int)).describe(include=[np.number])
df.describe(exclude=[np.number])
print(df)

# Pivot table
pivot_table = df.pivot_table(index='Gender', columns='Country', aggfunc='mean', values='Length')
ax = pivot_table.plot.bar(stacked=False)
ax.set_ylabel("Mean length (cm)")

# Map BMI to category
def map_BMI(x):
    y = x.copy(deep = True)
    y[x < 18.5] = "Underweight"
    y[(x > 18.5) & (x < 25)] = "Normal"
    y[x > 25] = "Overweight"
    return y
 
# custom aggregate function
def my_mean(x):
    return x.sum() / x.size

# \ is a line continuation character
df_agg = df.assign(Length_in_meter = lambda x: x.Length/100) \
           .assign(BMI = lambda x: x.Weight / (x.Length_in_meter**2)) \
           .assign(BMI = lambda x: round(x.BMI, 2)) \
           .assign(Category = lambda x: map_BMI(x.BMI)) \
           .assign(Age = lambda x: x.Age.astype(int)) \
           .replace({'Gender': {"M": "Male", "F": "Female"}}) \
           .query("Category != 'Underweight'") \
           .groupby(['Gender', 'Category'], as_index = True) \
           .agg({'Age': ['mean', my_mean, 'min', 'max', 'count'],
                 'BMI': ['mean']})

df_agg
df_agg.plot.bar(rot = 0)
df_agg = df_agg.reset_index()
df_agg
df_agg.plot.bar(rot = 0)

# https://stackoverflow.com/questions/14507794/pandas-how-to-flatten-a-hierarchical-index-in-columns
df_agg.columns = ['_'.join(col).rstrip('_') for col in df_agg.columns.values]
df_agg
df_agg.plot.bar(rot = 0, subplots = True)
