


/*                                  PROJECT SUMMARY: SUPERSTORE LOSS ANALYSIS 
    OBJECITVE : Identify the root cause of profitability losses within the Superstore dataset and trace how that cause manifests across
        customer segments, regions, product categories, and time — using advanced SQL techniques including correlated subqueries, window
        functions, CTEs, Views, JOINs, PIVOT, and stored procedures.

    Tools: SQL Server (SSMS) — correlated subqueries, LAG, running totals, stacked CTEs, Views, JOINs, PIVOT, indexes, stored procedures
        , temp tables

Key Finding: Discount level is the dominant, near-singular driver of order-level losses. Profitable orders average an 8% discount,
    while loss-making orders average 47% — nearly a 6x gap. When broken down by discount tier, the High Discount tier alone shows an
    -87.5% loss rate, meaning almost every high-discount order loses money, and losses in that tier are severe enough to dominate the
    tier's entire dollar volume.

Supporting Findings:
    19.4% of orders result in a loss, but those losses represent 26% of total dollar volume — loss orders tend to be individually more 
    severe than profit orders are beneficial, consistent with concentrated high-discount transactions.

    Segment shows minimal variation in loss rate (Corporate -24%, Home Office -23%, Consumer -27%) — segment does not meaningfully 
    predict risk. Consumer's larger absolute loss dollars (-$84,945) reflect its size as the largest segment by volume, not higher 
    inherent risk.

    Sub-category loss rate varies sharply: Supplies (-62%) and Bookcases (-58%) are the riskiest by rate, but Binders represents the 
    largest absolute dollar loss across regions when aggregated via PIVOT — a high-volume, moderately-risky category rather than a 
    high-risk one.

    Central region has the worst loss rate (-37%), roughly 2.5x worse than the healthiest region, West (-14.8%) — directly consistent
    with Central's elevated average discount found in the original Superstore analysis.

    Loss is concentrated in a small number of customers: Cindy Stewart alone accounts for a disproportionate share of total 
    company-wide loss, driven by a single order with a 44%+ discount.

    Yearly loss is accelerating: cumulative loss grew modestly in 2015 (+2% vs 2014) but accelerated sharply through 2016 (+16%) and 
    2017 (+41%) — the rate of decline is itself worsening, not just the raw dollar figure.

Recommendation: Implement a discount approval threshold around the 40% mark, since this is the point where profitability consistently 
collapses across every dimension examined (region, sub-category, segment, and individual customers). Prioritize review of high-volume,
moderately-risky sub-categories like Binders for the largest absolute dollar recovery, while addressing Supplies and Bookcases for the
highest per-order risk reduction. Given the accelerating yearly trend, this issue should be treated as time-sensitive rather than a 
stable, manageable baseline.*/








/* ============================================================
   Superstore Loss Analysis
   ============================================================ */

/* Baseline aggregate check */
select 
  round(sum(sales),1) as [total revenue],
  round(avg(sales),1) as [average revenue],
  round(min(sales),1) as [min sale],
  round(max(sales),1) as [max sales],
  round(sum(profit),1) as [total profit],
  round(avg(profit),1) as [average profit],
  round(min(profit),1) as [min profit],
  round(max(profit),1) as [max profit]
from Superstore;

/* Worst single loss order (excluding NULL profit rows) */

select top 10
  Customer_ID,
  Customer_Name,
  Profit
from Superstore
where Profit is not null
order by Profit asc;
/* Cindy Stewart (CS-12505) has the largest real loss at -$6,599.98.
Note: one row (Customer DV-13045, Damin Van Huff) has a NULL Profit despite 
valid Sales ($721.88), Discount (44%), and Quantity (6, Tables) - likely a 
data entry gap. Given the 44% discount on Tables, this order would plausibly 
represent another significant loss based on established patterns, but is 
excluded from profit aggregations due to the missing value. */


/* ------------------------------------------------------------
   SECTION: Profit vs Loss Split (order count)
   ------------------------------------------------------------ */

with pnl as (
  select 
    Order_ID,
    Profit,
    case 
      when Profit <= 0 or Profit is null then 'loss'
      else 'Profit'
    end as [profit or loss]
  from Superstore
)
select 
  [profit or loss],
  COUNT(*) as [order count]
from pnl
group by [profit or loss];
/* 8,058 profitable orders (80.6%) vs 1,936 loss orders (19.4%) */

