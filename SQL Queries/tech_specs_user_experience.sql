SET search_path TO laptop_schema;

-- Part B (Technical Specifications and User Experience)


/**************************************/


-- Q1: Average spec score across different processor brands
-- How does the average spec score vary across different processor brands?


SELECT brand, COUNT(*) AS laptop_count, 
	   ROUND(AVG(spec_score), 2) AS avg_spec_score
FROM laptops
GROUP BY brand
ORDER BY avg_spec_score DESC;






-- Q2: Percentage of laptops with SSD storage
-- What percentage of laptops in the dataset have SSD storage?


SELECT CONCAT(ROUND(100.0 * SUM(CASE WHEN internal_memory LIKE '%SSD%' THEN 1 ELSE 0 END) 
			 / COUNT(*), 2), '%') AS pct_ssd_laptops
FROM laptops;






-- Q3: Distribution of processor cores across laptop utilities
-- How does the distribution of processor cores vary across different laptop utilities 
-- (e.g., business, gaming, everyday use)?


SELECT utility, processor_core, COUNT(*) AS laptop_count
FROM laptops
WHERE utility IS NOT NULL AND processor_core IS NOT NULL
GROUP BY utility, processor_core
ORDER BY utility DESC, laptop_count DESC;






-- Q4: Distribution of Intel vs. AMD processors
-- What is the distribution of laptops with Intel vs. AMD processors?



SELECT processor_brand, COUNT(*) AS laptop_count
FROM laptops
WHERE processor_brand IS NOT NULL
GROUP BY processor_brand
ORDER BY laptop_count DESC;






-- Q5: Types and frequency of ROM memory
-- What are the different types of ROM memory available 
-- in the laptops, and how frequently do they occur?


SELECT rom_memory, COUNT(*) AS laptop_count
FROM laptops
GROUP BY rom_memory
ORDER BY laptop_count DESC;







-- Q6: Common graphics card brands in high-rated laptops
-- Which graphics card brands are most commonly used in high-rated laptops?


-- define high-rated laptops as those that fall within the 
-- top 10% of their spec_score values

-- Identify the laptops in the 90th percentile of spec_score


WITH spec_score_distribution AS (
    SELECT spec_score, 
           NTILE(10) OVER (ORDER BY spec_score DESC) AS percentile_rank
    FROM laptops
)
SELECT graphics_card, COUNT(*) AS laptop_count
FROM laptops
WHERE spec_score IN (
    SELECT spec_score 
    FROM spec_score_distribution 
    WHERE percentile_rank = 1
)
GROUP BY graphics_card
ORDER BY laptop_count DESC;







-- Q7: Common RAM and storage combinations across processor generations
-- What is the most common combination of RAM and storage capacity, and how has this 
-- changed across different processor generations?


WITH memory_cte AS 
(
SELECT processor_gen 
    AS proc_gen, 
    CONCAT(TRIM(REGEXP_SUBSTR(rom_memory, '([0-9]+\s?GB)')), 
        ' + ',
      TRIM(REGEXP_SUBSTR(internal_memory, '([0-9]+\s?(GB|TB)\s?SSD)'))) 
	AS ram_storage_combo
FROM laptops
WHERE processor_gen LIKE '%_Gen%'
    OR processor_gen LIKE 'M%'
),ranked_combos AS 
(
SELECT proc_gen, 
    ram_storage_combo, 
    COUNT(*) AS laptop_count,
    RANK() OVER (PARTITION BY proc_gen 
        ORDER BY COUNT(*) DESC) 
    AS rank_in_gen,
    RANK() OVER (ORDER BY COUNT(*) DESC) 
    AS overall_rank
  FROM memory_cte
  GROUP BY proc_gen, ram_storage_combo
)
SELECT 
  proc_gen, 
  ram_storage_combo, 
  laptop_count,
  rank_in_gen,
  overall_rank
FROM ranked_combos
WHERE rank_in_gen = 1 
    OR overall_rank <= 5
ORDER BY REGEXP_SUBSTR(proc_gen, 'M'),
REGEXP_SUBSTR(proc_gen, '[0-9]+')::INTEGER, 
laptop_count DESC;




