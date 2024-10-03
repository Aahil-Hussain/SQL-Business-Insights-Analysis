# Sales-Profit-Analysis

# OVERVIEW
This project involves analyzing a sales dataset containing various attributes such as order details, customer information, product data, and geographical insights. The objective of the project is to extract valuable business insights by running advanced SQL queries to help stakeholders make data-driven decisions. The business problem revolves around identifying trends, analyzing product performance, and comparing budgeted vs. actual results across different dimensions such as time, geography, and product lines.

# Dataset:
Dataset Source: Sales data
Main Tables:
Fact Table: Fact
Dimension Tables: Product, Location
Columns: ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERDATE, STATUS, PRODUCTLINE, CUSTOMERNAME, COUNTRY, etc.

# Objective: 
Provide key insights into sales performance, product trends, customer behavior, and forecast accuracy using advanced SQL techniques.


# SQL Techniques Used
This project leverages a variety of SQL features, including:

- Window Functions: 
Used to perform calculations across specific rows related to the current row. Functions such as RANK, ROW_NUMBER, and SUM() with OVER(), JOINS,  PARTITION BY,  VIEWs, CASE STATEMENT,  are utilized to analyze trends, rank products, and compare sequential sales periods.

- Common Table Expressions (CTEs): 
CTEs were used for better query readability and efficiency, especially in recursive and complex queries that required breaking down into smaller parts.

## Views: 
Created to encapsulate complex queries, providing a simplified interface for reporting and data retrieval.

## CASE Statements: 
Leveraged to implement conditional logic within queries, allowing for dynamic data transformations based on specified criteria.

## Subqueries: 
Subqueries were extensively used for filtering data, calculating aggregates, and generating derived columns in the main query.

## Dynamic SQL and Stored Procedures: 
Dynamic stored procedures were implemented to allow flexibility in query execution by enabling users to pass parameters for dynamic report generation (e.g., by date range, product category, or region).
