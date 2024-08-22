import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
import datetime as dt

# Suppress warnings for cleaner output
warnings.filterwarnings('ignore')

# Load the dataset
procsd_data = pd.read_csv('processed_data.csv')

# Convert '-' to NaN and then to 0 for summation
procsd_data['TotalAmount'] = pd.to_numeric(procsd_data['TotalAmount'], errors='coerce').fillna(0)
procsd_data['Quantity'] = pd.to_numeric(procsd_data['Quantity'], errors='coerce').fillna(0)

# Group by ProductCategory and aggregate multiple columns
category_aggregation = procsd_data.groupby('ProductCategory').agg({
    'TransactionID': 'count',         # Number of transactions
    'Quantity': 'sum',                # Total quantity sold
    'TotalAmount': 'sum',             # Total sales amount
    'DiscountApplied': 'mean',         # Avg discounts given
    'TrustPointsUsed': 'sum'          # Total trust points used
}).reset_index()

print('category_aggregation:', category_aggregation)

# Group by CustomerID to analyze customer-specific metrics
customer_aggregation = procsd_data.groupby('CustomerID').agg({
    'TransactionID': 'count',         # Number of transactions per customer
    'TotalAmount': ['sum', 'mean'],   # Total and average spending per customer
    'TrustPointsUsed': 'sum',         # Total trust points used by customer
}).reset_index()

print('customer_aggregation:', customer_aggregation)

# Group by TransactionDate for time-series analysis
date_aggregation = procsd_data.groupby('TransactionDate').agg({
    'TransactionID': 'count',         # Number of transactions per day
    'TotalAmount': 'sum',             # Total sales amount per day
}).reset_index()

print('date_aggregation:', date_aggregation)
