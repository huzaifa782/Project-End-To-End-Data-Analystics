select *
from df_orders;

SELECT
	TOP 10
	product_id,
	SUM (sale_price) AS sales
FROM
	df_orders
GROUP BY
	product_id
ORDER BY
	SUM (sale_price) DESC; 



WITH cte AS (
SELECT
	region,
	product_id,
	SUM (sale_price) AS sales
FROM
	df_orders
GROUP BY
	region,
	product_id)
SELECT *
FROM (
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC ) AS rn
	-- ROW_NUMBER() OVER(PARTITION BY region will assign the uniqe integer to rows within a partition of a result set.
	-- ORDER BY sales DESC: This orders the rows within each partition by the sales column in descending order.
FROM cte) A -- It will add the ranking in each region
WHERE
	rn <= 5 -- It will bring top 5 highest soled products from each region


WITH cte AS (
SELECT
	YEAR(order_date) AS order_year,
	MONTH(order_date) AS order_month,
	SUM (sale_price) AS sales
FROM
	df_orders
GROUP BY
	YEAR(order_date),
	MONTH (order_date)
)
SELECT
	order_month,
	SUM (CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022, 
	--  Uses a CASE statement to sum the sales for the year 2022. If order_year is 2022, it includes the sales value; otherwise, it adds 0.
	SUM (CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY
	order_month
ORDER BY
	order_month;




WITH cte AS (
SELECT
	category,
	FORMAT (order_date, 'yyyy-MM') AS order_year_month,
	SUM (sale_price) AS sales
FROM
	df_orders
GROUP BY
	category,
	FORMAT (order_date, 'yyyy-MM')
	)
SELECT *
FROM (
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
	FROM cte
) a
where
	rn = 1



WITH cte AS (
SELECT
	sub_category,
	YEAR(order_date) AS order_year,
	SUM (sale_price) AS sales
FROM
	df_orders
GROUP BY
	sub_category,
	YEAR(order_date)
),
cte2 AS (
SELECT
	sub_category,
	SUM (CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022, 
	--  Uses a CASE statement to sum the sales for the year 2022. If order_year is 2022, it includes the sales value; otherwise, it adds 0.
	SUM (CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY
	sub_category
	)
SELECT TOP 1 *,
	(sales_2023-sales_2022) AS grouth
FROM cte2
ORDER BY
	(sales_2023-sales_2022) DESC;
