CREATE TABLE Sales_Data (
	customer_id int(20) NOT NULL,
	order_id int(20) NOT NULL,
    order_date date NOT NULL,
	SKU varchar(200),
	price float(20),
	Discount float(20),
	order_city varchar(200),
    channel_type Enum('Online', 'Offline'),
  PRIMARY KEY (customer_id)
);

CREATE TABLE product_details (
	SKU varchar(200),
	MRP float(20),
	product_name varchar(200),
  PRIMARY KEY (SKU)
);

CREATE TABLE customer_details (
	customer_id int(20) NOT NULL,
	name varchar(200),
	phone_number int(20),
	email varchar(200),
  PRIMARY KEY (customer_id)
);

-- Query 1 --
-- Name and list the details of all customers who have placed multiple orders and have purchased a ceramic item at least once.--

-- Ceramic items start with 'CR' --
SELECT DISTINCT c.customer_id, c.name, c.phone_number, c.email
FROM Sales_Data s
JOIN Customer_Details c ON c.customer_id = s.customer_id
JOIN Product_Details p ON p.sku = s.sku
WHERE p.SKU LIKE 'CR%'
 -- Multiple orders--
  AND c.customer_id IN (
    SELECT customer_id
    FROM Sales_Data
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
  );
  
-- Query 2 --
-- Find the most expensive bestseller --
SELECT 
	p.sku, p.product_name, max(MRP) AS expensive,
	Count(s.order_id) as total_orders
 FROM product_details p
 Join sales_data s ON s.sku=p.sku
 Group By p.sku
 Order By total_orders Desc, expensive desc
 Limit 1
 
-- Query 3 --
-- For all customers who have purchased for the first time online, calculate the average number of times they purchase offline in a month --

WITH First_oln_pur as (
	SELECT customer_id, min(order_date) as First_oln_date
	FROM sales_data
	where channel_type = 'online'
	group by customer_id
    ),
Ofn_pur as (
	SELECT s.customer_id,
        COUNT(*) AS ofn_pur_count,
        EXTRACT(MONTH FROM S.order_date) AS purchase_month
	FROM sales_data S
	Join First_oln_pur F ON F.customer_id = S.customer_id
	where channel_type = 'offline'
    group by customer_id , purchase_month
    )
Select 
	AVG(ofn_pur_count) as Average_Offline_purchase_per_month 
from Ofn_pur

-- Query 4 --
-- List the top 7 spenders in Y city (here Y should be a user-input variable)--

-- Select new Stored procedure and enter below query,
CREATE DEFINER=`root`@`localhost` 
PROCEDURE `Top_7_spenders_in_X_city`
	(city_name VARCHAR(255))
BEGIN
	Select
		customer_id, order_city, 
        Sum(price*(1-discount/100)) as total_spending
	From sales_data
    Where order_city = city_name
    GROUP BY customer_id
    ORDER BY total_spending DESC
    LIMIT 7;
END