-- Breakdown of the Query:

-- Part 1: Extract ROM memory
-- TRIM(REGEXP_SUBSTR(rom_memory, '([0-9]+\s?GB)'))

-- REGEXP_SUBSTR Function:
-- This function extracts a substring from a string based on a regular expression pattern.

-- In this case, REGEXP_SUBSTR(rom_memory, '([0-9]+\s?GB)'):
-- Extracts a substring from the 'rom_memory' field that matches the pattern:

-- One or more digits ([0-9]+)
-- Optionally followed by whitespace (\s?)
-- Followed by "GB"
-- * Examples:
--   - If rom_memory is "16 GB LPDDR5 RAM", it extracts "16 GB"
--   - If rom_memory is ""8 GB DDR4 RAM"", it extracts "8 GB"

-- TRIM Function:
-- * Removes any leading or trailing whitespace from the extracted substring.
-- * Example: If REGEXP_SUBSTR extracts " 16 GB ", TRIM will return "16 GB"

-- Separator
' + '
-- This is a literal string that will be used to join the two parts.


-- Part 2: Extract internal memory

-- TRIM(REGEXP_SUBSTR(internal_memory, '([0-9]+\s?(GB|TB)\s?SSD)'))

-- REGEXP_SUBSTR Function:
-- In this case, REGEXP_SUBSTR(internal_memory, '([0-9]+\s?(GB|TB)\s?SSD)'):
-- Extracts a substring from the 'internal_memory' field that matches the pattern:
-- One or more digits ([0-9]+)
-- Optionally followed by whitespace (\s?)
-- Followed by either "GB" or "TB" ((GB|TB))
-- Optionally followed by whitespace (\s?)
-- Followed by "SSD"

-- Examples:
-- If internal_memory is "512 GB SSD", it extracts "512 GB SSD"
-- If internal_memory is "1 TB HARD Disk, 256 GB SSD", it extracts "256 SSD"

-- TRIM Function:
-- As before, removes any leading or trailing whitespace from the extracted substring.

-- Complete Examples:
-- If rom_memory is "16 GB LPDDR5 RAM" and internal_memory is "1 TB HARD Disk, 256 GB SSD":
--   Result: "16 GB + 256GB SSD"
-- If rom_memory is "8 GB LPDDR5 RAM" and internal_memory is "1 TB SSD":
--   Result: "8 GB + 1 TB SSD"







-- Q8: Average number of USB ports in different price ranges
-- What is the average number of USB ports for laptops in different 
-- price ranges?



WITH usb_ports_cte AS
(
SELECT 
	id,
	price, 
	usb_ports,
    (
        SELECT SUM(CAST(num AS INTEGER))
        FROM (
            SELECT REGEXP_SUBSTR(TRIM(part), '^[0-9]+') AS num
            FROM UNNEST(STRING_TO_ARRAY(REPLACE(usb_ports, ' x ', ','), ',')) AS part
        ) AS numbers
        WHERE num != ''
    ) AS total_usb_ports
FROM laptops
)
SELECT lps.price_segment AS price_segment,
	    COUNT(*) AS laptop_count,
		ROUND(AVG(usb.total_usb_ports), 2) AS avg_usb_ports
FROM laptop_price_segments lps -- from laptop_price_segment view
JOIN usb_ports_cte usb ON lps.id = usb.id
GROUP BY lps.price_segment;





-- Breakdown of the Query:

-- REPLACE(usb_ports, ' x ', ','):
-- This function replaces occurrences of " x " (with spaces) in the 
-- usb_ports string with a comma (,). 
-- This is important because it standardizes the format of the string, 
-- making it easier to split later.
-- For example, "2 x USB 3.0, 1 x USB Type-C" becomes "2, 1".


-- STRING_TO_ARRAY(..., ','):
-- This function takes the modified string and splits it into an 
-- array based on the comma delimiter.
-- Continuing the previous example, "2, 1" would become an array: ['2', '1'].