/* Dollar volume split  */
with pnl as (
  select 
    Order_ID,
    Profit,
    case 
      when Profit <= 0 or Profit is null then 'loss'
      else 'Profit'
    end as [profit or loss]
  from Superstore
)
select 
  [profit or loss],
  COUNT(*) as [order count],
  SUM(Profit) as [total profit or loss],
  CONCAT(round(SUM(Profit)*100.0 / (select SUM(ABS(Profit)) from pnl),1), '%') as [% dollar volume]
from pnl
group by [profit or loss];
/* Profit = 73% of total dollar volume, Loss = -26%.
Since only 19.4% of orders are losses but they represent 26% of dollar volume,
loss orders tend to be individually more severe than profit orders are beneficial -
likely driven by concentrated high-discount transactions (e.g., Tables at 40%+ discount). */

/* ------------------------------------------------------------
   SECTION: Loss Analysis by Segment
   ------------------------------------------------------------ */
   /* Total orders vs loss orders per segment - proving segment size drives absolute $ */
select 
  Segment,
  COUNT(*) as [total orders],
  (select count(*) from Superstore s2 
   where s2.Profit <= 0 and s2.Segment = Superstore.Segment) as [loss orders]
from Superstore
group by Segment;


/* Loss RATE within each segment */
select 
  Segment,
  Round(sum(Profit),1) as [Total loss],
  Concat(round(sum(Profit)*100 / (select
                                    sum(ABS(Profit))
                                   from Superstore s2 
                                   where s2.Segment = Superstore.Segment)
  ,1),'%') as [% of segment volume that is loss]
from Superstore
where Profit <= 0
group by Segment;

/* Corporate: -24% | Home Office: -23% | Consumer: -27%
Loss RATE is similar across all segments - segment does not meaningfully predict risk. */

/* Confirms Consumer has proportionally more total orders, explaining why its 
absolute loss dollars (-$84,945) are larger than Home Office (-$26,398) or 
Corporate (-$44,367) despite similar loss RATES. Consumer is the largest segment 
by volume, not the riskiest per dollar. */

/* ------------------------------------------------------------
   SECTION: Loss Analysis across sub-category
   ------------------------------------------------------------ */

/*Total orders vs loss orders in sub category */
select 
  Sub_Category,
  COUNT(*) as [total orders],
  (select count(*) from Superstore s2 
   where s2.Profit <= 0 and s2.Sub_Category = Superstore.Sub_Category) as [loss orders]
from Superstore
group by Sub_Category;

/* loss rate within sub category*/
select 
 Sub_Category,
  Round(sum(Profit),1) as [Total loss],
  Concat(Round(sum(Profit)*100 / (select
                                    sum(ABS(Profit))
                                   from Superstore s2 
                                   where s2.Sub_Category= Superstore.Sub_Category)
  ,1),'%') as [% of category volume that is loss]
from Superstore
where Profit <= 0
group by Sub_Category;

/* ------------------------------------------------------------
   SECTION: Loss Analysis across Region
   ------------------------------------------------------------ */


/*Total orders vs loss orders in Region */
select 
  Region,
  COUNT(*) as [total orders],
  (select count(*) from Superstore s2 
   where s2.Profit <= 0 and s2.Region = Superstore.Region) as [loss orders]
from Superstore
group by Region;

/* loss rate within Region*/
select 
 Region,
  Round(sum(Profit),1) as [Total loss],
  Concat(Round(sum(Profit)*100 / (select
                                    sum(ABS(Profit))
                                   from Superstore s2 
                                   where s2.Region= Superstore.Region)
  ,1),'%') as [% of region volume that is loss]
from Superstore
where Profit <= 0
group by Region;

/*loss by region analysis for furthure information in relation to */
select Sub_Category,[East],[West],[South],[Central],(ISNULL([East],0)+ISNULL([West],0)+ISNULL([South],0)+ISNULL([Central],0)) as [Total loss]
from(
select 
Region,
Sub_Category,
Profit
from Superstore 
where Profit <= 0) as [SourceTable]
Pivot (
Sum(Profit)
For Region in ([East],[West],[South],[Central]))as PivotTable
order by [Total loss]
/*Loss distribution among difrent regions on bases of sub category
while supplies and bookcases show the highest loss rates (62% and 
58% respectively),binders repersents the largest absolite dollar 
loss when agregated across regions_indicating its a jigh volume,
moderately-risky cayehoru rayher than a high riskone. This distinction 
matters for prioritization: Fixing binders discount practices would likely 
recover more total dollars, Even though supplies is proportionally the more broken category*/



