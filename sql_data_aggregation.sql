-- Use the target schema
USE yuma_assignment;

-- Step 1: Aggregate by ProductCategory
-- This query calculates aggregate metrics for each product category
SELECT 
    ProductCategory,                          -- Product category
    COUNT(TransactionID) AS NumberOfTransactions, -- Total number of transactions per category
    SUM(Quantity) AS TotalQuantitySold,       -- Total quantity of products sold per category
    SUM(TotalAmount) AS TotalSalesAmount,     -- Total sales amount per category
    AVG(DiscountApplied) AS AverageDiscountsGiven, -- Average discount applied per category
    SUM(TrustPointsUsed) AS TotalTrustPointsUsed -- Total trust points used per category
FROM 
    processed_sales_data
GROUP BY 
    ProductCategory
ORDER BY TotalSalesAmount DESC;

-- Step 2: Aggregate by CustomerID
-- This query calculates aggregate metrics for each customer
SELECT 
    CustomerID,                               -- Customer ID
    COUNT(TransactionID) AS NumberOfTransactions, -- Total number of transactions per customer
    SUM(TotalAmount) AS TotalSpending,        -- Total spending per customer
    ROUND(AVG(TotalAmount), 2) AS AverageSpending, -- Average spending per customer
    SUM(TrustPointsUsed) AS TotalTrustPointsUsed -- Total trust points used per customer
FROM 
    processed_sales_data
GROUP BY 
    CustomerID
ORDER BY TotalSpending DESC;

-- Step 3: Aggregate by TransactionDate
-- This query calculates aggregate metrics for each transaction date
SELECT 
    TransactionDate,                         -- Transaction date
    COUNT(TransactionID) AS NumberOfTransactions, -- Total number of transactions per date
    SUM(TotalAmount) AS TotalSalesAmount    -- Total sales amount per date
FROM 
    processed_sales_data
GROUP BY 
    TransactionDate
ORDER BY TotalSalesAmount DESC;
