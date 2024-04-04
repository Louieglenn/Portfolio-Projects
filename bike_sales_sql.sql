-- DATABASE CREATION
CREATE DATABASE adven_works_db;
USE adven_works_db;


-- CREATION OF TABLES
CREATE TABLE sale(
id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
order_date DATE,
stock_date DATE,
order_number VARCHAR(10),
product_key INT, 
customer_key INT,
territory_key INT,
order_line_item INT, 
order_quantity INT,
unit_price_sold DECIMAL(6,2)
);

CREATE TABLE customer(
customer_key INT PRIMARY KEY,
prefix VARCHAR(5),
first_name VARCHAR(50),
last_name VARCHAR(50),
birth_date DATE,
marital_status VARCHAR(10),
gender VARCHAR(10),
email_address VARCHAR(100),
annual_income VARCHAR(100),
total_children INT,
education_level  VARCHAR(100),
occupation VARCHAR(100),
home_owner VARCHAR(5)
);


-- Set customer_key as PRIMARY KEY

ALTER TABLE customer
MODIFY customer_key INT PRIMARY KEY;

-- Data cleaning to convert annual_income to an INT datatype

UPDATE customer SET annual_income = REPLACE(REPLACE(annual_income, '$', ''),',','');
ALTER TABLE customer
MODIFY annual_income INT NOT NULL;

CREATE TABLE product_category(
product_category_key INT NOT NULL PRIMARY KEY,
category_name VARCHAR(100)
);

CREATE TABLE product_subcategory(
product_subcategory_key INT NOT NULL PRIMARY KEY,
subcategory_name VARCHAR(100),
product_category_key INT NOT NULL,
FOREIGN KEY (product_category_key) REFERENCES product_category(product_category_key)
);

CREATE TABLE product(
product_key INT NOT NULL PRIMARY KEY,
product_subcategory_key INT NOT NULL,
product_sku VARCHAR(100),
product_name VARCHAR(100),
model_name VARCHAR(100),
product_description VARCHAR(255) ,
product_color VARCHAR(50),
product_size VARCHAR(50),
product_style VARCHAR(50),
product_cost DECIMAL(8,2),
product_price DECIMAL(8,2),
FOREIGN KEY (product_subcategory_key) REFERENCES product_subcategory(product_subcategory_key)
);


CREATE TABLE territory(
sales_territory_key INT NOT NULL PRIMARY KEY,
region VARCHAR(100),
country VARCHAR(100),
continent VARCHAR(100)
);


-- How many customers do we have?

SELECT COUNT(*) from customer;


-- Who are the top 5 customers by items bought?

SELECT 
    CONCAT(first_name, ' ', last_name) AS customer,
    COUNT(order_quantity) AS orders
FROM
    customer
        JOIN
    sale ON sale.customer_key = customer.customer_key
GROUP BY first_name , last_name
ORDER BY orders DESC
LIMIT 5;


-- In which day of the week does sale peak?

SELECT 
    DAYNAME(order_date) AS Day, COUNT(order_quantity) AS orders
FROM
    sale
GROUP BY Day
ORDER BY orders DESC
;




-- What how much did customers with the top 10 highest salaries spend on bikes?

SELECT 
    CONCAT(first_name, ' ', last_name) AS customer,
    SUM(order_quantity * unit_price_sold) AS Spends,
    annual_income
FROM
    sale
        JOIN
    customer ON customer.customer_key = sale.customer_key
GROUP BY customer , annual_income
HAVING annual_income = (SELECT 
        MAX(annual_income)
    FROM
        customer)
ORDER BY Spends DESC
LIMIT 10
;



-- What products did the top 1 spender bought?


SELECT 
    CONCAT(first_name, ' ', last_name) AS customer,
    (order_quantity * unit_price_sold) AS Spends,
    ifnull(product.product_name, 0)
FROM
    sale
        LEFT JOIN
    customer ON customer.customer_key = sale.customer_key
        LEFT JOIN
    product ON product.product_key = sale.product_key
WHERE
    CONCAT(first_name, ' ', last_name) = (SELECT 
            CONCAT(first_name, ' ', last_name)
        FROM
            sale
                LEFT JOIN
            customer ON customer.customer_key = sale.customer_key
        GROUP BY CONCAT(first_name, ' ', last_name)
        ORDER BY SUM(order_quantity * unit_price_sold) DESC
        LIMIT 1)
GROUP BY customer , Spends , product.product_name
ORDER BY Spends DESC;



-- What is the total sale from year 2015 to 2017

SELECT 
    YEAR(order_date) AS year,
    SUM(order_quantity * unit_price_sold) AS total_sale
FROM
    sale
GROUP BY year WITH ROLLUP;


-- Which category has the highest amount of sale?

SELECT 
    category_name,
    SUM(order_quantity * product_price) AS total_sale
FROM
    sale s
        RIGHT JOIN
    product p ON p.product_key = s.product_key
        RIGHT JOIN
    product_subcategory b ON b.product_subcategory_key = p.product_subcategory_key
        JOIN
    product_category c ON c.product_category_key = b.product_category_key
GROUP BY category_name
ORDER BY total_sale DESC;
    
    
    -- Which subcategory has the highest amount of sale?

SELECT 
    subcategory_name,
    SUM(order_quantity * product_price) AS total_sale
FROM
    sale s
        LEFT JOIN
    product p ON p.product_key = s.product_key
        LEFT JOIN
    product_subcategory b ON b.product_subcategory_key = p.product_subcategory_key
GROUP BY subcategory_name
ORDER BY total_sale DESC
LIMIT 10;
    
   
   -- In which country does the highest sale occur?
   
    SELECT 
    country, SUM(order_quantity * unit_price_sold) AS total_sale
FROM
    sale s
        JOIN
    territory t ON t.sales_territory_key = s.territory_key
GROUP BY country WITH ROLLUP;

-- In what age bracket does sale peak?

SELECT 
    CASE
        WHEN
            ROUND(DATEDIFF('2017-12-30', birth_date) / 365.25,
                    0) BETWEEN 35 AND 50
        THEN
            'Middle-aged-Adults'
        WHEN
            ROUND(DATEDIFF('2017-12-30', birth_date) / 365.25,
                    0) BETWEEN 51 AND 65
        THEN
            'Senior Adults'
        ELSE 'Senior Citizen'
    END AS age_bracket,
    SUM(unit_price_sold * order_quantity) AS total_sale
FROM
    sale s
        JOIN
    customer c ON c.customer_key = s.customer_key
GROUP BY age_bracket
ORDER BY total_sale DESC;
 
 -- In which months do the bike sale peak?
 
SELECT 
    MONTHNAME(order_date) AS 'month',
    SUM(unit_price_sold * order_quantity) AS total_sale
FROM
    sale
GROUP BY month
ORDER BY total_sale DESC;
 
 -- What is the top 10 most popular product?
 
SELECT 
    product_name, SUM(order_quantity) AS total_sold
FROM
    sale s
        JOIN
    product p ON p.product_key = s.product_key
GROUP BY product_name
ORDER BY total_sold DESC
LIMIT 10;




