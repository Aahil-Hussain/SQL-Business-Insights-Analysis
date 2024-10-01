
-- 1. Sales & Profit Analysis

--Total Sales and Profit by State:
SELECT top 10
    l.State,
    SUM(f.Sales) AS Total_Sales,
    SUM(f.Profit) AS Total_Profit
FROM 
    fact f
JOIN 
    location l ON f.Area_Code = l.Area_Code
GROUP BY 
    l.State


--Basic Sales and Profit Aggregation

SELECT 
    p.Product,
    SUM(f.Sales) AS Total_Sales,
    SUM(f.Profit) AS Total_Profit,
    AVG(f.Margin) AS Average_Margin
FROM Fact f
JOIN Product p ON f.ProductId = p.ProductId
GROUP BY p.Product

--Market-wise Performance Analysis
SELECT 
    l.Market,
    SUM(f.Sales) AS Total_Sales,
    SUM(f.Profit) AS Total_Profit
FROM Fact f
JOIN Location l ON f.Area_Code = l.Area_Code
GROUP BY l.Market


--Sales and Profit Trends Over Time (Moving Average)
WITH Sales_CTE AS (
    SELECT 
        f.Date,
        p.Product,
        SUM(f.Sales) OVER (ORDER BY f.Date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS Moving_Avg_Sales,
        SUM(f.Profit) OVER (ORDER BY f.Date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS Moving_Avg_Profit
    FROM Fact f
    JOIN Product p ON f.ProductId = p.ProductId
)
SELECT * 
FROM Sales_CTE;


-- Sales by Product Type and Market
SELECT 
    p.Product_Type, 
    l.Market, 
    SUM(f.Sales) AS Total_Sales
FROM Fact f
JOIN Product p ON f.ProductId = p.ProductId
JOIN Location l ON f.Area_Code = l.Area_Code
GROUP BY p.Product_Type, l.Market
ORDER BY Total_Sales DESC


-- 2. Budget vs Actual Analysis

-- Budget vs Actual Profit Analysis:
SELECT 
    l.State,
    SUM(f.Profit) AS Actual_Profit,
    SUM(f.Budget_Profit) AS Budget_Profit,
    (SUM(f.Profit) - SUM(f.Budget_Profit)) AS Profit_Variance
FROM 
    fact f
JOIN 
    location l ON f.Area_Code = l.Area_Code
GROUP BY 
    l.State


-- Analyze the difference between actual and budgeted profit and sales by product.

SELECT 
    p.Product,
    SUM(f.Sales) AS Actual_Sales,
    SUM(f.Budget_Sales) AS Budgeted_Sales,
    SUM(f.Profit) AS Actual_Profit,
    SUM(f.Budget_Profit) AS Budgeted_Profit,
    (SUM(f.Sales) - SUM(f.Budget_Sales)) AS Sales_Variance,
    (SUM(f.Profit) - SUM(f.Budget_Profit)) AS Profit_Variance
FROM Fact f
JOIN Product p ON f.ProductId = p.ProductId
GROUP BY p.Product;

--Performance Against Budget for Sales, Profit, and COGS
--Identify any over-budget expenses or underperformance?
CREATE VIEW Budget_Analysis AS
SELECT 
    p.Product,
    SUM(f.Sales) AS Actual_Sales,
    SUM(f.Budget_Sales) AS Budgeted_Sales,
    SUM(f.Sales) - SUM(f.Budget_Sales) AS Sales_Variance,
    SUM(f.COGS) AS Actual_COGS,
    SUM(f.Budget_COGS) AS Budgeted_COGS,
    SUM(f.COGS) - SUM(f.Budget_COGS) AS COGS_Variance,
	CASE 
        WHEN SUM(f.Sales) < SUM(f.Budget_Sales) THEN 'Underperforming'
        ELSE 'On Target'
    END AS Sales_Performance
FROM Fact f
JOIN Product p ON f.ProductId = p.ProductId
GROUP BY p.Product

select * from Budget_Analysis

-- Identify Products with Profit Below Budgeted Profit using a CTE.
WITH ProfitComparison AS (
    SELECT 
        f.ProductId, 
        SUM(f.Profit) AS Actual_Profit, 
        SUM(f.Budget_Profit) AS Budget_Profit
    FROM Fact f
    GROUP BY f.ProductId
)
SELECT 
    p.Product, 
    pc.Actual_Profit, 
    pc.Budget_Profit
FROM ProfitComparison pc
JOIN Product p ON pc.ProductId = p.ProductId
WHERE pc.Actual_Profit < pc.Budget_Profit


--3. Inventory & Demand
--Identify Products with Low Inventory Across Regions
SELECT 
    p.Product,
    SUM(f.Inventory) AS Total_Inventory
FROM Fact f
JOIN Product p ON f.ProductId = p.ProductId
WHERE f.Inventory < 300  -- Threshold for low inventory
GROUP BY p.Product

--Products Running Low on Inventory and Impact on Demand

WITH Low_Inventory AS (
    SELECT 
        p.Product,
        f.Inventory,
        f.Sales
    FROM Fact f
    JOIN Product p ON f.ProductId = p.ProductId
    WHERE f.Inventory < 300
)
SELECT * FROM Low_Inventory

--4. Product Performance
--Average Margin by Product Type
SELECT 
    p.Product_Type,
    AVG(f.Margin) AS Average_Margin
FROM 
    fact f
JOIN 
    product p ON f.ProductId = p.ProductId
GROUP BY 
    p.Product_Type

-- Monthly Sales Trends by Product
SELECT 
	p.Product,
	DATEPART(YEAR, f.Date) AS Year,
	DATEPART(MONTH, f.Date) AS Month,
	SUM(f.Sales) AS Total_Sales
FROM Fact f
JOIN Product p ON f.ProductId = p.ProductId
GROUP BY p.Product, DATEPART(YEAR, f.Date), DATEPART(MONTH, f.Date)
ORDER BY Year, Month;

-- Profit Margin and Cost Reduction by Product Type
SELECT 
    p.Product_Type,
    SUM(f.Profit) AS Total_Profit,
    SUM(f.COGS) AS Total_COGS,
    (SUM(f.Profit) * 100.0 / SUM(f.COGS)) AS Profit_Margin_Percentage
FROM Fact f
JOIN Product p ON f.ProductId = p.ProductId
GROUP BY p.Product_Type;


-- Year-over-Year Sales Growth for Each Product


WITH YearlySales AS (
    SELECT 
        YEAR(f.Date) AS Year, 
        f.Productid, 
        SUM(f.Sales) AS Total_Sales
    FROM Fact f
    GROUP BY YEAR(f.Date), f.ProductId
)
SELECT 
    ys1.Year AS Current_Year, 
    ys1.Productid, 
    ys1.Total_Sales AS Sales_Current_Year,
    ys2.Total_Sales AS Sales_Previous_Year,
    ((ys1.Total_Sales - ys2.Total_Sales) / CAST(ys2.Total_Sales AS FLOAT)) * 100 AS Growth_Percentage
FROM YearlySales ys1
JOIN YearlySales ys2 
    ON ys1.Productid = ys2.Productid
    AND ys1.Year = ys2.Year + 1
WHERE ys2.Total_Sales IS NOT NULL -- Ensures only years with previous sales are shown

-- Identify Product with Highest Sales in Each Product Type
SELECT Product_Type, Product, Sales
FROM Product p
JOIN Fact f ON p.ProductId = f.ProductId
WHERE Sales = (SELECT MAX(Sales) 
               FROM Fact f2 
               WHERE f2.ProductId = f.ProductId)
order by 3
-- Top 3 Markets by Sales for Each Product Type (Nested Query)
SELECT Product_Type, Market, Sales
FROM (
    SELECT 
        p.Product_Type, 
        l.Market, 
        SUM(f.Sales) AS Sales, 
        ROW_NUMBER() OVER (PARTITION BY p.Product_Type ORDER BY SUM(f.Sales) DESC) AS RowNum
    FROM Fact f
    JOIN Product p ON f.ProductId = p.ProductId
    JOIN Location l ON f.Area_Code = l.Area_Code
    GROUP BY p.Product_Type, l.Market
) AS RankedSales
WHERE RowNum <= 3

--5. Market Performance
-- Top Selling Products by Area
SELECT distinct
    l.Area_Code,
    p.Product,
    SUM(f.Sales) AS Total_Sales
FROM 
    fact f
JOIN 
    location l ON f.Area_Code = l.Area_Code
JOIN 
    product p ON f.ProductId = p.ProductId
GROUP BY 
    l.Area_Code, p.Product
ORDER BY 
    Total_Sales DESC


-- Identify Top Performing Markets 
WITH Market_Performance AS (
    SELECT 
        l.Market,
        SUM(f.Sales) AS Total_Sales,
        SUM(f.Profit) AS Total_Profit,
        RANK() OVER (ORDER BY SUM(f.Sales) DESC) AS Sales_Rank
    FROM Fact f
    JOIN Location l ON f.Area_Code = l.Area_Code
    GROUP BY l.Market
)
SELECT * FROM Market_Performance
WHERE Sales_Rank <=4  -- Top 4 markets


--6. Time-Based Trend Analysis
-- Monthly Sales Trends
SELECT 
    FORMAT(f.Date, 'yyyy-MM') AS Month,
    SUM(f.Sales) AS Monthly_Sales
FROM 
    fact f
GROUP BY 
    FORMAT(f.Date, 'yyyy-MM')
ORDER BY 
    FORMAT(f.Date, 'yyyy-MM')

-- Automated Reports: Sales and Profit by Date Range and Market
CREATE PROCEDURE GetSalesByMarket
    @StartDate DATE,
    @EndDate DATE,
    @Market NVARCHAR(50)
AS
BEGIN
    SELECT 
        f.Date,
        l.Market,
        SUM(f.Sales) AS Total_Sales,
        SUM(f.Profit) AS Total_Profit
    FROM Fact f
    JOIN Location l ON f.Area_Code = l.Area_Code
    WHERE f.Date BETWEEN @StartDate AND @EndDate
    AND l.Market = @Market
    GROUP BY f.Date, l.Market;
END;

EXEC GetSalesByMarket 
    @StartDate = '2010-01-01',  
    @EndDate = '2011-01-03',     
    @Market = 'East'

--7. Marketing vs Sales
-- Correlation Between Marketing Spend and Sales by Product
SELECT 
    p.Product,
    SUM(f.Marketing) AS Total_Marketing_Spend,
    SUM(f.Sales) AS Total_Sales,
    (SUM(f.Sales) / SUM(f.Marketing)) AS Sales_To_Marketing_Ratio
FROM Fact f
JOIN Product p ON f.ProductId = p.ProductId
GROUP BY p.Product