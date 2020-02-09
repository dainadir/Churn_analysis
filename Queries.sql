-- --------------------------------------------------------
-- QUERIES TO DERIVE ADDITIONAL INFO
-- --------------------------------------------------------

-- --------------------------------------------------------
-- AVERAGE NUMBER OF ORDERS PER MONTH FOR EACH SHOP
-- --------------------------------------------------------

SELECT a.shop_id, ROUND(AVG(CONVERT(FLOAT, a.orders)),2) AS avg_orders_per_mnth FROM
	(SELECT shop_id, MONTH(created_at_date) AS mnth, COUNT(*) AS orders
		FROM orderitems_modified 
		GROUP BY shop_id, MONTH(created_at_date)) AS a
GROUP BY a.shop_id 
ORDER BY a.shop_id

-- --------------------------------------------------------
-- THE PERCENTAGE OF ALL IMPORTS OCCURRING DURING A WEEKDAY
-- --------------------------------------------------------

WITH weekends AS (SELECT id, shop_id, created_at_date, 
	CASE WHEN DATENAME(DW, created_at_date) = 'Saturday' OR DATENAME(DW, created_at_date) = 'Sunday' THEN 'Weekend' ELSE 'Weekday' END AS daytype
FROM importproducts_modified
GROUP BY id, shop_id, created_at_date)

SELECT w.shop_id, COUNT(CASE w.daytype WHEN 'Weekday' THEN 1 ELSE NULL END) AS weekday, 
	COUNT(CASE w.daytype WHEN 'Weekend' THEN 1 ELSE NULL END) AS weekend,
	ROUND(CAST(COUNT(CASE w.daytype WHEN 'Weekday' THEN 1 ELSE NULL END) AS FLOAT)/CAST(COUNT(ID) AS FLOAT),2) AS percentage_weekday
FROM weekends AS w
GROUP BY w.shop_id
ORDER BY COUNT(CASE w.daytype WHEN 'Weekend' THEN 1 ELSE NULL END) DESC

-- --------------------------------------------------------
-- AVERAGE NUMBER OF SOURCES USED TO IMPORT PRODUCTS
-- --------------------------------------------------------

 SELECT a.shop_id, ROUND(AVG(CONVERT(FLOAT, a.num_sources)),0) AS avg_sources_used_per_mnth FROM
	(SELECT shop_id, MONTH(created_at_date) AS mnth, COUNT(DISTINCT(source)) AS num_sources
	FROM importproducts_modified 
	GROUP BY shop_id, MONTH(created_at_date)) AS a
GROUP BY a.shop_id 
ORDER BY ROUND(AVG(CONVERT(FLOAT, a.num_sources)),2) DESC

-- --------------------------------------------------------
-- DAYS TO IMPORT FIRST PRODUCT
-- --------------------------------------------------------

SELECT i.shop_id, s.created_at_date, MIN(i.created_at_date) AS first_import, DATEDIFF (DAY,s.created_at_date, MIN(i.created_at_date)) AS diff  
FROM importproducts_modified AS i
LEFT JOIN shops_modified AS s ON s.id = i.shop_id
GROUP BY i.shop_id, s.created_at_date
ORDER BY shop_id ASC

-- --------------------------------------------------------
-- LABEL DATA: 1 - CHURNER, 0 - ACTIVE
-- --------------------------------------------------------

WITH Time_Series AS(
    SELECT shop_id, DATEDIFF(DAY,LAG(created_at_date) OVER (PARTITION BY shop_id ORDER BY created_at_date),created_at_date) AS diff 
    FROM importproducts_modified)

SELECT g.shop_id, a.last_import,
       CASE WHEN (MAX(g.diff) > 31) OR (DATEDIFF(DAY, a.last_import, '2017/07/24') > 31) THEN 1 ELSE 0 END AS churn
FROM Time_Series g
INNER JOIN 
	(SELECT shop_id, MAX(created_at_date) AS last_import
	FROM importproducts_modified
	GROUP BY shop_id) AS a ON a.shop_id = g.shop_id
GROUP BY g.shop_id, a.last_import
ORDER BY CASE WHEN (MAX(g.diff) > 31) OR (DATEDIFF(DAY, a.last_import, '2017/07/24') > 31) THEN 1 ELSE 0 END DESC

-- --------------------------------------------------------
-- AVERAGE NUMBER OF DIFFERENT PRODUCTS STORED IN THE SHOP PER EACH MONTH
-- --------------------------------------------------------

SELECT a.shop_id, ROUND(AVG(CONVERT(FLOAT, a.avg_no_prod)),0) AS avg_no_of_prod FROM
	(SELECT shop_id, MONTH(created_at_date) as mnth, count(distinct(product_id)) AS avg_no_prod
	FROM importproducts_modified 
	GROUP BY shop_id, MONTH(created_at_date)) AS a
GROUP BY a.shop_id

 
-- --------------------------------------------------------
-- DAYS TO SELL FIRST PRODUCT COUNTING FROM FIRST IMPORT
-- --------------------------------------------------------

SELECT i.shop_id, MIN(i.created_at_date) AS min_import, MIN(o.created_at_date) AS min_order, DATEDIFF (DAY,MIN(i.created_at_date), MIN(o.created_at_date)) AS diff 
FROM importproducts_modified  AS i
LEFT JOIN orderitems_modified AS o ON o.shop_id = i.shop_id
GROUP BY i.shop_id
ORDER BY i.shop_id DESC


-- --------------------------------------------------------
-- HOW LONG CLIENT IS ACTIVE
-- --------------------------------------------------------

SELECT i.shop_id,  f.created_at_date AS shop_created, MAX(i.created_at_date) AS last_order,
	CASE WHEN f.created_at_date >= '2017-07-01' THEN DATEDIFF (MONTH,f.created_at_date, MAX(i.created_at_date)) ELSE 
		DATEDIFF (MONTH,f.created_at_date, MAX(i.created_at_date))+1  END AS months
FROM importproducts_modified AS i
LEFT JOIN final_dataset AS f ON f.id = i.shop_id
GROUP BY i.shop_id, f.created_at_date 
ORDER BY 4 ASC
