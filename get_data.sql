with CTE AS
(
	SELECT 
		MONTH(DATEVALUE) as MONTH,
		year(DATEVALUE) AS year,
		DBRA."NAME" AS BRANCHNAME, 
		DLOB.NAME AS LINEOFBUSINESS, 
		DCUS."NAME" AS CUSTOMERNAME
		, DLOC."NAME" AS LOCATIONNAME
		, DITEM."NAME" AS ITEMNAME
		, DB.[CF: BUSINESS CHANNEL]
		, SALES
		, Quantity
		, SALES/Quantity as unit_price
		FROM Canteen.RECOGNIZESALESREVENUEFACT_V RECO
		INNER JOIN Canteen.DIMLOCATION_V DLOC
		ON RECO.LOCATIONKEY = DLOC.LOCATIONKEY
		INNER JOIN Canteen.DIMMACHINE_V DMACH
		ON RECO.MACHINEKEY = DMACH.MACHINEKEY
		INNER JOIN Canteen.DIMITEM_V DITEM
		ON RECO.ITEMKEY = DITEM.ITEMKEY
		INNER JOIN Canteen.DIMCUSTOMER_V DCUS
		ON DLOC.CUSTOMERKEY = DCUS.CUSTOMERKEY
		INNER JOIN Canteen.DIMBRANCH_V DBRA
		ON DCUS.BRANCHKEY = DBRA.BRANCHKEY
		INNER JOIN Canteen.DIMROUTE_V DROU
		ON DMACH.ROUTEKEY = DROU.ROUTEKEY
		INNER JOIN Canteen.DIMLINEOFBUSINESS_V DLOB
		ON RECO.LINEOFBUSINESSKEY = DLOB.LINEOFBUSINESSKEY
		INNER JOIN Canteen.DIMDATE_V DTIME
		ON RECO.VISITDATEKEY = DTIME.DATEKEY
		left join Canteen.Location_Manager_Map DB
		on DLOC.NAME = DB.Location
		WHERE 1=1
		AND saletype = 'Visit'
		and DITEM.size = '500ml'
		and Quantity > 0 and SALES > 0
		and RECO.lineofbusinesskey > 1
		AND MONTH(DATEVALUE) = 1 AND YEAR(DATEVALUE) IN (2023, 2024)
	),
cte_2 as
(
SELECT
	[CF: BUSINESS CHANNEL],
	LINEOFBUSINESS,
	CUSTOMERNAME,
	LOCATIONNAME,
	ITEMNAME,
	SUM(CASE WHEN year = 2023 AND month = 1 THEN SALES ELSE 0 END) AS Sales_2023_01,
	SUM(CASE WHEN year = 2023 AND month = 1 THEN Quantity ELSE 0 END) AS Quantity_2023_01,
	cast(SUM(CASE WHEN year = 2023 AND month = 1 THEN SALES ELSE 0 END) as float)/SUM(CASE WHEN year = 2023 AND month = 1 THEN Quantity ELSE 0 END) AS unit_price_2023_01,
	--AVG(CASE WHEN year = 2023 AND month = 1 THEN unit_price ELSE 0 END) AS unit_price_2023_01,
	SUM(CASE WHEN year = 2024 AND month = 1 THEN SALES ELSE 0 END) AS Sales_2024_01,
	SUM(CASE WHEN year = 2024 AND month = 1 THEN Quantity ELSE 0 END) AS Quantity_2024_01,
	cast(SUM(CASE WHEN year = 2024 AND month = 1 THEN SALES ELSE 0 END) as float)/SUM(CASE WHEN year = 2024 AND month = 1 THEN Quantity ELSE 0 END) AS unit_price_2024_01
	--AVG(CASE WHEN year = 2024 AND month = 1 THEN unit_price ELSE 0 END) AS unit_price_2024_01,

	--SUM(CASE WHEN year = 2023 AND month = 7 THEN SALES ELSE 0 END) AS Sales_2023_07,
	--SUM(CASE WHEN year = 2023 AND month = 7 THEN Quantity ELSE 0 END) AS Quantity_2023_07,
	--AVG(CASE WHEN year = 2023 AND month = 7 THEN unit_price ELSE 0 END) AS unit_price_2023_07,
	--SUM(CASE WHEN year = 2024 AND month = 7 THEN SALES ELSE 0 END) AS Sales_2024_07,
	--SUM(CASE WHEN year = 2024 AND month = 7 THEN Quantity ELSE 0 END) AS Quantity_2024_07,
	--AVG(CASE WHEN year = 2024 AND month = 7 THEN unit_price ELSE 0 END) AS unit_price_2024_07
FROM CTE
GROUP BY [CF: BUSINESS CHANNEL],
	LINEOFBUSINESS,
	CUSTOMERNAME,
	LOCATIONNAME,
	ITEMNAME
)
	select
		[CF: BUSINESS CHANNEL],
		LINEOFBUSINESS,
		CUSTOMERNAME,
		LOCATIONNAME,
		ITEMNAME,
		Quantity_2023_01,
		unit_price_2023_01,
		Quantity_2024_01,
		unit_price_2024_01
	from cte_2
	where Quantity_2023_01 > 0 and Quantity_2024_01 >0 and Sales_2023_01>0 and Sales_2024_01>0
	-- and ITEMNAME like '%COKE CLASSIC BTL%'


-- SELECT 
-- -- ITEMNAME,
-- unit_price_2024_01,
-- unit_price_2023_01,
-- CAST(ROUND(unit_price_2024_01-unit_price_2023_01, 2) AS NUMERIC(26,2)) AS change_in_price,
-- Quantity_2024_01,
-- Quantity_2023_01,
-- unit_price_2024_01-unit_price_2023_01 AS change_in_quantity
-- FROM CTE_3

-- select
-- 	ITEMNAME,
-- 	price_change,
-- 	unit_price_2024_01,
-- 	unit_price_2023_01,
-- 	Quantity_2024_01,
-- 	Quantity_2023_01
-- 	cast((sum(Quantity_2024_01) - sum(Quantity_2023_01)) as float)/sum(Quantity_2023_01) as Qty_change_percentage
-- from cte_4
-- group by
-- price_change,ITEMNAME,unit_price_2024_01, unit_price_2023_01

-- order by 1
-- ;