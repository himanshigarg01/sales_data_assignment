-- Use the target schema
USE yuma_assignment;

-- Step 1: Aggregate Sales Data Over Time
-- Aggregating total sales by day
SELECT 
    TransactionDate,
    SUM(TotalAmount) AS TotalSales
FROM processed_sales_data
GROUP BY TransactionDate
ORDER BY TransactionDate;

-- Step 2: Aggregate Sales Data by Product Category
-- Aggregating total sales and quantity sold by product category
SELECT 
    ProductCategory,
    SUM(TotalAmount) AS TotalSales,
    SUM(Quantity) AS TotalQuantitySold
FROM processed_sales_data
GROUP BY ProductCategory;

-- Step 3: Aggregate Sales Data by Customer
-- Aggregating total and average spending by customer
SELECT 
    CustomerID,
    SUM(TotalAmount) AS TotalSpending,
    AVG(TotalAmount) AS AverageSpending
FROM processed_sales_data
GROUP BY CustomerID;

-- Step 4: Aggregate Sales Data by Week
-- Aggregating total sales by week (assuming 'TransactionDate' is in 'YYYY-MM-DD' format)
SELECT 
    YEAR(TransactionDate) AS Year,
    WEEK(TransactionDate) AS Week,
    SUM(TotalAmount) AS TotalSales
FROM processed_sales_data
GROUP BY YEAR(TransactionDate), WEEK(TransactionDate)
ORDER BY Year, Week;

-- Step 5: Correlation between TotalAmount and Quantity
-- This helps in understanding linear relationships
SELECT 
    CORR(TotalAmount, Quantity) AS Correlation
FROM processed_sales_data;
