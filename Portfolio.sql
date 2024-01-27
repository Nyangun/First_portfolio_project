-- Creating the first table (Sales) and then Imported data from our csv file
-- Importation via the Import wizard was direct and with the not null feature it meant our entries were guaranteed of cleanliness and lacking null values

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------- STEP 1 CREATED THE TABLE (SALES) BASED ON VARIOUS DATA TYPES AND COLUMN CONDITUINING ---------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE TABLE sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10 , 2 ) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6 , 4 ) NOT NULL,
    total DECIMAL(10 , 2 ) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10 , 2 ) NOT NULL,
    gross_margin_percentage FLOAT(11 , 9 ) NOT NULL,
    gross_income DECIMAL(10 , 2 ) NOT NULL,
    rating FLOAT(2 , 1 ) NOT NULL
);
    
SELECT 
    *
FROM
    sales;

-- ------------------------------------------------- FEATURE ENGINEERING-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- STEP 2- HERE WE USE THE CASE STATEMENT TO CREATE A NEW COLUMN (time_of_date)

SELECT 
    time,
    (CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END) AS time_of_date
FROM
    sales;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- STEP 3- HERE WE ALTER THE ORIGINAL TABLE BY ADDING A NEW COLUMN (time_of_day)

ALTER TABLE sales
		ADD COLUMN time_of_day VARCHAR(20);

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- STEP 4- HERE WE POPULATE THE ORIGINAL TABLE BY ADDING DATA FROM STEP 2 INTO THE NEW COLUMN (time_of_day)

UPDATE sales
	SET time_of_day =
				(CASE
					WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning" #THIS IS THE CASE STATEMENT FROM STEP 2 THAT WE USED TO CREATE A NEW COLUMN FOR FOR TIME OF DATE
					WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
					ELSE "Evening"
				END);
                
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- STEP 5- HERE WE CREATE A NEW COLUMN (name_of_day)

select
	date,
    dayname(date) as day_name
from sales;

-- Therefore we create a new column for the table

alter table sales
add column day_name VARCHAR(10);

-- We populate the created column

UPDATE sales
SET day_name = dayname(date);

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- STEP 6- HERE WE CREATE A NEW COLUMN (month_name)
SELECT 
    date, MONTHNAME(date) AS month_name
FROM
    sales;

-- Therefore we create a new column

alter table sales
add column month_name VARCHAR(10);

-- We populate the new column

UPDATE sales 
SET 
    month_name = MONTHNAME(date);

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- STEP 7- HERE WE drop unnecessary and unessential columns

alter table sales
	drop column invoice_id, 
	drop column date,
    drop column time;
    
-- -----------------------------------------------------------------EXPLORATORY DATA ANANLYSIS (EDA)----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- STEP 8- HERE WE answer certain analytical questions using the available data

-- --------------------------GENERIC QUESTIONS------------------------------------------------------------------------------------------------------------------------------

-- 1. How many unique cities does the data have?
select
	DISTINCT city
from sales;

-- 2. In which city is each branch?
SELECT DISTINCT
    city, branch
FROM
    sales;

-- ----------------------------PRODUCT QUESTIONS---------------------------------------------------------------------------------------------------------------------

-- 1. How many unique product lines does the data have?
SELECT DISTINCT
    product_line
FROM
    sales;

-- 2. What is the most common payment method?
SELECT 
    payment_method, COUNT(payment_method) AS frequency
FROM
    sales
GROUP BY payment_method
ORDER BY frequency DESC;

-- 3. What is the most selling product line?
SELECT 
    product_line, COUNT(product_line) AS frequency
FROM
    sales
GROUP BY product_line
ORDER BY frequency DESC;

-- 4. What is the total revenue by month?
SELECT 
    month_name, SUM(total) AS total_revenue
FROM
    sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 5. What month had the largest COGS?
SELECT 
    month_name, SUM(cogs) AS cost_of_goods
FROM
    sales
GROUP BY month_name
ORDER BY cost_of_goods DESC;

-- 6. What product line had the largest revenue?
SELECT 
    product_line, SUM(total) AS total_revenue
FROM
    sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- 5. What is the city with the largest revenue?
SELECT 
    city, SUM(total) AS total_revenue
FROM
    sales
GROUP BY city
ORDER BY total_revenue DESC; 

