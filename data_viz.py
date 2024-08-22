import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import pearsonr, spearmanr

# Load the preprocessed data
procsd_data = pd.read_csv('processed_data.csv')

# Set up the visual style
sns.set(style="whitegrid")

# Convert '-' to NaN and then to 0 for summation
procsd_data['TotalAmount'] = pd.to_numeric(procsd_data['TotalAmount'], errors='coerce').fillna(0)
procsd_data['Quantity'] = pd.to_numeric(procsd_data['Quantity'], errors='coerce').fillna(0)
procsd_data['PricePerUnit'] = pd.to_numeric(procsd_data['PricePerUnit'], errors='coerce').fillna(0)

# 1. Line Chart: Sales Over Time
plt.figure(figsize=(10, 6))
procsd_data['TransactionDate'] = pd.to_datetime(procsd_data['TransactionDate'])
daily_sales = procsd_data.groupby('TransactionDate')['TotalAmount'].sum()
plt.plot(daily_sales.index, daily_sales.values, marker='o')
plt.title('Total Sales Over Time')
plt.xlabel('Date')
plt.ylabel('Total Sales Amount')
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig('total_sales_over_time.png')
plt.show()

# 2. Bar Chart: Category-Wise Sales
plt.figure(figsize=(10, 6))
category_sales = procsd_data.groupby('ProductCategory')['TotalAmount'].sum().sort_values()
category_sales.plot(kind='barh', color='teal')
plt.title('Total Sales by Product Category')
plt.xlabel('Total Sales Amount')
plt.ylabel('Product Category')
plt.tight_layout()
plt.savefig('sales_by_category.png')
plt.show()

# 3. Scatter Plot: Price vs. Quantity Sold
plt.figure(figsize=(8, 6))
plt.scatter(procsd_data['PricePerUnit'], procsd_data['Quantity'], alpha=0.7, color='purple')
plt.title('Price vs. Quantity Sold')
plt.xlabel('Price Per Unit')
plt.ylabel('Quantity Sold')
plt.tight_layout()
plt.savefig('price_vs_quantity.png')
plt.show()

# 4. Box Plot: Distribution of Sales by Product Category
plt.figure(figsize=(10, 6))
sns.boxplot(x='ProductCategory', y='TotalAmount', data=procsd_data)
plt.title('Distribution of Sales by Product Category')
plt.xlabel('Product Category')
plt.ylabel('Total Amount')
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig('sales_distribution_by_category.png')
plt.show()

# 5. Heatmap: Correlation Matrix
plt.figure(figsize=(10, 6))
corr_matrix = procsd_data[['Quantity', 'PricePerUnit', 'TotalAmount', 'DiscountApplied', 'TrustPointsUsed']].corr()
sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', fmt='.2f')
plt.title('Correlation Matrix of Numerical Variables')
plt.tight_layout()
plt.savefig('correlation_matrix.png')
plt.show()

# 6. Histogram: Sales Distribution
plt.figure(figsize=(10, 6))
sns.histplot(procsd_data['TotalAmount'], bins=20, kde=True, color='skyblue')
plt.title('Distribution of Total Sales Amount')
plt.xlabel('Total Amount')
plt.ylabel('Frequency')
plt.tight_layout()
plt.savefig('sales_distribution.png')
plt.show()

# 7. Checking Linearity: Price vs. TotalAmount
plt.figure(figsize=(8, 6))
plt.scatter(procsd_data['PricePerUnit'], procsd_data['TotalAmount'], alpha=0.7, color='darkorange')
plt.title('Price vs. Total Amount')
plt.xlabel('Price Per Unit')
plt.ylabel('Total Amount')
plt.tight_layout()
plt.savefig('price_vs_total_amount.png')
plt.show()

# Correlation coefficients for linearity
pearson_corr, _ = pearsonr(procsd_data['PricePerUnit'], procsd_data['TotalAmount'])
spearman_corr, _ = spearmanr(procsd_data['PricePerUnit'], procsd_data['TotalAmount'])
print(f"Pearson Correlation between PricePerUnit and TotalAmount: {pearson_corr:.2f}")
print(f"Spearman Correlation between PricePerUnit and TotalAmount: {spearman_corr:.2f}")
