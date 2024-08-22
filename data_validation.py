import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
import datetime as dt
from scipy import stats

# Suppress warnings for cleaner output
warnings.filterwarnings('ignore')

# Load the dataset
procsd_data = pd.read_csv('processed_data.csv')

# Check for missing values and raise an error if any are found
missing_values = procsd_data.isnull().sum()
print("Missing Values:\n", missing_values)

if missing_values.any():
    raise ValueError("Data contains missing values. Please address them.")
else:
    print("Data does not contain missing values.")

# Convert '-' to NaN, then replace NaN with 0 for numerical operations
procsd_data['TotalAmount'] = pd.to_numeric(procsd_data['TotalAmount'], errors='coerce').fillna(0)
procsd_data['Quantity'] = pd.to_numeric(procsd_data['Quantity'], errors='coerce').fillna(0)
procsd_data['PricePerUnit'] = pd.to_numeric(procsd_data['PricePerUnit'], errors='coerce').fillna(0)

# Validate that TotalAmount is correctly calculated as Quantity * PricePerUnit
procsd_data['CalculatedTotalAmount'] = procsd_data['Quantity'] * procsd_data['PricePerUnit']
if not (procsd_data['TotalAmount'] == procsd_data['CalculatedTotalAmount']).all():
    raise AssertionError("TotalAmount mismatch found!")

# Visualize outliers in TotalAmount using a boxplot
sns.boxplot(x=procsd_data['TotalAmount'])
plt.title('Boxplot of TotalAmount')
plt.savefig('boxplot.png')  # Save the plot for further analysis
plt.show()

# Identify outliers using z-scores (values more than 3 standard deviations from the mean)
z_scores = np.abs(stats.zscore(procsd_data[['Quantity', 'PricePerUnit', 'TotalAmount']].astype(float)))
outliers = (z_scores > 3).any(axis=1)
print("Number of outliers detected:", outliers.sum())

# Ensure all numerical values are non-negative
assert (procsd_data['Quantity'] >= 0).all(), "Negative quantities found!"
assert (procsd_data['PricePerUnit'] >= 0).all(), "Negative prices found!"
assert (procsd_data['TotalAmount'] >= 0).all(), "Negative TotalAmount values found!"

# Optional: Drop the 'CalculatedTotalAmount' column as it's no longer needed
procsd_data.drop(columns=['CalculatedTotalAmount'], inplace=True)

print("Data validation and processing complete.")