-- UNNEST(...) AS part:
-- This function takes the array created by STRING_TO_ARRAY and expands it 
-- into a set of rows, where each element of the array becomes a separate row.
-- For example, the array ['2', '1'] would produce two rows: one with "2" and 
-- another with "1".

-- REGEXP_SUBSTR(TRIM(part), '^[0-9]+') AS num:
-- This extracts the numeric part from each trimmed part. 
-- The TRIM function removes any leading or trailing spaces.
-- The regular expression '^[0-9]+' matches one or more digits at the 
-- beginning of the string. So, if part is "2", it extracts "2".


-- SUM(CAST(num AS INTEGER)):
-- This part of the query sums up all the extracted numbers 
-- (converted to integers) from the inner query. The inner query 
-- collects all the numeric values extracted from the usb_ports column.

-- WHERE num != '':
-- This condition filters out any empty strings that might result from 
-- the extraction process, ensuring that only valid numbers are summed.


-- Overall Query Logic:
-- The outer query selects the usb_ports column and calculates the 
-- total number of USB ports for each row.

-- For each row in the laptops table, it:
-- Replaces " x " with a comma to standardize the format.
-- Splits the modified string into an array of individual components.
-- Expands that array into multiple rows.
-- Extracts the numeric portion from each component.
-- Sums those numbers to get the total count of USB ports for that row.








-- Q9: Feature-Rich High-Performance Laptops
-- Identify the laptops that have more than five distinct hardware features and
-- port connections (e.g., Backlit Keyboard, Thunderbolt, etc.). For these laptops, 
-- determine which have at least a spec score of 90.



WITH features_cte AS (
SELECT name, 
	price, 
	spec_score, 
	ARRAY_LENGTH(STRING_TO_ARRAY(
		CONCAT(port_connection, ', ', hardware_features), ', '), 1) 
	AS features_count
FROM laptops
)
SELECT name, price, spec_score, features_count
FROM features_cte
WHERE features_count > 5 AND spec_score >= 90
ORDER BY spec_score DESC;



-- Explanation:

-- STRING_TO_ARRAY(features, ','):
-- This function splits the features string into an array using a 
-- comma as the delimiter. For example, "HDMI, Multi Card Reader, 
-- Backlit Keyboard, Inbuilt Microphone" becomes an array with four elements.

-- ARRAY_LENGTH(..., 1):
-- This function counts the number of elements in the array created 
-- by STRING_TO_ARRAY. The second argument 1 specifies that we 
-- want the length of the first dimension of the array.





-- Q10: Above-Average Spec Scores Within Brand and Price Range
-- Identify the top 5 laptops that have a higher spec score than the 
-- average spec score of laptops in their same price range and brand.



WITH relevant_data AS (
SELECT lps.brand, lps.name,
	   lps.price_segment,
	   lps.price, 
	   l.spec_score
FROM laptops l
JOIN laptop_price_segments lps
ON l.id = lps.id
)
, brand_cte AS (
SELECT brand, ROUND(AVG(spec_score), 2) AS brand_avg_spec_score
FROM relevant_data
GROUP BY brand
)
, price_segment_cte AS (
SELECT price_segment, ROUND(AVG(spec_score), 2) AS price_segment_avg_spec_score
FROM relevant_data
GROUP BY price_segment
)
, ranked_laptops AS (
SELECT r.brand, r.name, r.price_segment, 
	   r.price, r.spec_score, 
	   b.brand_avg_spec_score, 
	   p.price_segment_avg_spec_score,
	   ROW_NUMBER() OVER(PARTITION BY r.price_segment ORDER BY r.spec_score DESC) AS rank
FROM relevant_data r
JOIN brand_cte b ON r.brand = b.brand
JOIN price_segment_cte p ON r.price_segment = p.price_segment
WHERE r.spec_score > b.brand_avg_spec_score
AND r.spec_score > p.price_segment_avg_spec_score
)
SELECT *
FROM ranked_laptops
WHERE rank <= 5;







-- Q11: Average weight across screen size categories
-- How does the average weight of laptops differ across screen size categories?


