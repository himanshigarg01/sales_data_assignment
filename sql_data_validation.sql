-- Use the target schema
USE yuma_assignment;

-- Step 1: Check for Missing Values
-- This query identifies columns with missing values in the processed_sales_data table
SELECT 
    SUM(CASE WHEN TransactionID IS NULL THEN 1 ELSE 0 END) AS MissingTransactionID,
    SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END) AS MissingProductID,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS MissingQuantity,
    SUM(CASE WHEN PricePerUnit IS NULL THEN 1 ELSE 0 END) AS MissingPricePerUnit,
    SUM(CASE WHEN TotalAmount IS NULL THEN 1 ELSE 0 END) AS MissingTotalAmount,
    SUM(CASE WHEN TrustPointsUsed IS NULL THEN 1 ELSE 0 END) AS MissingTrustPointsUsed,
    SUM(CASE WHEN PaymentMethod IS NULL THEN 1 ELSE 0 END) AS MissingPaymentMethod
FROM processed_sales_data;

-- Step 2: Check for Consistency of Date Formats
-- This query identifies rows with incorrect date formats in the TransactionDate column
SELECT 
    TransactionDate
FROM processed_sales_data
WHERE TransactionDate NOT LIKE '____-__-__';

-- Step 3: Validate Aggregation with Original Data Counts
-- Compare the number of records in the original and processed data
SELECT COUNT(*) AS OriginalCount FROM original_sales_data;
SELECT COUNT(*) AS ProcessedCount FROM processed_sales_data;

-- Step 4: Verify Calculated Columns (TotalAmount)
-- Ensure that TotalAmount matches the expected value based on Quantity and PricePerUnit
SELECT 
    TransactionID,
    Quantity,
    PricePerUnit,
    TotalAmount,
    CASE 
        WHEN TotalAmount IS NULL AND Quantity IS NOT NULL AND PricePerUnit IS NOT NULL 
        THEN Quantity * PricePerUnit 
        ELSE TotalAmount 
    END AS CalculatedTotalAmount
FROM processed_sales_data;

-- Step 5: Check for Duplicate Records
-- This query checks for duplicate TransactionID and compares total records with unique records
SELECT 
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT TransactionID) AS UniqueRecords
FROM processed_sales_data;

-- Step 6: Outlier Detection in 'TotalAmount' using IQR
-- Step 1: Create a temporary table with ordered data and row numbers
CREATE TEMPORARY TABLE ordered_data AS
SELECT 
    TransactionID,
    TotalAmount,
    @rownum := @rownum + 1 AS rownum,
    @total_rows := (SELECT COUNT(*) FROM processed_sales_data) AS total_rows
FROM 
    processed_sales_data,
    (SELECT @rownum := 0) AS vars
ORDER BY TotalAmount;

-- Step 2: Calculate Q1 and Q3
SET @Q1_rownum = ROUND(0.25 * @total_rows);
SET @Q3_rownum = ROUND(0.75 * @total_rows);

-- Retrieve Q1 and Q3 values
SELECT 
    MIN(CASE WHEN rownum = @Q1_rownum THEN TotalAmount END) INTO @Q1
FROM ordered_data;

SELECT 
    MIN(CASE WHEN rownum = @Q3_rownum THEN TotalAmount END) INTO @Q3
FROM ordered_data;

-- Calculate IQR
SET @IQR = @Q3 - @Q1;

-- Step 3: Remove outliers based on the IQR
DELETE FROM processed_sales_data
WHERE TotalAmount < (@Q1 - 1.5 * @IQR)
   OR TotalAmount > (@Q3 + 1.5 * @IQR);

-- Clean up temporary table
DROP TEMPORARY TABLE ordered_data;

-- Verify outliers removal (optional)
SELECT COUNT(*) AS RemainingRecords FROM processed_sales_data;