-- 6. What product line had the largest VAT?
SELECT 
    product_line, SUM(VAT) AS total_vat
FROM
    sales
GROUP BY product_line
ORDER BY total_vat DESC;

-- 7. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
-- Adding a column as per the question
alter table sales
add column remarks VARCHAR(10);
-- Create a temporary table to store product_line and its average total

create TEMPORARY table temp_avg_total as
select
	product_line,
    avg(total) as avg_total
from sales
group by product_line;

-- Populating the column
UPDATE sales
        JOIN
    temp_avg_total t ON sales.product_line = t.product_line 
SET 
    sales.remarks = (CASE
        WHEN sales.total > t.avg_total THEN 'Good'
        ELSE 'Bad'
    END);

-- Dropping the temporary table
drop temporary table if exists temp_avg_total; 

-- 8. Which branch sold more products than average product sold?
SELECT 
    branch, SUM(quantity) AS products_sold
FROM
    sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT 
        AVG(quantity)
    FROM
        sales);

-- 9. What is the most common product line by gender?
SELECT 
    product_line, gender, COUNT(gender) AS gender_count
FROM
    sales
GROUP BY product_line , gender
ORDER BY gender_count DESC;

-- 10. What is the average rating of each product line?
SELECT 
    product_line, round(AVG(rating), 2) AS average_rating
FROM
    sales
GROUP BY product_line
ORDER BY average_rating DESC;

-- --------------------------------------- SALES QUESTIONS-----------------------------------

-- 1. Number of sales made in each time of the day per weekday
SELECT 
    time_of_day, COUNT(*) AS number_of_sales
FROM
    sales
GROUP BY time_of_day
ORDER BY number_of_sales DESC;

-- 2. Which of the customer types brings the most revenue?
SELECT 
    customer_type, SUM(total) AS total_revenue
FROM
    sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- 3. Which city has the largest tax percent/ VAT (**Value Added Tax**)?
SELECT 
    city, AVG(VAT) AS tax_percent
FROM
    sales
GROUP BY city
ORDER BY tax_percent DESC; 

-- 4. Which customer type pays the most in VAT?
SELECT 
    customer_type, SUM(VAT) AS total_vat
FROM
    sales
GROUP BY customer_type
ORDER BY total_vat DESC;

-- -----------------------------CUSTOMER CALCULATIONS-----------------------------

-- 1. How many unique customer types does the data have?
SELECT DISTINCT
    customer_type
FROM
    sales;

-- 2. How many unique payment methods does the data have?
SELECT DISTINCT
    payment_method
FROM
    sales; 
    
-- 3. What is the most common customer type?
SELECT 
    customer_type, COUNT(*) AS count
FROM
    sales
GROUP BY customer_type
ORDER BY count DESC;

-- 4. Which customer type buys the most?
SELECT 
    customer_type, COUNT(*) AS frequency
FROM
    sales
GROUP BY customer_type
ORDER BY frequency DESC; 

-- 5. What is the gender of most of the customers?
SELECT 
    gender, COUNT(*) AS gender_count
FROM
    sales
GROUP BY gender
ORDER BY gender_count DESC;

-- 6. What is the gender distribution per branch?
SELECT 
    branch, gender, COUNT(gender) AS gender_count
FROM
    sales
GROUP BY branch, gender
ORDER BY branch; 

-- 7. Which time of the day do customers give most ratings?
SELECT 
    time_of_day, round(Avg(rating), 2) AS avg_rating
FROM
    sales
GROUP BY time_of_day
ORDER BY avg_rating DESC; 

-- 8. Which time of the day do customers give most ratings per branch?
SELECT 
    time_of_day, Round(AVG(rating), 2) as avg_rating
FROM
    sales
where branch = 'A'                            # Here we input the branch name we want to query as per the question
GROUP BY branch , time_of_day
ORDER BY avg_rating desc; 

-- 9. Which day fo the week has the best avg ratings?
SELECT 
    day_name, ROUND(AVG(rating), 2) AS avg_rating
FROM
    sales
GROUP BY day_name
ORDER BY avg_rating DESC; 

-- 10. Which day of the week has the best average ratings per branch?
SELECT 
    day_name, ROUND(AVG(rating), 2) AS avg_rating
FROM
    sales
where branch = 'A'          # Here we input the branch values we want to query as per the question
GROUP BY branch, day_name
ORDER BY avg_rating desc; 















