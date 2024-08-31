SET search_path to laptop_schema;


-- Part A (Market and Value Analysis)


-- /******************************/


-- Q1: Average price of laptops for each brand
-- What is the average price of laptops for each brand?


SELECT brand, 
	COUNT(*) AS laptop_count, 
	ROUND(AVG(price), 2) AS avg_price
FROM laptops
GROUP BY brand
ORDER BY avg_price DESC;




   
   
-- Q2: Correlation between price and spec score
-- What is the correlation between price and spec score?


SELECT ROUND(CORR(price, spec_score)::NUMERIC, 2) AS correlation
FROM laptops;




-- Q3: Price difference between NVIDIA and other graphics cards
-- Is there a significant price difference between laptops with 
-- NVIDIA graphics cards and those with other graphics card?


SELECT 
    CASE 
        WHEN graphics_card ILIKE '%Nvidia%' THEN 'NVIDIA Graphics'
        ELSE 'Other Graphics'
    END AS graphics_type,
    COUNT(*) AS laptop_count,
    ROUND(AVG(price), 2) AS average_price
FROM laptops
GROUP BY 
    CASE 
        WHEN graphics_card ILIKE '%Nvidia%' THEN 'NVIDIA Graphics'
        ELSE 'Other Graphics'
    END;





   
-- Q4: Most common OS in laptops priced over 100,000
-- Which operating system is most common among laptops priced over 100,000?


SELECT os, COUNT(*) AS laptop_count
FROM laptops
WHERE price > 100000
GROUP BY os
ORDER BY laptop_count DESC;





-- Q5: Relationship between RAM capacity and price
-- What is the relationship between RAM capacity and price?


WITH ram_extracted AS (
    SELECT 
        price,
        CASE 
            WHEN internal_memory LIKE '%TB%' THEN 
                CAST(SUBSTRING(UPPER(internal_memory) FROM '[0-9]+(?=\s*TB)') AS INTEGER) * 1024
            WHEN internal_memory LIKE '%GB%' THEN 
                CAST(SUBSTRING(UPPER(internal_memory) FROM '[0-9]+(?=\s*GB)') AS INTEGER)
            ELSE 0
        END AS ram_gb
    FROM laptops
),
ram_categories AS (
    SELECT 
        CASE 
            WHEN ram_gb <= 128 THEN '0-128 GB'
            WHEN ram_gb <= 512 THEN '129-512 GB'
            ELSE '513+ GB'
        END AS ram_category,
        price
    FROM ram_extracted
)
SELECT 
    ram_category,
    COUNT(*) AS laptop_count,
    ROUND(AVG(price), 2) AS avg_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM ram_categories
GROUP BY ram_category
ORDER BY 
    CASE 
        WHEN ram_category = '0-128 GB' THEN 1
        WHEN ram_category = '129-512 GB' THEN 2
        WHEN ram_category = '513+ GB' THEN 3
    END;
	






-- Q6: Average price of laptops with a spec score above 70
-- What is the average price of laptops with a spec score above 70?


SELECT ROUND(AVG(price), 2) AS avg_price_above_70_spec_score
FROM laptops
WHERE spec_score > 70;






-- Q7: Top 5 laptop brands with highest average user rating
-- Which are laptop brands have the top 5 highest average user rating?


SELECT brand, ROUND(AVG(user_rating), 1) AS avg_user_ratings
FROM laptops
GROUP BY brand
ORDER BY avg_user_ratings DESC
LIMIT 5;

   


-- Q8: Average warranty period by brand
-- What is the average warranty period offered by each brand?


SELECT brand, 
       ROUND(AVG(CAST(SUBSTRING(warranty FROM '[0-9]+') AS INTEGER)), 2) AS avg_warranty_years
FROM laptops
GROUP BY brand
ORDER BY avg_warranty_years DESC;






-- Q9: Brand market share across different price segments
-- How does the market share of different brands vary across different 
-- price segments (budget, mid-range, premium)?


-- first, create price segments for the laptops

-- Budget: at least 40,000 
-- Mid-range: 40,001 - 100,000,
-- Premium: above 100,000

-- then find the market share, which is:
-- (brand laptop count / total laptop count in price segment) * 100

-- I will create a view to have a consistent price segment for all questions

-- create view of the laptop price segment

CREATE VIEW laptop_price_segments AS
SELECT 
    id,
	brand,
	name, 
    price,
    CASE WHEN price <= 40000 THEN 'Budget'
         WHEN price BETWEEN 40001 AND 100000 THEN 'Mid-range'
         ELSE 'Premium' END AS price_segment
FROM laptops;


