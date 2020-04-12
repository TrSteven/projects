import pandas as pd
from matplotlib import pyplot as plt
import statsmodels.api as sm
import calendar
import datetime
import seaborn as sns


amtrak = pd.read_csv('amtrak_data.csv')

# https://docs.python.org/3/library/datetime.html#strftime-and-strptime-behavior
amtrak = amtrak.rename(columns = {'Month': 'Date_string'})
amtrak['Date'] = pd.to_datetime(amtrak['Date_string'], format = '%b-%y') 
amtrak.dtypes
amtrak.set_index('Date', inplace=True)
amtrak['Year'] = amtrak.index.year
amtrak['Month'] = amtrak.index.month
amtrak['Month_name'] = amtrak['Month'].apply(lambda x: calendar.month_abbr[x])

# Plot time series
plt.plot(amtrak['Ridership'])
amtrak['Ridership'].plot()
plt.plot(amtrak.index, amtrak['Ridership'])

# Plot yearly
amtrak_year = amtrak.groupby('Year').sum()
amtrak_year = amtrak_year.query('Year < 2004')
plt.plot(amtrak_year['Ridership'])
plt.plot(amtrak_year.index, amtrak_year['Ridership'])

# Plot monthly
amtrak_month = amtrak.groupby('Month').sum()
plt.plot(amtrak_month['Ridership'])
amtrak_month['Month_name'] = amtrak_month.index.to_series().apply(lambda x: calendar.month_abbr[x])
plt.plot(amtrak_month['Month_name'], amtrak_month['Ridership'])

amtrak.boxplot(column=['Ridership'], by='Month')
amtrak.boxplot(column=['Ridership'], by='Month_name')
sns.boxplot(y='Ridership', x='Month_name', data=amtrak)

# ACF
sm.graphics.tsa.plot_acf(amtrak['Ridership'].values, lags=20)
sm.graphics.tsa.plot_acf(amtrak['Ridership'].diff(periods=1).dropna().values, lags=20)
sm.graphics.tsa.plot_acf(amtrak['Ridership'].diff(periods=1).diff(periods=12).dropna().values, lags=20)

# PACF
sm.graphics.tsa.plot_pacf(amtrak['Ridership'].values, lags=20)
sm.graphics.tsa.plot_pacf(amtrak['Ridership'].diff(periods=1).dropna().values, lags=20)
sm.graphics.tsa.plot_pacf(amtrak['Ridership'].diff(periods=1).diff(periods=12).dropna().values, lags=20)

###############
# ARIMA model #
###############
n_valid = 36
n_train = len(amtrak.index) - n_valid
amtrak = amtrak.sort_index(ascending = True)
amtrak_train = amtrak[0:n_train]
amtrak_valid = amtrak[n_train:]
amtrak.index.freq = "MS"

sarima_mod = sm.tsa.statespace.SARIMAX(amtrak_train['Ridership'], 
                                       order=(1,1,1),  
                                       seasonal_order=(0,1,1,12), 
                                       freq = "MS")
sarima_fit = sarima_mod.fit()
sarima_fit.summary()

# Construct the forecasts
sarima_pred = sarima_fit.get_prediction().summary_frame(alpha=0.10)
sarima_fc = sarima_fit.get_forecast(steps=36).summary_frame(alpha=0.10)
sarima_combined = sarima_pred.append(sarima_fc)

# Plot the forecasts
fig, ax = plt.subplots(figsize=(15, 5))   
sarima_combined['mean'].plot(ax=ax, color='blue')
amtrak['Ridership'].plot(ax=ax, style='k--')
ax.fill_between(sarima_fc.index, 
                sarima_fc['mean_ci_lower'], sarima_fc['mean_ci_upper'], 
                color='green', alpha=0.5);
ax.set_xlim([datetime.date(2000, 1, 1), datetime.date(2004, 2, 1)])    
ax.set_ylim([1000, 2700]) 