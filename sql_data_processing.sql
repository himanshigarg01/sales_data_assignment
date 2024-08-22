use yuma_assignment;
-- Step 1: Create a cleaned table by removing rows with missing 'TransactionID' or 'ProductID'
CREATE TABLE cleaned_sales_data AS
SELECT * 
FROM original_sales_data
WHERE TransactionID IS NOT NULL 
  AND ProductID IS NOT NULL;

-- Step 2: Correct negative values in 'Quantity', 'PricePerUnit', and 'TotalAmount' columns
UPDATE cleaned_sales_data
SET 
    Quantity = ABS(Quantity),
    PricePerUnit = ABS(PricePerUnit),
    TotalAmount = ABS(TotalAmount);

-- Step 3: Fill missing 'CustomerID' with 'Unknown'
UPDATE cleaned_sales_data
SET CustomerID = 'Unknown'
WHERE CustomerID IS NULL;

-- Step 4: Forward fill missing 'TransactionDate' using a temporary table
CREATE TEMPORARY TABLE Temp_FilledDates AS
SELECT 
    TransactionID, 
    COALESCE(TransactionDate, LAG(TransactionDate) OVER (ORDER BY TransactionID)) AS FilledTransactionDate
FROM cleaned_sales_data;

UPDATE cleaned_sales_data
JOIN Temp_FilledDates 
    ON cleaned_sales_data.TransactionID = Temp_FilledDates.TransactionID
SET cleaned_sales_data.TransactionDate = Temp_FilledDates.FilledTransactionDate;

DROP TABLE Temp_FilledDates;

-- Step 5: Calculate 'TotalAmount' if 'Quantity' and 'PricePerUnit' are available
UPDATE cleaned_sales_data
SET TotalAmount = 
    CASE 
        WHEN TotalAmount IS NULL 
             AND Quantity IS NOT NULL 
             AND PricePerUnit IS NOT NULL 
        THEN Quantity * PricePerUnit 
        ELSE TotalAmount 
    END;

-- Step 6: Replace missing values in 'PricePerUnit', 'Quantity', and 'DiscountApplied' with placeholders
UPDATE cleaned_sales_data
SET 
    PricePerUnit = COALESCE(PricePerUnit, 0),
    Quantity = COALESCE(Quantity, 0),
    DiscountApplied = COALESCE(DiscountApplied, 0);

-- Step 7: Fill missing 'PaymentMethod' with 'Unknown'
UPDATE cleaned_sales_data
SET PaymentMethod = 'Unknown'
WHERE PaymentMethod IS NULL;

-- Step 8: Split 'TransactionDate' into 'TransactionDate' and 'TransactionTime'
ALTER TABLE cleaned_sales_data 
ADD COLUMN TransactionTime TIME;

UPDATE cleaned_sales_data
SET 
    TransactionTime = STR_TO_DATE(SUBSTRING_INDEX(TransactionDate, ' ', -1), '%H:%i:%s'),
    TransactionDate = STR_TO_DATE(SUBSTRING_INDEX(TransactionDate, ' ', 1), '%d/%m/%y');

-- Step 9: Create a temporary table to retain unique rows
CREATE TEMPORARY TABLE temp_unique_sales_data AS
SELECT * 
FROM cleaned_sales_data
WHERE TransactionID IN (
    SELECT MIN(TransactionID)
    FROM cleaned_sales_data
    GROUP BY 
        CustomerID, 
        TransactionDate, 
        ProductID, 
        ProductCategory, 
        Quantity, 
        PricePerUnit, 
        TotalAmount, 
        TrustPointsUsed, 
        PaymentMethod, 
        DiscountApplied
);

-- Step 10: Replace original table with unique rows
TRUNCATE TABLE cleaned_sales_data;

INSERT INTO cleaned_sales_data
SELECT * FROM temp_unique_sales_data;

-- Step 11: Drop the temporary table
DROP TEMPORARY TABLE temp_unique_sales_data;

-- Step 12: Identify and remove outliers in 'TotalAmount' using IQR
-- Create a temporary table with ordered data and row numbers
CREATE TEMPORARY TABLE ordered_data AS
SELECT 
    TransactionID,
    TotalAmount,
    @rownum := @rownum + 1 AS rownum,
    @total_rows := (SELECT COUNT(*) FROM cleaned_sales_data) AS total_rows
FROM 
    cleaned_sales_data,
    (SELECT @rownum := 0) AS vars
ORDER BY TotalAmount;

-- Calculate Q1 and Q3 approximations
SET @Q1_rownum = ROUND(0.25 * @total_rows);
SET @Q3_rownum = ROUND(0.75 * @total_rows);

-- Retrieve Q1 and Q3 values (ensure only one row is returned)
SELECT 
    MIN(CASE WHEN rownum = @Q1_rownum THEN TotalAmount END) INTO @Q1
FROM ordered_data;

SELECT 
    MIN(CASE WHEN rownum = @Q3_rownum THEN TotalAmount END) INTO @Q3
FROM ordered_data;

SET @IQR = @Q3 - @Q1;

-- Remove outliers based on IQR
DELETE FROM cleaned_sales_data
WHERE TotalAmount < (@Q1 - 1.5 * @IQR)
   OR TotalAmount > (@Q3 + 1.5 * @IQR);

-- Drop the temporary table
DROP TEMPORARY TABLE ordered_data;

-- Step 13: Final check on the cleaned data
SELECT * FROM cleaned_sales_data;

-- Optionally: Save the cleaned data into a new table for future use
CREATE TABLE processed_sales_data AS
SELECT * FROM cleaned_sales_data;
