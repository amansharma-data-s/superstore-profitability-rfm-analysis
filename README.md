# superstore-progitability-rfm-analysis
# Superstore Customer Segmentation (RFM Analysis) — Excel

## Business Question
Which customers are most valuable, and which are at risk of churning, 
based on their purchase behavior?

## Dataset
Superstore sales dataset (orders, customers, sales) 

## Process
- Built a relational Data Model in Power Pivot linking orders, customers, 
  and sales tables
- Calculated Recency, Frequency, and Monetary (RFM) scores per customer 
  using DAX (DIVIDE, DISTINCTCOUNT, RANKX)
- Segmented customers into tiers (e.g. Champions, At Risk, Lost) using 
  SWITCH(TRUE()) logic
- Built KPI cards using CUBEVALUE for dynamic, filter-aware summary metrics
- Designed an interactive dashboard for segment-level insights

## Key Insight
Customer segmentation revealed that Champions (116 customers, 15%) and Lost customers (117, 15%) are nearly identical in size — meaning the business is losing customers at almost the same rate it's cultivating its most valuable ones. Combined with At Risk (66, 8%), nearly a quarter of the customer base is either disengaged or trending that way, highlighting a clear opportunity for targeted retention campaigns.

## Tools
Excel · Power Query · Power Pivot · DAX · CUBEVALUE

## Screenshots


![Dashboard](screenshots/Dashboard.png)




![DAX_Measures](Screenshots/DAX_Mesasures.png)



![Table](Screenshots/Table.png)


# Superstore Loss Analysis (Advanced SQL)

## Overview
An in-depth SQL analysis identifying the root cause of profitability losses 
in a retail Superstore dataset, tracing how that cause manifests across 
customer segments, regions, product categories, individual customers, and 
time.

## Objective
Identify what drives order-level losses and quantify their impact across 
key business dimensions using advanced SQL Server techniques.

## Tools
SQL Server (SSMS)

## Techniques Used
- Correlated subqueries
- Window functions (LAG, running totals with ROWS BETWEEN)
- Common Table Expressions (CTEs), including stacked/chained CTEs
- Views
- JOINs
- PIVOT
- Stored procedures
- Temp tables
- Indexes (conceptual application)

## Key Finding
Discount level is the dominant driver of order-level losses. Profitable 
orders average an 8% discount, while loss-making orders average 47% - 
nearly a 6x gap. High Discount tier orders show an -87.5% loss rate, 
meaning the vast majority of heavily-discounted orders lose money.

## Summary of Findings
- 19.4% of orders result in a loss, but represent 26% of total dollar 
  volume - loss orders tend to be more severe than profit orders are 
  beneficial
- Segment shows minimal loss rate variation (23-27%) - not a meaningful 
  risk predictor; Consumer's larger absolute losses reflect its size, 
  not higher risk
- Supplies (-62%) and Bookcases (-58%) have the highest loss rates by 
  sub-category; Binders has the largest absolute dollar loss due to volume
- Central region has the worst loss rate (-37%), ~2.5x worse than West 
  (-14.8%)
- Loss is accelerating year over year: +2% (2015), +16% (2016), 
  +41% (2017)

## Recommendation
Implement a discount approval threshold around 40%, where profitability 
consistently collapses across every dimension examined. Prioritize 
Binders for absolute dollar recovery and Supplies/Bookcases for 
per-order risk reduction.

## File
Main Project (superstore).sql - full commented query file with 
section headers and inline findings