WITH screen_size_cte AS (
SELECT 
    CAST(REGEXP_SUBSTR(screen_size, '[0-9]+(\.[0-9]+)?') AS DECIMAL(4,1)) AS screen_size_inches,
	weight
FROM 
    laptops
)
SELECT CASE WHEN screen_size_inches <= 14 THEN '14" and below'
	        WHEN screen_size_inches BETWEEN 14.1 AND 15.9 THEN '14" - 15"'
			ELSE '16" and above' END AS screen_size_category,
			ROUND(AVG(weight), 2) AS avg_weight
FROM screen_size_cte
GROUP BY CASE WHEN screen_size_inches <= 14 THEN '14" and below'
	        WHEN screen_size_inches BETWEEN 14.1 AND 15.9 THEN '14" - 15"'
			ELSE '16" and above' END
ORDER BY avg_weight DESC;






-- Breakdown of the Query:
-- REGEXP_SUBSTR(screen_size, '[0-9]+(\.[0-9]+)?')

-- REGEXP_SUBSTR Function:
-- * This function extracts a substring from a string based on a regular expression pattern.

-- * In this case, REGEXP_SUBSTR(screen_size, '[0-9]+(\.[0-9]+)?'):
--   * Extracts a substring from the 'screen_size' field that matches the pattern:
--     - One or more digits ([0-9]+)
--     - Optionally followed by a decimal point and one or more digits ((\.[0-9]+)?)
-- * Examples:
--   - If screen_size is "15.6 inch display", it extracts "15.6"
--   - If screen_size is "17 inch screen", it extracts "17"
--   - If screen_size is "13.3-inch Average", it extracts "13.3"

-- Regular Expression Breakdown:
-- '[0-9]+': Matches one or more digits
-- '(\.[0-9]+)?': 
--   * '\.': A literal decimal point
--   * '[0-9]+': One or more digits after the decimal point
--   * '(...)?' : The entire decimal part is optional

-- - The '?' at the end:
-- * This question mark makes the entire grouped pattern (\.[0-9]+) optional.
-- * It means the regular expression will match:
--   - Just the whole number part (e.g., "15")
--   - OR the whole number part followed by a decimal point and more digits (e.g., "15.6")

-- The query is designed to extract the numeric part of a screen size, 
-- including decimal places if present. It's flexible enough to handle 
-- various formats of screen size specifications, whether they include 
-- decimal places or not.






-- Q12: Brands with a Wide Range of Screen Sizes
-- Which brands have laptops with a wide range of screen sizes?


SELECT brand, 
    MIN(screen_size_inches) AS min_screen_size, 
    MAX(screen_size_inches) AS max_screen_size, 
    (MAX(screen_size_inches) - MIN(screen_size_inches)) AS screen_size_range
FROM
(
    SELECT brand, 
        CAST(REGEXP_SUBSTR(screen_size, '[0-9]+(\.[0-9]+)?') 
			 AS DECIMAL(4,1)) AS screen_size_inches
    FROM laptops
) AS brand_screen_size
GROUP BY brand
-- add a HAVING clause to filter out brands with only 
-- one screen size (where the range is 0).
HAVING COUNT(DISTINCT screen_size_inches) > 1  
ORDER BY screen_size_range DESC;







-- Q13: Weight-to-Screen Size Ratio Analysis
-- Calculate the ratio of weight to screen size for all laptops. 
-- Identify the top 10 laptops with the lowest ratio (lightest for 
-- their screen size) and the bottom 10 (heaviest for their screen size). 
-- How do these laptops compare in terms of performance and price?