WITH brand_cte AS (
SELECT brand, price_segment, COUNT(*) AS laptop_count
FROM laptop_price_segments
GROUP BY brand, price_segment
)
SELECT price_segment, brand,
	   laptop_count,
	   SUM(laptop_count) OVER(PARTITION BY price_segment) AS total_in_segment,
	   ROUND(100.0 * laptop_count / 
					SUM(laptop_count) OVER(PARTITION BY price_segment), 2) AS market_share
FROM brand_cte
ORDER BY price_segment, market_share DESC;




-- Q10: Average user rating in different utility categories
-- What is the average user rating for laptops in different utility categories 
-- (e.g., gaming, business, everyday use) across brands?


SELECT utility, ROUND(AVG(user_rating), 2) AS avg_user_rating
FROM laptops
WHERE utility IS NOT NULL
GROUP BY utility
ORDER BY avg_user_rating DESC;






-- Q11: Comparison of Gaming Laptop Brands 
-- Among the laptops specifically marketed as gaming devices, which brand offers 
-- the highest number, and how does this compare to other gaming-focused 
-- brands in the dataset?

-- I will only consider laptops listed as Gaming Laptop in their name,
-- or exactly for Gaming in the utility



WITH gaming_brands_cte AS
(
SELECT brand, 
	COUNT(*) AS num_of_gaming_laptop, 
	ROUND(AVG(price), 2) AS avg_price, 
	ROUND(AVG(spec_score), 2) AS avg_spec_score
FROM laptops
WHERE name LIKE '%Gaming%' OR utility = 'Gaming'
GROUP BY brand
)
SELECT brand, 
	num_of_gaming_laptop, 
	CONCAT(ROUND(100.0 * num_of_gaming_laptop / 
		  (SELECT SUM(num_of_gaming_laptop) FROM gaming_brands_cte), 2), '%')
		  AS gaming_market_share,
		  avg_price,
		  avg_spec_score
FROM gaming_brands_cte
ORDER BY num_of_gaming_laptop DESC;







-- Q12: Price-Rating Discrepancy Within Generations
-- Which laptops have a higher than average price but lower than average 
-- user ratings within their processor generation?
-- Output the top 3 laptops in each generation with the biggest 
-- price discrepancies.



WITH gen_cte AS
(
SELECT processor_gen, 
	ROUND(AVG(price), 2) AS gen_avg_price, 
	ROUND(AVG(user_rating), 2) AS gen_avg_user_rating
FROM laptops
WHERE processor_gen IS NOT NULL
GROUP BY processor_gen
)
, ranked_laptops AS 
(
SELECT l.processor_gen, l.name, l.price, l.user_rating, 
	   g.gen_avg_price, g.gen_avg_user_rating,
	(l.price - g.gen_avg_price) AS price_diff,
        (g.gen_avg_user_rating - l.user_rating) AS rating_diff,
        ROW_NUMBER() OVER(PARTITION BY l.processor_gen 
        ORDER BY (l.price - g.gen_avg_price) - (l.user_rating - g.gen_avg_user_rating) DESC) AS row_num
    FROM laptops l
    JOIN gen_cte g ON l.processor_gen = g.processor_gen
    WHERE l.price > g.gen_avg_price AND l.user_rating < g.gen_avg_user_rating
)
SELECT 
    processor_gen, name,
    price, user_rating, 
	gen_avg_price, gen_avg_user_rating,
    price_diff, rating_diff
FROM ranked_laptops
WHERE row_num <= 3
ORDER BY processor_gen, row_num;






-- Q13: Top-Tier Utility Laptops
-- Identify the most expensive laptop in each utility category 
-- (e.g., Gaming, Business, Everyday Use).
-- Output: List showing utility category, most expensive laptop, and its price.



SELECT utility, name AS most_expensive_laptop, price
FROM
(
SELECT utility, 
	name, 
	price, 
	RANK() OVER(PARTITION BY utility ORDER BY price DESC) AS price_rank
FROM laptops
WHERE utility IS NOT NULL
) AS ranked_laptops
WHERE price_rank = 1
ORDER BY price DESC;






-- Q14: Elite Performance Laptops: Triple Top 100 Analysis
-- Find laptops that simultaneously appear in the top 100 rankings 
-- for price, spec score, and user rating


WITH most_expensive_laptops AS
(
SELECT brand, name, price, spec_score, user_rating
FROM laptops
ORDER BY price DESC
LIMIT 100
)
, high_performance_laptops AS
(
SELECT brand, name, price, spec_score, user_rating
FROM laptops
ORDER BY spec_score DESC
LIMIT 100
)
, most_rated_laptops AS
(
SELECT brand, name, price, spec_score, user_rating
FROM laptops
ORDER BY user_rating DESC
LIMIT 100
)
SELECT * 
FROM most_expensive_laptops
INTERSECT
SELECT *
FROM high_performance_laptops
INTERSECT
SELECT *
FROM most_rated_laptops
ORDER BY spec_score DESC;





