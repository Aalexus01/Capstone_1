-- Analyzing the sales Territory in New York.


-- What is total revenue overall for sales in the assigned territory, 
-- plus the start date and end date that tell you what period the data covers?

SELECT SUM(SalesTotal) as TotalRevenue, MIN(Date) as StartDate, MAX(Date) as EndDate
FROM online_sales
WHERE ShiptoState = 'New York'; 

SELECT SUM(ss.Sale_Amount) as TotalRevenue, MIN(ss.Transaction_Date) as StartDate, MAX(ss.Transaction_Date) as EndDate
FROM store_sales ss
JOIN store_locations sl
ON ss.Store_ID = sl.StoreId 
WHERE State = 'New York';


SELECT SUM(TotalRevenue) as OverallRevenueTotal, MIN(StartDate) as StartDate, MAX(EndDate) as EndDate
FROM (
SELECT SUM(SalesTotal) as TotalRevenue, MIN(Date) as StartDate, MAX(Date) as EndDate
FROM online_sales
WHERE ShiptoState = 'New York'

UNION ALL

SELECT SUM(ss.Sale_Amount), MIN(ss.Transaction_Date) as StartDate, MAX(ss.Transaction_Date) as EndDate
FROM store_sales ss
JOIN store_locations sl 
ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'New York' 
) as combined_sales;


-- What is the revenue breakdown by year and month for the sales territory?

SELECT RevenueYear, RevenueMonth, SUM(Revenue) as TotalRevenue

FROM (
SELECT YEAR(Date) as RevenueYear, MONTH(Date) as RevenueMonth, SUM(SalesTotal) as Revenue
FROM online_sales
WHERE ShiptoState = 'New York'
GROUP BY YEAR(Date), MONTH(Date)

UNION ALL 

SELECT YEAR(ss.Transaction_Date) as RevenueYear, MONTH(ss.Transaction_Date) as RevenueMonth, SUM(ss.Sale_Amount) as Revenue
FROM store_sales ss
JOIN store_locations sl
ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'New York'
GROUP BY RevenueYear, RevenueMonth)
as combined_revenue
GROUP BY RevenueYear, RevenueMonth
ORDER BY RevenueYear, RevenueMonth; 


-- Provide a comparison of total revenue for the specific sales territory and the region it belongs to.

SELECT DISTINCT State
FROM management
WHERE Region = 'East';

SELECT 

SUM(CASE WHEN State = 'New York'
    THEN Revenue Else 0 END) as NYRevenue, SUM(Revenue) as RegionRevenue
FROM (    
SELECT ShiptoState as State, SUM(SalesTotal) as Revenue 
FROM online_sales
WHERE ShiptoState IN ('New York', 'Connecticut')
GROUP BY ShiptoState 

UNION ALL 

SELECT sl.State, SUM(ss.Sale_Amount) as Revenue
FROM store_sales ss
JOIN store_locations sl
ON ss.Store_ID = sl.StoreId
WHERE sl.State IN ('New York', 'Connecticut')
GROUP BY sl.State )
as combined_revenue;


-- What is the number of transactions per month and average transaction amount by product category for the sales territory?

SELECT SalesMonth, SalesYear, Category, COUNT(*) MonthlySalesCount, AVG(TransactionAmount) as AvgSale

FROM (

SELECT
MONTH(os.Date) SalesMonth, 
YEAR(os.Date) SalesYear, ic.Category as Category, os.SalesTotal as TransactionAmount
FROM online_sales os JOIN products p ON os.ProdNum = p.ProdNum
JOIN inventory_categories ic ON p.Categoryid = ic.Categoryid
WHERE ShiptoState = 'New York'

UNION ALL
 
SELECT
MONTH(ss.Transaction_Date) SalesMonth,
YEAR(ss.Transaction_Date) SalesYear, ic.Category as Category, ss.Sale_Amount as TransactionAmount
FROM store_sales ss
JOIN products p ON ss.Prod_Num = p.ProdNum
JOIN inventory_categories ic ON p.Categoryid = ic.Categoryid
JOIN store_locations sl ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'New York'
) as combined_sales
GROUP BY SalesMonth, SalesYear, Category
ORDER BY SalesMonth, SalesYear, Category;