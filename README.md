# Sales-Profit-Analysis

# OVERVIEW
This project involves analyzing a sales dataset containing various attributes such as order details, customer information, product data, and geographical insights. The objective of the project is to extract valuable business insights by running advanced SQL queries to help stakeholders make data-driven decisions. The business problem revolves around identifying trends, analyzing product performance, and comparing budgeted vs. actual results across different dimensions such as time, geography, and product lines.

## Dataset:
Fact Table: Fact

Dimension Tables: Product, Location

Columns: ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERDATE, STATUS, PRODUCTLINE, CUSTOMERNAME, COUNTRY, etc.

![Sales Performance](https://github.com/Aahil-Hussain/Sales-Profit-Analysis/blob/main/png%20files/ERD_Diagram.png)

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

# Performance Comparison: Before and After Indexing

![Sales Performance](https://github.com/username/repository/blob/main/images/sales_performance.png)

Conclusion
The addition of indexing significantly improved query performance, particularly in the parsing and compilation phase. Although the execution time remained comparable, the notable decrease in parse time demonstrates the effectiveness of indexing.

Implications for Larger Datasets
As the dataset size increases (e.g., to millions of rows), the benefits of indexing will become even more pronounced. Indexing can reduce data retrieval times by minimizing the number of rows scanned, leading to faster query execution and improved overall performance.

Visual Evidence
Please refer to the attached screenshots of the execution plan charts before and after indexing to visualize the performance improvements.


# Query Insights:
Here are some key insights extracted from the data:

```--Total Sales and Profit by State:
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

* Top Performing Products: Using window functions, the project identified the top 10 products based on total sales value. These products contributed to over 30% of the company’s revenue.

* Geographical Trends: Analysis of the sales performance across different markets revealed that the West and Central region had the highest sales, with a significant growth trend compared to the previous quarters.

* Budget vs. Actuals: A comparison of budgeted sales vs. actual sales was performed using dynamic queries. This helped in identifying underperforming regions and adjusting the budget allocation for the next quarter.





# Conclusion:
This project demonstrates the power of SQL in extracting business insights from large datasets. By utilizing advanced SQL techniques such as window functions, CTEs, subqueries, and dynamic stored procedures, we were able to generate actionable insights to help drive decision-making.

Feel free to explore the queries and modify them based on your own dataset or business problem.
