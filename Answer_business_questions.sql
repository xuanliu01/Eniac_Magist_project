/***** Answer business questions *****/ 
USE magist;

/* 2.1. In relation to the products: */
 
-- What categories of tech products does Magist have?
SELECT * FROM product_category_name_translation; # 74 rows 

SELECT 
	product_category_name_english,
CASE 
    WHEN product_category_name_english IN (
      'computers',
      'computers_accessories',
      'consoles_games',
      'electronics',
      'fixed_telephony',
      'pc_gamer',
      'tablets_printing_image' 
      'telephony')
	 THEN 'Tech_products'
     ELSE 'Others'
END AS category_group 
FROM 
    product_category_name_translation;   
      
   
-- How many products of these tech categories have been sold (within the time window of the database snapshot)? 

SELECT 
     COUNT(DISTINCT(oi.product_id)) AS tech_products_sold
FROM 
     order_items AS oi
     LEFT JOIN products AS p USING (product_id)
     LEFT JOIN product_category_name_translation AS pt USING(product_category_name)
WHERE 
     #product_category_name_english IN (
     #'computers',
	 #'computers_accessories',
	 #'consoles_games',
	 #'electronics',
	 #'fixed_telephony',
	 #'pc_gamer',
	 #'tablets_printing_image' 
	 #'telephony');  
	 product_category_name_english IN (
     "audio", 
     "electronics", 
     "computers_accessories", 
     "pc_gamer", "computers", 
     "tablets_printing_image", 
     "telephony");
	-- 3390

-- What percentage does that represent from the overall number of products sold? 
 
SELECT * FROM product_category_name_translation;
SELECT * FROM products;
SELECT * FROM orders;

SELECT COUNT(DISTINCT(product_id)) AS products_sold
FROM order_items;
	-- 32951
    
SELECT 3390 / 32951; -- This step can also be done on a calculator
	-- 0.1029, therefore 10%

/************************** 
WITH high_tech_categories AS (  # filter high tech category
    SELECT  
         DISTINCT * 
    FROM 
         product_category_name_translation
    WHERE 
         product_category_name_english 
      IN (
      'computers',
      'computers_accessories',
      'consoles_games',
      'electronics',
      'pc_gamer',
      'signaling_and_security',
      'tablets_printing_image' 
       )
),
    products_sold AS ( # find sold product 
	SELECT 
	     DISTINCT o_it.product_id 
		#o_it.product_id  
    FROM 
         orders AS o 
         JOIN 
         order_items AS o_it USING(order_id)
	WHERE 
         o.order_status IN ('delivered', 'shipped', 'invoiced', 'approved')
), 
	high_tech_products_sold AS ( # join high tech category and sold products
    SELECT 
	    DISTINCT products_sold.product_id, p.product_category_name, high_tech_categories.product_category_name_english
        #products_sold.product_id, p.product_category_name, high_tech_categories.product_category_name_english
    FROM 
        products_sold 
        JOIN 
        products AS p USING(product_id)  
        JOIN 
		high_tech_categories USING(product_category_name) 
)         
SELECT
     ht.product_category_name AS category, 
     COUNT(*) AS high_tech_sold_count,
     (SELECT COUNT(*) FROM products_sold) AS total_sold_count,
	 COUNT(*) * 100 / (SELECT COUNT(*) FROM products_sold) AS high_tech_percentage
FROM high_tech_products_sold AS ht      
GROUP BY ht.product_category_name
;
******************************/

-- What’s the average price of the products being sold? 

SELECT ROUND(AVG(price), 2)
FROM order_items;
	-- 120.65
    
# tech_products 
SELECT ROUND(AVG(price), 2)
FROM 
    order_items oi
    LEFT JOIN products p USING(product_id)
    LEFT JOIN product_category_name_translation pt USING (product_category_name)
WHERE pt.product_category_name_english IN (
      "audio", 
      "electronics", 
      "computers_accessories", 
      "pc_gamer", 
      "computers", 
      "tablets_printing_image", 
      "telephony"); #106.25

     
-- Are expensive tech products popular? * using function CASE WHEN 

SELECT 
    COUNT(oi.product_id), 
	CASE 
		WHEN price > 1000 THEN "Expensive"
		WHEN price > 100 THEN "Mid-range"
		ELSE "Cheap"
END AS price_range
FROM 
    order_items oi
    LEFT JOIN products p USING(product_id)
    LEFT JOIN product_category_name_translation pt USING (product_category_name)
WHERE pt.product_category_name_english IN (
      "audio", 
      "electronics", 
      "computers_accessories", 
      "pc_gamer", 
      "computers", 
      "tablets_printing_image", 
      "telephony")
GROUP BY price_range
ORDER BY 1 DESC;
	-- 11361 cheap
    -- 4263 mid-range
    -- 174 expensive

###### use distinct count product_id 
##### total 2431 not 3390
SELECT 
      COUNT(DISTINCT(oi.product_id)), 
	CASE 
		WHEN price > 1000 THEN "Expensive"
		WHEN price > 100 THEN "Mid-range"
		ELSE "Cheap"