WITH relevant_data AS (
    SELECT name, 
           spec_score,
           price,
           ROUND(1.0 * weight / 
				 CAST(REGEXP_SUBSTR(screen_size, '[0-9]+(\.[0-9]+)?') 
					  AS DECIMAL(3,1)), 2) AS ws_ratio
    FROM laptops
    WHERE weight IS NOT NULL AND screen_size IS NOT NULL
),
lightest_laptops AS (
    SELECT 'Lightest laptop' AS weight_screen_category, 
           name, 
           ws_ratio, 
           price, 
           spec_score
    FROM relevant_data
    ORDER BY ws_ratio ASC
    LIMIT 10
),
heaviest_laptops AS (
    SELECT 'Heaviest laptop' AS weight_screen_category, 
           name, 
           ws_ratio, 
           price, 
           spec_score
    FROM relevant_data
    ORDER BY ws_ratio DESC
    LIMIT 10
)
SELECT *, 
	ROUND(AVG(spec_score) OVER(), 2) AS avg_spec_score,
	ROUND(AVG(price) OVER(), 2) AS avg_price 
FROM lightest_laptops
UNION ALL
SELECT *,
	ROUND(AVG(spec_score) OVER(), 2) AS avg_spec_score,
	ROUND(AVG(price) OVER(), 2) AS avg_price 
FROM heaviest_laptops;







-- Q14: Highest user-rated laptops and their price comparison
-- Which laptops have the highest user rating, and how does their price 
-- compare to the average?


-- define highest user_rated laptops as those with maximum user rating


WITH highest_rated_laptops AS (
SELECT name, user_rating, price
FROM laptops 
WHERE user_rating = (SELECT MAX(user_rating) FROM laptops)
)
, average_cte AS (
SELECT ROUND(AVG(price), 2) AS avg_price
FROM laptops
)
SELECT name, user_rating, price, avg_price, 
	   (price - avg_price) AS price_diff, 
	   ROUND(100.0 * (price - avg_price)/(avg_price), 2) AS percent_diff
FROM highest_rated_laptops
CROSS JOIN average_cte
ORDER BY percent_diff DESC;






-- Q15: Correlation between user votes and user rating
-- Is there a correlation between the number of user votes and the user rating?


SELECT ROUND(CORR(user_votes, user_rating)::NUMERIC, 2) AS correlation
FROM laptops;







-- Q16: Average User Rating For Different Screen Sizes
-- How does the average user rating change for laptops with different screen sizes?



WITH screen_size_cte AS (
SELECT 
    CAST(REGEXP_SUBSTR(screen_size, '[0-9]+(\.[0-9]+)?') 
		 AS DECIMAL(4,1)) AS screen_size_inches,
	user_rating,
	ROUND(AVG(user_rating) OVER(), 2) AS overall_avg
FROM 
    laptops
)
SELECT CASE WHEN screen_size_inches <= 14 THEN '14" and below'
	        WHEN screen_size_inches BETWEEN 14.1 AND 15.9 THEN '14" - 15"'
			ELSE '16" and above' END AS screen_size_category,
			ROUND(AVG(user_rating), 2) AS avg_rating,
			COUNT(*) AS laptop_count,
			MAX(overall_avg) AS overall_avg
FROM screen_size_cte
GROUP BY CASE WHEN screen_size_inches <= 14 THEN '14" and below'
	        WHEN screen_size_inches BETWEEN 14.1 AND 15.9 THEN '14" - 15"'
			ELSE '16" and above' END;





-- Q17: Battery Life Across Utility Category
-- What is the average battery life across different laptop utilities 
-- (e.g., gaming, business)?


SELECT utility, 
    ROUND(
		AVG(
		CAST(TRIM(REPLACE(SPLIT_PART(battery, 'Wh', 1), ' ', '')) 
			 AS DECIMAL(4, 1))), 2)
		AS avg_battery_life
FROM laptops
WHERE battery LIKE '%Wh%' AND utility IS NOT NULL
GROUP BY utility
ORDER BY avg_battery_life DESC;





-- Q18: Relationship between battery capacity and Laptop weight
-- What is the relationship between battery capacity and laptop weight?


SELECT ROUND(CORR(battery_capacity, weight)::NUMERIC, 2) AS correlation
FROM
(
SELECT
	CAST(TRIM(REPLACE(SPLIT_PART(battery, 'Wh', 1), ' ', '')) AS DECIMAL(4, 1))
		AS battery_capacity, 
		weight
FROM laptops
WHERE battery LIKE '%Wh%' AND weight IS NOT NULL) AS battery_weight;








--