-- Q15: Best Value High-Performance Laptops by Processor Brand
-- Identify the top 5 laptops with the best value (lowest price-to-spec score ratio) 
-- for Intel and AMD processors separately, considering only laptops with a 
-- spec score above 70.



WITH value_laptops AS (
    SELECT 
        brand, name, price, spec_score,
        CASE 
            WHEN processor_brand ILIKE '%Intel%' THEN 'Intel'
            WHEN processor_brand ILIKE '%AMD%' THEN 'AMD'
            ELSE 'Other'
        END AS processor_type,
        ROUND(price::DECIMAL / spec_score, 2) AS price_to_spec_ratio,
        ROW_NUMBER() OVER (
            PARTITION BY 
                CASE 
                    WHEN processor_brand ILIKE '%Intel%' THEN 'Intel'
                    WHEN processor_brand ILIKE '%AMD%' THEN 'AMD'
                    ELSE 'Other'
                END
            ORDER BY (price::DECIMAL / spec_score) ASC
        ) AS rank
    FROM laptops 
    WHERE spec_score > 70
)
SELECT 
    processor_type, brand, name, price, spec_score, price_to_spec_ratio
FROM value_laptops
WHERE processor_type IN ('Intel', 'AMD') AND rank <= 5
ORDER BY processor_type, price_to_spec_ratio;






-- Q16: Percentage of Laptops with Touch Screen
-- What percentage of laptops offer touch screen functionality, 
-- and how does this correlate with price?


-- percentage of laptops with touch screen feature

SELECT 
	CONCAT(ROUND(100.0 * SUM(CASE WHEN screen_feature LIKE '%Touch Screen%' 
							 THEN 1 ELSE 0 END) 
		  / COUNT(*), 2), '%') AS pct_of_laptops_with_touch_screen
FROM laptops;


-- showing how touch screen functionality correlates with price


WITH touch_screen_cte AS
(
SELECT 
    lps.price_segment AS price_segment,
    ROUND(AVG(l.price), 2) AS avg_price_all,
    ROUND(AVG(CASE WHEN l.screen_feature LIKE '%Touch Screen%' 
			  THEN l.price END), 2) AS avg_price_touch_screen,
    SUM(CASE WHEN l.screen_feature LIKE '%Touch Screen%' 
		THEN 1 ELSE 0 END) AS touch_screen_laptop_count,
    COUNT(*) AS total_laptops
FROM laptops l
JOIN laptop_price_segments lps ON l.id = lps.id  -- from laptop_price_segments view
GROUP BY lps.price_segment
)
SELECT *, 
    ROUND(100.0 * touch_screen_laptop_count / 
		  total_laptops, 2) AS perc_of_touch_screen_laptop
FROM touch_screen_cte
ORDER BY price_segment;






-- Q17: Biometric Security Adoption Analysis 
-- Analyze the adoption rate of fingerprint sensors across different 
-- price ranges.


-- showing percentage of laptops with fingerprint sensors

SELECT 
	CONCAT(ROUND(100.0 * SUM(CASE WHEN hardware_features LIKE '%Fingerprint Sensor%' 
							 THEN 1 ELSE 0 END) 
		  / COUNT(*), 2), '%') AS pct_of_laptops_with_fingerprint_sensor
FROM laptops;


-- showing % of laptops with fingerprint sensor by price segment



WITH fingerprint_sensor_cte AS
(
SELECT lps.price_segment AS price_segment,
	ROUND(AVG(l.price), 2) AS avg_price_all,
	ROUND(AVG(CASE WHEN l.hardware_features LIKE '%Fingerprint Sensor%' 
			  THEN l.price END), 2) AS avg_price_fingerprint_sensor,
	SUM(CASE WHEN L.hardware_features LIKE '%Fingerprint Sensor%' 
		THEN 1 ELSE 0 END) AS fingerprint_laptop_count,
	COUNT(*) AS total_laptops
FROM laptops l
JOIN laptop_price_segments lps ON l.id = lps.id  -- from laptop_price_segments view
GROUP BY lps.price_segment
)
SELECT *, 
	ROUND(100.0 * fingerprint_laptop_count / 
		  total_laptops , 2) 
	AS perc_of_laptop_with_fingerprint_sensor
FROM 
fingerprint_sensor_cte;









--