/* ------------------------------------------------------------
   SECTION: Loss Analysis across Cusotmer
   ------------------------------------------------------------ */



/*who has the most amount of losses (doller lost) */
Select top 10
    Customer_ID,
    Customer_Name,
    COUNT(*) AS [Total order],
    (select 
        count(*)
    from Superstore as t2
    where Profit <= 0 and t2.Customer_ID= Superstore.Customer_ID)
    as [Loss orders],
    SUM(Profit) AS [Total revenue]
from Superstore
Group by Customer_ID,Customer_Name
order by SUM(Profit);


/* loss rate within customer*/
select top 10
 Customer_ID,
 Customer_Name,
  Round(sum(Profit),1) as [Total loss],
  Concat(Round(sum(Profit)*100 / (select
                                    sum(Profit)
                                   from Superstore s2 
                                   where Profit <= 0)
  ,1),'%') as [% Share of total company loss]
from Superstore
where Profit <= 0
group by Customer_ID,Customer_Name
order by SUM(Profit);

/* ------------------------------------------------------------
   SECTION: Root cause 
   ------------------------------------------------------------ */
/*Does discount/quantity actaully explain the loss pattern? */
select 
round(AVG(Discount),2) as [average discount profit],
(select 
round(AVG(Discount),2)
from Superstore
where Profit <= 0) as [ avrage discount loss]
from Superstore
where Profit > 0.0;
/*profitable orders avg 8% discount vs 47% for loss orders - ~6x gap, the primary driver of order-level losses  */

/*Is loss getting wrose or better over time- Trend over time */

with [monthly losses] as(
select 
YEAR(Order_Date) AS [Year],
MONTH(Order_Date) AS [Month],
SUM(case when Profit < =0 then Profit else 0 end ) as [Monthly loss]
from Superstore
Group by YEAR(Order_Date) ,
MONTH(Order_Date))
select 
[Year],
[Month],
LAG([Monthly loss] )over (order by [Year],[Month]) as [previous monnth loss],
[Monthly loss] - LAG([Monthly loss] )over (order by [Year],[Month]) as  [change in loss]
from [monthly losses]
order by [Year],[Month];

/* monthly loss is too volatile to show a clean trend - see yearly aggregation below*/
-------------------------------------------------------------------------------------------------------


with [Yearly losses] as(
select 
YEAR(Order_Date) AS [Year],
SUM(case when Profit < =0 then Profit else 0 end ) as [year loss]
from Superstore
Group by YEAR(Order_Date) ), 
[with lag ] as (
select 
Year,
[year loss],
LAG([year loss] )over (order by [Year]) as [previous monnth loss]
from [Yearly losses])
select 
[Year],
round([year loss] - [previous monnth loss] ,2) as  [change in loss],
concat(round(([year loss] - [previous monnth loss])*100/ [previous monnth loss],2),'%') AS [percent change year over year ]
from [with lag ]
order by [Year];

/*Whats the loss rate in each discount tier */
select 
dt.[Discount Tier],
SUM(case when s.Profit <=0 then s.Profit else 0 end ) [Total loss],
concat(
    ROUND(
        SUM(case when s.Profit <=0 then s.Profit else 0 end)*100/sum(abs(s.Profit))                                                          
    ,2)
 ,'%')AS [Percent prportion]
from DiscountTiers as dt
Join Superstore as s on dt.Order_ID = s.Order_ID
group by dt.[Discount Tier];



/*running total -- cumulative loss */
with yearly_loss as (
select  
    YEAR(Order_Date) as [years],
    Round(SUM(case when Profit<= 0 then Profit ELSE 0 end ),2)as [total loss]
from Superstore
group by YEAR(Order_Date) )
select 
    years,
    [total loss],
    Round(
        sum([total loss]) over (order by years rows between unbounded preceding and current row),2) as [cumulative loss]
from yearly_loss
order by years;


/*Cumulative loss grows steadily and accelerates in 2016-2017,consistant wiht the yearly % change trend */

/* ------------------------------------------------------------
   SECTION: Technique Demonstrations
   ------------------------------------------------------------ */
   SELECT
    Region,
    SUM(Profit) AS [Total Loss]
INTO #RegionLoss
From Superstore
Where Profit <= 0
Group by Region

Select *From #RegionLoss Where [Total Loss] < -30000

EXEC GetRegionLossRate @Region_name = 'Central'