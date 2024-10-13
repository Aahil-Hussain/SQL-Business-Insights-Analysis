# SQL Business Insights Analysis 

# OVERVIEW
This project involves analyzing a sales dataset containing various attributes such as order details, customer information, product data, and geographical insights. The objective of the project is to extract valuable business insights by running advanced SQL queries to help stakeholders make data-driven decisions. The business problem revolves around identifying trends, analyzing product performance, and comparing budgeted vs. actual results across different dimensions such as time, geography, and product lines.

## Dataset:
Fact Table: Fact

Dimension Tables: Product, Location

Columns: ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERDATE, STATUS, PRODUCTLINE, CUSTOMERNAME, COUNTRY, etc.

![Sales Performance](https://github.com/Aahil-Hussain/Sales-Profit-Analysis/blob/main/ERD_Diagram.png)

# Objective: 
Provide key insights into sales performance, product trends, customer behavior, and forecast accuracy using advanced SQL techniques.


## SQL Techniques Used:
This project leverages a variety of SQL features, including:

- Window Functions: 
Used to perform calculations across specific rows related to the current row. Functions such as RANK, ROW_NUMBER, and SUM() with OVER(), JOINS,  PARTITION BY, etc  are utilized to analyze trends, rank products, and compare sequential sales periods.

- Common Table Expressions (CTEs): 
CTEs were used for better query readability and efficiency, especially in recursive and complex queries that required breaking down into smaller parts.

- Views: 
Created to encapsulate complex queries, providing a simplified interface for reporting and data retrieval.

- CASE Statements: 
Leveraged to implement conditional logic within queries, allowing for dynamic data transformations based on specified criteria.

- Subqueries: 
Subqueries were extensively used for filtering data, calculating aggregates, and generating derived columns in the main query.

- Dynamic SQL and Stored Procedures: 
Dynamic stored procedures were implemented to allow flexibility in query execution by enabling users to pass parameters for dynamic report generation (e.g., by date range, product category, or region).

## Database Optimization

To enhance the performance of my SQL queries, I implemented various indexing strategies and key structures in the database.

- **Composite Key:** I also created a composite key in the `Fact` table using the `Date`, `ProductId`, and `Area_Code` columns. This composite key ensures data integrity and improves the performance of queries that filter or join on these columns by providing a unique identifier for each record.

- **Non-Clustered Index:** Additionally, I implemented a non-clustered index on the `Date`, `ProductId`, and `Area_Code` columns allowing for quicker searches and aggregations without affecting the physical order of the data.

These optimizations led to a noticeable reduction in query execution times and improved overall efficiency of the database operations.
Although the execution time remained comparable, the notable decrease in parse time demonstrates the effectiveness of indexing.

Implications for Larger Datasets
As the dataset size increases (e.g., to millions of rows), the benefits of indexing will become even more pronounced. Indexing can reduce data retrieval times by minimizing the number of rows scanned, leading to faster query execution and improved overall performance.


# Query Insights:
Here are some key insights extracted from the data:

```
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
```
![Sales Performance](https://github.com/Aahil-Hussain/Sales-Profit-Analysis/blob/main/sql_pic_1.png)

```
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
WHERE Sales_Rank <=4  
```
![Sales Performance](https://github.com/Aahil-Hussain/Sales-Profit-Analysis/blob/main/sql_pic_2.png)

```
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
```
![Sales Performance](https://github.com/Aahil-Hussain/Sales-Profit-Analysis/blob/main/sql_pic_3.png)

```
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
```
![Sales Performance](https://github.com/Aahil-Hussain/Sales-Profit-Analysis/blob/main/sql_pic_5.png)

```
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
```
![Sales Performance](https://github.com/Aahil-Hussain/Sales-Profit-Analysis/blob/main/sql_pic_6.png)
```
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
```
![Sales Performance](https://github.com/Aahil-Hussain/Sales-Profit-Analysis/blob/main/sql_pic_7.png)
```
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
```
![Sales Performance](https://github.com/Aahil-Hussain/Sales-Profit-Analysis/blob/main/sql_pic_8.png)
```
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
```
![Sales Performance](https://github.com/Aahil-Hussain/Sales-Profit-Analysis/blob/main/sql_pic_9.png)
```
-- Inventory and Sales by Product
SELECT 
    p.Product,
    SUM(f.Inventory) AS Total_Inventory,
	sum(sales) as Total_Sales	
FROM Fact f
JOIN Product p ON f.ProductId = p.ProductId
GROUP BY p.Product
order by 2 desc
```
![Sales Performance](https://github.com/Aahil-Hussain/Sales-Profit-Analysis/blob/main/sql_pic_10.png)


* Top Performing Region: Using SUM() functions, the query identified the top 10  states based on theri total sales value. 

* Geographical Trends: Analysis of the sales performance across different markets revealed that the West and Central region had the highest sales, with a significant growth trend compared to the previous quarters.

* Budget vs. Actuals: A comparison of budgeted sales vs. actual sales was performed using dynamic queries. This helped in identifying underperforming regions and adjusting the budget allocation for the next quarter.

* Performance: The query uses a CASE statement to identify underperforming products, providing stakeholders with insights that can help improve future sales strategies.





# Conclusion:
This project demonstrates the power of SQL in extracting business insights from large datasets. By utilizing advanced SQL techniques such as window functions, CTEs, subqueries, and dynamic stored procedures, we were able to generate actionable insights to help drive decision-making.

Feel free to explore the queries and modify them based on your own dataset or business problem.
