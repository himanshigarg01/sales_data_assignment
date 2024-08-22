import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
import datetime as dt

# Suppress warnings for cleaner output
warnings.filterwarnings('ignore')

# Load the dataset
data = pd.read_csv('Data Source (sales_transactions).csv')

# Display initial information about the dataset
print(data.head())
print(data.info())
print(data.describe())

# Check for missing values
print("Missing values per column:\n", data.isnull().sum())

# Drop rows where 'TransactionID' or 'ProductID' are missing (essential data)
data.dropna(subset=['TransactionID', 'ProductID'], inplace=True)

# Correct negative values in 'Quantity', 'PricePerUnit', and 'TotalAmount' columns
data['Quantity'] = data['Quantity'].abs()
data['PricePerUnit'] = data['PricePerUnit'].abs()
data['TotalAmount'] = data['TotalAmount'].abs()

# Fill missing 'CustomerID' with a placeholder if the record is still valuable
data['CustomerID'].fillna('Unknown', inplace=True)

# Forward fill missing 'TransactionDate'
data['TransactionDate'].fillna(method='ffill', inplace=True)

# Calculate 'TotalAmount' if 'Quantity' and 'PricePerUnit' are available, else fill with '-'
data['TotalAmount'] = data.apply(
    lambda row: row['Quantity'] * row['PricePerUnit'] if pd.notnull(row['Quantity']) and pd.notnull(row['PricePerUnit']) else '-',
    axis=1
)

# Replace missing values in 'PricePerUnit', 'Quantity', and 'DiscountApplied' with placeholders
data['PricePerUnit'].fillna('-', inplace=True)
data['Quantity'].fillna('-', inplace=True)
data['DiscountApplied'].fillna('0', inplace=True)

# Fill missing 'PaymentMethod' with 'Unknown'
data['PaymentMethod'].fillna('Unknown', inplace=True)

# Split 'TransactionDate' into 'TransactionDate' and 'TransactionTime'
data['TransactionTime'] = data['TransactionDate'].str.split(' ', expand=True)[1]

# Convert 'TransactionTime' to proper 24-hour format (HH:MM:SS)
data['TransactionTime'] = pd.to_datetime(data['TransactionTime'], format='%H:%M').dt.time

# Extract date portion and format as YYYY-MM-DD
data['TransactionDate'] = data['TransactionDate'].str.split(' ', expand=True)[0]
data['TransactionDate'] = pd.to_datetime(data['TransactionDate'], format='%d/%m/%y').dt.strftime('%Y-%m-%d')

# Drop duplicate rows
data.drop_duplicates(inplace=True)

# Identify and remove outliers in 'TotalAmount' using IQR
Q1 = data['TotalAmount'].quantile(0.25)
Q3 = data['TotalAmount'].quantile(0.75)
IQR = Q3 - Q1
data = data[~((data['TotalAmount'] < (Q1 - 1.5 * IQR)) | (data['TotalAmount'] > (Q3 + 1.5 * IQR)))]

# Display final information about the cleaned dataset
print(data.info())
print(data.describe())

# Save the preprocessed data to a new CSV file
data.to_csv('processed_data.csv', index=False)

# Print the final cleaned data
print(data)