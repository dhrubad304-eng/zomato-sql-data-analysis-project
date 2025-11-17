# Zomato SQL Data Analysis Project

![Project Banner](https://github.com/dhrubad304-eng/zomato-sql-data-analysis-project/blob/52cf9523d999178487e8ac7829295afbef0b3e22/zomato-logo-jpeg.jpg)

This project is a complete SQL case study built on a Zomato-like food delivery dataset.  
It includes database creation, exploratory data analysis (EDA), and business-focused analytical queries.

## Project Highlights
- Designed 5 relational tables (customers, restaurants, orders, riders, deliveries)
- Added foreign key relationships for structured relational modelling
- Performed exploratory data analysis using essential SELECT queries
- Solved 12 practical business-driven analytical questions

## Key Analysis Performed
- Most frequently ordered dishes by customers
- Popular ordering time slots across 2-hour intervals
- Average Order Value (AOV) analysis for high-frequency customers
- Top revenue-generating restaurants in each city
- Month-over-month customer retention tracking
- Rider-wise delivery success rate analysis
- Customer loyalty insights for each restaurant
- Delivered order revenue analysis for the last 6 months

## Database Schema Overview
The database contains five main tables:

1. Customers  
   Stores customer details and registration dates.

2. Restaurants  
   Contains restaurant information, locations, and operating hours.

3. Orders  
   Includes order details such as items, date, time, status, and bill amount.

4. Riders  
   Contains rider information and sign-up dates.

5. Deliveries  
   Stores delivery records linked to both orders and riders.

Relationships:
- Each customer can place multiple orders.
- Each restaurant can have multiple orders.
- Each rider can deliver multiple orders.
- Each delivery entry is tied to one order and one rider.

## Files Included
- `zomato_analysis.sql`  
  Contains the entire SQL script including table creation, constraints, EDA, and analytical queries.

## Tech Used
- SQL (PostgreSQL-style analytical functions)
- Compatible with PostgreSQL, MySQL 8+, and other SQL engines supporting window functions

## How to Use
1. Create a database in your SQL environment.
2. Run the SQL script (`zomato_analysis.sql`) to generate all tables and relationships.
3. Execute the EDA and analytical queries section to view insights.
4. Modify or extend the queries for deeper analysis if required.

## Use Case
This project can be used for:
- SQL learning and practice
- Portfolio and GitHub showcase
- Business analysis demonstrations
- Interview preparation
