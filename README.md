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