END AS price_range
FROM 
    order_items oi
    LEFT JOIN products p USING(product_id)
    LEFT JOIN product_category_name_translation pt USING (product_category_name)
WHERE pt.product_category_name_english IN (
      "audio", 
      "electronics", 
      "computers_accessories", 
      "pc_gamer", 
      "computers", 
      "tablets_printing_image", 
      "telephony")
GROUP BY price_range
ORDER BY 1 DESC;
	-- 2394 cheap
    -- 984 mid-range
    -- 53 expensive


/* 2.2. In relation to the sellers: */ 
-- How many months of data are included in the magist database?
SELECT * FROM orders;
## my solution
SELECT 
    DISTINCT YEAR (order_purchase_timestamp) AS year_,
    MONTH (order_purchase_timestamp) AS month_
FROM 
    orders 
ORDER BY year_, month_; # 25 rows

## example solution
SELECT 
    TIMESTAMPDIFF(MONTH,
        MIN(order_purchase_timestamp),
        MAX(order_purchase_timestamp))
FROM
    orders;
	-- 25 months


-- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
SELECT * FROM sellers; 
SELECT * FROM order_items;
SELECT * FROM product_category_name_translation;
SELECT * FROM products;

# how many sellers? 
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    sellers;
	-- 3095

# how many tech sellers? 
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    sellers
        LEFT JOIN
    order_items USING (seller_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    pt.product_category_name_english IN (
        'audio' , 
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');
	-- 454

# What percentage of overall sellers are Tech sellers?

SELECT (454 / 3095) * 100;
	-- 14.67%
    
/*************************** my solution 
WITH high_tech_categories AS (  # filter high tech category
    SELECT  
         DISTINCT * 
    FROM 
         product_category_name_translation
    WHERE 
         product_category_name_english 
      IN (
      'audio' , 
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony'
       )
),
total_sellers AS (  # Get the total sellers (unique seller_id)
    SELECT 
        DISTINCT seller_id
    FROM 
        sellers
),
high_tech_sellers AS (  # Identify sellers who deal in Tech products
    SELECT 
         DISTINCT o_it.seller_id # p.product_id, ht.product_category_name_english, ht.product_category_name, 
    FROM 
         products AS p
         JOIN 
         high_tech_categories AS ht USING(product_category_name)
         JOIN 
         order_items AS o_it USING(product_id) 
)
SELECT 
    (SELECT COUNT(*) FROM total_sellers) AS total_sellers,  -- Total number of sellers
    (SELECT COUNT(*) FROM high_tech_sellers) AS high_tech_sellers,  -- Tech sellers count
    ROUND((SELECT COUNT(*) FROM high_tech_sellers) * 100 / (SELECT COUNT(*) FROM total_sellers), 2) AS tech_percentage  -- Percentage of Tech sellers
;
***************************************/ 

-- What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
SELECT * FROM order_items;
SELECT * FROM product_category_name_translation;
SELECT * FROM products;

-- we use price from order_items and not payment_value from order_payments as an order may contain tech and non tech product. With payment_value we can't distinguish between items in an order
# by all sellers
SELECT 
    SUM(oi.price) AS total
FROM
    order_items oi
        LEFT JOIN
    orders o USING (order_id)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled');
    -- 13494400.74

# by tech sellers
SELECT 
    SUM(oi.price) AS total
FROM
    order_items oi
        LEFT JOIN
    orders o USING (order_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled')
        AND pt.product_category_name_english IN (
        'audio' , 
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');
	-- 1666211.28


-- Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?
# of all sellers
SELECT 13494400.74/ 3095 / 25;
	-- 174.40

# of tech sellers
SELECT 1666211.28 / 454 / 25;
	-- 146.80

/* 2.3. In relation to the delivery time: */ 
-- What’s the average time between the order being placed and the product being delivered?

SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp))
FROM orders;
	-- 12.5035

-- How many orders are delivered on time vs orders delivered with a delay?

SELECT 
    CASE 
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 'Delayed' 
        ELSE 'On time'
    END AS delivery_status, 
    COUNT(DISTINCT order_id) AS orders_count
FROM orders 
WHERE order_status = 'delivered'
    AND order_estimated_delivery_date IS NOT NULL
    AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;
	-- on time 89805
    -- delayed 6665

-- Is there any pattern for delayed orders, e.g. big products being delayed more often?

SELECT
    CASE 
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) >= 100 THEN "> 100 day Delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) >= 7 AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) < 100 THEN "1 week to 100 day delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 3 AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) < 7 THEN "4-7 day delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) >= 1  AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) <= 3 THEN "1-3 day delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0  AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) < 1 THEN "less than 1 day delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) <= 0 THEN 'On time' 
    END AS "delay_range", 
    AVG(product_weight_g) AS weight_avg,
    MAX(product_weight_g) AS max_weight,
    MIN(product_weight_g) AS min_weight,
    SUM(product_weight_g) AS sum_weight,
    COUNT(DISTINCT a.order_id) AS orders_count
FROM orders a
LEFT JOIN order_items b
    USING (order_id)
LEFT JOIN products c
    USING (product_id)
WHERE order_estimated_delivery_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL
AND order_status = 'delivered'
GROUP BY delay_range;

