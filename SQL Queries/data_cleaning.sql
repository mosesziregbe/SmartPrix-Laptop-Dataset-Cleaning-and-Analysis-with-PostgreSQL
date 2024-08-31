-- create the schema

CREATE SCHEMA laptop_schema;

SET search_path to laptop_schema;


-- First, create a table for the data, then import into postgresql 
-- using the pgadmin import tool


-- Create table smartprix_laptop

DROP TABLE IF EXISTS smartprix_laptop;

CREATE TABLE smartprix_laptop (
    name	VARCHAR(255),
    price	VARCHAR(30),
    spec_score	INT,
    votes	VARCHAR(50),
    user_rating	DECIMAL(3, 1),
    os	VARCHAR(100),
    utility	VARCHAR(255),
    thickness	VARCHAR(50),
    weight	VARCHAR(50),
    warranty	VARCHAR(100),
    screen_size	VARCHAR(50),
    resolution	VARCHAR(50),
    ppi	VARCHAR(100),
    battery	VARCHAR(100),
    screen_feature1	VARCHAR(50),
    screen_feature2	VARCHAR(50),
    processor_name	VARCHAR(255),
    processor_speed	VARCHAR(255),
    no_cores	VARCHAR(255),
    caches	VARCHAR(50),
    graphics_card	VARCHAR(255),
    rom_memory	VARCHAR(100),
    internal_memory	VARCHAR(100),
    port_connection	VARCHAR(255),
    wireless_connection	VARCHAR(255),
    usb_ports	VARCHAR(255),
    hardware_features	VARCHAR(255)
);


-- Import the dataset with the pgAdmin import tool

-- Inspect the imported dataset

SELECT * FROM smartprix_laptop;


-- we have 1020 rows and 27 columns

SELECT * FROM smartprix_laptop;



-- DATA CLEANING AND TRANSFORMATION

-- Create a new table named laptops to do the data cleaning and 
-- copy all data from the original smartprix_data table to preserve the original data.

DROP TABLE IF EXISTS laptops;


SELECT *
INTO laptops
FROM smartprix_laptop;


-- check if there are any duplicates

WITH duplicate_cte AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY name, price, spec_score, votes, user_rating, 
							os, utility, thickness, weight, warranty, screen_size, resolution, 
							ppi, battery, screen_feature1, screen_feature2, processor_name, 
							processor_speed, no_cores, caches, graphics_card, rom_memory, 
							internal_memory, port_connection, wireless_connection, 
							usb_ports, hardware_features) AS row_num
FROM laptops
)
SELECT * 
FROM duplicate_cte 
WHERE row_num > 1;



-- we have 22 rows of duplicate data

-- use the postgresql ctid column to remove the duplicate rows

WITH duplicate_cte AS (
    SELECT ctid, ROW_NUMBER() OVER(PARTITION BY name, price, spec_score, votes, user_rating, 
                                   os, utility, thickness, weight, warranty, screen_size, resolution, 
                                   ppi, battery, screen_feature1, screen_feature2, processor_name, 
                                   processor_speed, no_cores, caches, graphics_card, rom_memory, 
                                   internal_memory, port_connection, wireless_connection, 
                                   usb_ports, hardware_features) AS row_num
    FROM laptops
)
DELETE FROM laptops
WHERE ctid IN (
    SELECT ctid
    FROM duplicate_cte
    WHERE row_num > 1);


-- Inspect the table, we are left with 998 rows and 27 columns

SELECT * FROM laptops;

-- Quality issues

-- Almost all the columns need data cleaning, standardization,
-- so I will clean the column one after the other



-- name column

-- first, extract the brand name using the SPLIT_PART function, the first words are obviously
-- the brand names (HP, Xiaomi, Apple etc.)

-- Then use the initcap function to capital the first words of the brand names **

SELECT SPLIT_PART(name, ' ', 1) AS brands FROM laptops
ORDER BY brands;


-- add new column brand

ALTER TABLE laptops ADD brand VARCHAR(20);

UPDATE laptops
SET brand = SPLIT_PART(name, ' ', 1);


-- Inspect the table

SELECT * FROM laptops;


-- update the brand table for Asus brand

UPDATE laptops
SET brand = CASE WHEN brand = 'ASUS' THEN 'Asus' ELSE brand END;


-- Ensure data consistency and standardization

-- checking for hidden whitespaces

SELECT DISTINCT brand, ASCII(SUBSTRING(brand FROM 1 FOR 1)) AS first_char_ascii
FROM laptops
ORDER BY brand;

UPDATE laptops
SET brand = REGEXP_REPLACE(brand, '[\u200E]', '', 'g');


-- Removed the error or hidden whitespace, now there are 31 distinct brands

SELECT DISTINCT brand FROM laptops
ORDER BY brand;

SELECT * FROM laptops;



-- price column

-- For the price column, I want to turn this into a numeric column
-- so I need to remove the currency symbol and commas.

SELECT price, REPLACE(SUBSTRING(price, 2, LENGTH(price)), ',', '') 
FROM laptops;


UPDATE laptops
SET price = REPLACE(SUBSTRING(price, 2, LENGTH(price)), ',', '');


-- change column datatype to numeric
-- using postgres documentation -- http://www.postgresql.org/docs/current/interactive/sql-altertable.html

ALTER TABLE laptops ALTER COLUMN price TYPE NUMERIC USING price::NUMERIC;



-- spec_score column

-- count of spec_score returns 1020 non_null values, so this is okay

SELECT COUNT(spec_score) FROM laptops
WHERE spec_score IS NOT NULL;



-- votes column

-- The votes column has some user reviews count included inside the
-- column, I will try to extract the votes seperately, then 
-- extract the reviews count into another column thanks to the SPLIT_PART function

-- use the split_part function to retrieve the votes,
-- also retrieve the number of reviews


SELECT votes, SPLIT_PART(votes, ' ', 1) AS votes, 
	   SPLIT_PART(votes, ' ', 4) AS reviews 
FROM laptops;

-- first create new column reviews, to extract the reviews
-- from the votes column

ALTER TABLE laptops ADD reviews INTEGER;

-- first use trim to check for empty string, and make them null
-- then cast the extracted strings as integer

UPDATE laptops
SET reviews = CASE WHEN TRIM(SPLIT_PART(votes, ' ', 4)) = '' THEN NULL
				   ELSE CAST(SPLIT_PART(votes, ' ', 4) AS INTEGER) END;


-- I can now fix the votes column
-- I will replace the commas, after splitting the
-- column to get the votes


UPDATE laptops
SET votes = REPLACE(SPLIT_PART(votes, ' ', 1), ',', '');



-- next I will rename the column vote to user_votes
-- change the datatype of user_votes to integer

ALTER TABLE laptops RENAME COLUMN votes TO user_votes;

ALTER TABLE laptops ALTER COLUMN user_votes TYPE INTEGER USING user_votes::INTEGER;


-- Inspect our laptops table 

SELECT * FROM laptops;



-- os column

SELECT DISTINCT os FROM laptops;

-- There are about 12 distinct OS (operating system), but we have a data entry issue
-- where the utility is placed inside the os column

SELECT INITCAP(SUBSTRING(os, 4, LENGTH(os)))
FROM laptops
WHERE os LIKE 'OS%'; -- find the strings in the os column that starts with 'OS'




-- There are some rows having misplaced data
-- I will update the os table to handle the ones with the available os

UPDATE laptops
SET os = CASE WHEN os LIKE 'OS%' THEN INITCAP(SUBSTRING(os, 4, LENGTH(os))) 
			  ELSE os END;
			  
SELECT DISTINCT os FROM laptops;


-- we have 2 errors, os showing just 'windows' and os showing 'utility'

SELECT name, os
FROM laptops
WHERE os LIKE '%windows';


-- checking from the website, some of them are actually listed 
-- as having windows OS --> 
-- https://www.smartprix.com/laptops/lenovo-legion-y9000x-laptop-13th-gen-core-ppd1ov3wyhvp
-- so I will leave the OS as windows

-- I will find the remaining ones with data entry issues

SELECT name, os
FROM laptops
WHERE os LIKE 'Utility%' 

SELECT name, os
FROM laptops
WHERE name ILIKE '%Samsung%';




-- we have 3 groups (the names with Prime OS, Jio OS and the samsung)
-- the os for that samsung is listed as unknown on the smartprix website

UPDATE laptops
SET os = CASE WHEN os LIKE 'OS%' THEN TRIM((SUBSTRING(os, 4, LENGTH(os))))
			  WHEN os LIKE 'Utility%' AND name LIKE 'Jio%' THEN 'Jio os'
			  WHEN os LIKE 'Utility%' AND name LIKE 'Prime%' THEN 'Prime os'
			  ELSE os END;


SELECT DISTINCT os FROM laptops;

SELECT INITCAP(os) FROM laptops;



-- Ensure to capitalize each first letter and trim the os column	

UPDATE laptops
SET os = INITCAP(TRIM(os));

-- there are misplaced data with some of the columns due to
-- data scrapping issues or poor data entry

-- To sort this out, first I will handle the cases where I can simply
-- remove the redundant word 'Utility' from the rows that have the word 
-- utility.

-- this is happening between the thickness, weight and warranty columns

SELECT utility, TRIM(SUBSTRING(utility, 9, LENGTH(utility)))
FROM laptops
WHERE utility LIKE 'Utility%';

-- we have about 1013 rows, so 7 of them have misplaced data issues
-- Try to handle the 7 rows with data entry issues

-- 5 of the rows contains the thickness while 1 contains warranty, 1 row contains the weight

SELECT name, utility, thickness, weight, warranty
FROM laptops
WHERE utility NOT LIKE 'Utility%';

-- to handle the many errors first, let's find a way to fix the
-- appropriate data for each column

SELECT name, utility, thickness, weight, warranty
FROM laptops
WHERE utility NOT LIKE 'Utility%' AND utility LIKE 'Thickness%';



-- I will create 3 backup columns with the original data from
-- utility, thickness, weight...


ALTER TABLE laptops
ADD COLUMN backup_utility TEXT,
ADD COLUMN backup_thickness TEXT,
ADD COLUMN backup_weight TEXT;


UPDATE laptops
SET backup_utility = utility,
	backup_thickness = thickness,
    backup_weight = weight;
	
	

-- update from the backup in batches

UPDATE laptops
SET thickness = backup_utility
WHERE backup_utility LIKE 'Thickness%'
AND backup_thickness NOT LIKE 'Thickness%';



SELECT *
FROM laptops
WHERE backup_weight LIKE '%Warranty' AND warranty IS NULL;



-- update the warranty column first from the weight column

UPDATE laptops
SET warranty = weight
WHERE backup_weight LIKE '%Warranty' AND warranty IS NULL;


-- Try to fix more of the warranty column

UPDATE laptops
SET warranty = thickness
WHERE thickness LIKE '%Warranty' AND warranty IS NULL;


-- Inspect the thickness column

SELECT utility, thickness, weight, warranty
FROM laptops
WHERE thickness LIKE '%Warranty'

-- Warranty is already updated with the appropriate data
-- so the warranty data in thickness can now be deleted

UPDATE laptops
SET thickness = NULL
WHERE thickness LIKE '%Warranty';


-- we can try and handle the weight data in our thickness column now

SELECT utility, thickness, weight, warranty
FROM laptops
WHERE thickness NOT LIKE 'Thickness%'

UPDATE laptops
SET weight = thickness
WHERE thickness NOT LIKE 'Thickness%' AND weight LIKE '%Warranty';


-- remove the misplaced weight values from thickness

SELECT utility, thickness, weight, warranty
FROM laptops
WHERE thickness NOT LIKE 'Thickness%'

UPDATE laptops
SET thickness = NULL
WHERE thickness NOT LIKE 'Thickness%';



-- Can we fix our utility column now?

SELECT utility, thickness, weight, warranty
FROM laptops;



-- let's check again

SELECT utility, thickness, weight, warranty
FROM laptops
WHERE utility NOT LIKE 'Utility%';



-- we have just 2 rows withs misplaced values, to solve this problem
-- it will be great using the exact match for the brand name
-- to avoid mixing up issues for other rows

SELECT name, utility, thickness, weight, warranty
FROM laptops
WHERE utility NOT LIKE 'Utility%';

UPDATE laptops
SET weight = utility
WHERE name = 'Jio JioBook NB1112MM BLU 2023 Netbook Laptop (Octa Core/ 4GB/ 64GB eMMC/ JioOS)';

UPDATE laptops
SET warranty = utility
WHERE name = 'Jio JioBook Cloud Laptop (Octa Core/ 4GB/ 64GB eMMC/ JioOS)'



-- Almost there :), for each of the problem columns (utility, thickness, 
-- weight, warranty) that do not match we can turn them into null values


SELECT name, utility, thickness, weight, warranty
FROM laptops
WHERE utility NOT LIKE 'Utility%';

UPDATE laptops
SET utility = NULL
WHERE utility NOT LIKE 'Utility%';

UPDATE laptops
SET weight = NULL
WHERE weight LIKE '%Warranty';



-- Inspecting our tables again

SELECT DISTINCT utility
FROM laptops;

SELECT DISTINCT thickness
FROM laptops;

SELECT DISTINCT weight 
FROM laptops;

SELECT DISTINCT warranty
FROM laptops;



-- Okay?? we can remove redundant text from our Utility column now

SELECT name, utility, TRIM(SUBSTRING(utility, 9, LENGTH(utility)))
FROM laptops;


UPDATE laptops
SET utility = TRIM(SUBSTRING(utility, 9, LENGTH(utility)));




--  split thickness into 2 parts, thickness (in mm) and thickness_category

SELECT * FROM laptops;



-- add thickness category column

ALTER TABLE laptops ADD COLUMN thickness_category VARCHAR(20);

SELECT TRIM(SPLIT_PART(thickness, 'mm', 2)) FROM laptops;

UPDATE laptops
SET thickness_category = TRIM(SPLIT_PART(thickness, 'mm', 2));
										   


-- get the first part from thickness

SELECT TRIM(SPLIT_PART(SPLIT_PART(thickness, 'mm', 1), ' ', 2)) FROM laptops;


UPDATE laptops
SET thickness = TRIM(SPLIT_PART(SPLIT_PART(thickness, 'mm', 1), ' ', 2));


UPDATE laptops
SET thickness = CAST(
	TRIM(REGEXP_REPLACE(thickness, '[^0-9\.]', '', 'g')) AS NUMERIC);



-- alter column to the appropriate data type

ALTER TABLE laptops ALTER COLUMN thickness TYPE NUMERIC USING thickness::NUMERIC;
										   
										   
-- time to work on the weight column


SELECT * FROM laptops;
										   
SELECT TRIM(SPLIT_PART(weight, 'kg', 2)) FROM laptops;	
										   
										   
-- Add new column weight_category
										   
ALTER TABLE laptops ADD COLUMN weight_category VARCHAR(20);

UPDATE laptops
SET weight_category = TRIM(SPLIT_PART(weight, 'kg', 2));									   
										   
										   
UPDATE laptops
SET weight = TRIM(SPLIT_PART(weight, 'kg', 1));
										   
UPDATE laptops
SET weight = CAST(TRIM(REGEXP_REPLACE(weight, '[^0-9\.]', '', 'g')) AS NUMERIC);
										   

-- alter the weight column to the appropriate data type

ALTER TABLE laptops ALTER COLUMN weight TYPE NUMERIC USING weight::NUMERIC;



-- We need to standardize the weight to make it uniform, some are in grams, 
-- while others are in kilogram
										   
SELECT CASE WHEN weight > 100 THEN ROUND((1.0 * weight/1000), 2)
			ELSE weight END AS weight 
FROM laptops;



-- fix the weight column
										   
UPDATE laptops
SET weight = CASE WHEN weight > 100 THEN ROUND((1.0 * weight/1000), 2)
			 ELSE weight END;
										   
																			   
										   
-- warranty column

SELECT DISTINCT warranty FROM laptops;


-- returns 3 distinct warranty and null values,
-- we can move on from this and drop our backup columns	



-- dropping our backup columns we created earlier
										   
ALTER TABLE laptops 
DROP COLUMN backup_utility,
DROP COLUMN backup_thickness,
DROP COLUMN backup_weight;



-- Inspecting our laptops table

SELECT * FROM laptops;



-- screen_size column
-- find the distinct values in screen_size

SELECT DISTINCT screen_size FROM laptops;

						
-- remove redundant words from screen_size column

SELECT screen_size, TRIM(LEFT(screen_size, POSITION('inches' IN screen_size) + 5)) AS cleaned_screen_size
FROM laptops
ORDER BY cleaned_screen_size DESC;


UPDATE laptops
SET screen_size = TRIM(LEFT(screen_size, POSITION('inches' IN screen_size) + 5));



-- ppi column

SELECT DISTINCT ppi FROM laptops;

-- this is not really a relevant column, 
-- so I will drop this column

ALTER TABLE laptops DROP COLUMN ppi;


-- resolution column
-- I will drop this column as well

ALTER TABLE laptops DROP COLUMN resolution;


-- battery column
-- battery column contains some redundant words 'Good'

SELECT DISTINCT battery FROM laptops;

SELECT SPLIT_PART(battery, 'Good', 1) FROM laptops;

UPDATE laptops
SET battery = SPLIT_PART(battery, 'Good', 1);

-- Inspect table

SELECT * FROM laptops;


-- screen_feature1 and screen_feature2 columns

-- combine the screen features columns using concat_ws

SELECT CONCAT_WS(', ', screen_feature1, screen_feature2) FROM laptops;

UPDATE laptops
SET screen_feature1 = CONCAT_WS(', ', screen_feature1, screen_feature2);


-- rename screen_feature1 column to screen_feature

ALTER TABLE laptops RENAME COLUMN screen_feature1 TO screen_feature;


-- drop the second screen feature column

ALTER TABLE laptops DROP COLUMN screen_feature2;



-- Inspect the table

SELECT * FROM laptops;



-- processor_name column

-- first, ensure that the processor_name column do not 
-- have extra white spaces

SELECT processor_name, TRIM(REPLACE(REPLACE(processor_name, '  ', ' '), '  ', ' ')) AS processor_name
FROM laptops
WHERE processor_model IS NULL;

UPDATE laptops
SET processor_name = TRIM(REPLACE(REPLACE(processor_name, '  ', ' '), '  ', ' '));


-- try to extract the processor_gen from the processor_name column

SELECT TRIM(LEFT(processor_name, POSITION('Gen' IN processor_name) + 2)) 
FROM laptops
WHERE processor_name LIKE '%Gen%'; -- matches any string that contains the word "Gen" anywhere in it


ALTER TABLE laptops ADD COLUMN processor_gen VARCHAR(20);

UPDATE laptops
SET processor_gen = TRIM(LEFT(processor_name, POSITION('Gen' IN processor_name) + 2))
					WHERE processor_name LIKE '%Gen%';



SELECT SPLIT_PART(processor_name, 'Apple', 2) FROM laptops
WHERE processor_name NOT LIKE '%Gen%' AND processor_name LIKE '%Apple%';

UPDATE laptops
SET processor_gen = TRIM(SPLIT_PART(processor_name, 'Apple', 2))
WHERE processor_name NOT LIKE '%Gen%' AND processor_name LIKE '%Apple%';

-- I will leave the other values in the processor_gen column 
-- as null for now


SELECT * FROM laptops;




-- try to extract the processor brand

SELECT processor_name, TRIM(INITCAP(SPLIT_PART(processor_name, ' ', 3)))
FROM laptops
WHERE processor_name LIKE '%Gen%';

ALTER TABLE laptops ADD COLUMN processor_brand VARCHAR(20);



UPDATE laptops
SET processor_brand = TRIM(INITCAP(SPLIT_PART(processor_name, ' ', 3)))
WHERE processor_name LIKE '%Gen%';



-- try to extract the remaining batches of laptops with Intel as processor brand

SELECT processor_name, TRIM(INITCAP(SPLIT_PART(processor_name, ' ', 1)))
FROM laptops
WHERE processor_name NOT LIKE '%Gen%' AND processor_name LIKE '%Intel%';


UPDATE laptops
SET processor_brand = TRIM(INITCAP(SPLIT_PART(processor_name, ' ', 1)))
WHERE processor_name NOT LIKE '%Gen%' AND processor_name LIKE '%Intel%';


SELECT DISTINCT processor_brand, LENGTH(processor_brand) 
FROM laptops;


SELECT DISTINCT processor_brand, 
	   ASCII(SUBSTRING(processor_brand FROM 1 FOR 1)) AS first_char_ascii
FROM laptops;


-- remove the hidden white spaces from the processor_brand column

UPDATE laptops
SET processor_brand = REGEXP_REPLACE(processor_brand, '[\u200E]', '', 'g');


-- try to extract the processor_core 

ALTER TABLE laptops ADD COLUMN processor_core VARCHAR(20);


-- leverage regular expressions to locate and extract the desired substring

SELECT processor_name, TRIM(SUBSTRING(processor_name FROM 'Core\s*\w+\d'))
FROM laptops
WHERE processor_name LIKE '%Core%';


UPDATE laptops
SET processor_core = TRIM(SUBSTRING(processor_name FROM 'Core\s*\w+\d'))
WHERE processor_name LIKE '%Core%';


SELECT * FROM laptops;


SELECT name, processor_name, processor_core
FROM laptops
WHERE processor_core IS NULL AND processor_name NOT LIKE 'Apple%';



-- try to extract the processor model

ALTER TABLE laptops ADD COLUMN processor_model VARCHAR(50);


SELECT name, processor_name, 
	   TRIM(REGEXP_REPLACE(processor_name,'.*(Intel Celeron(\s+Dual Core)?\s+)', '')) AS processor_model
FROM laptops
WHERE processor_name LIKE '%Intel Celeron%';

UPDATE laptops
SET processor_model = TRIM(REGEXP_REPLACE(processor_name,'.*(Intel Celeron(\s+Dual Core)?\s+)', ''))
WHERE processor_name LIKE '%Intel Celeron%';



-- Here's a breakdown of what each part does:
-- REGEXP_REPLACE(processor_name, ...):
-- This function replaces part of the processor_name string based on a 
-- regular expression pattern.

-- '.*(Intel Celeron(\s+Dual Core)?\s+)':

-- This is the regular expression pattern:

-- .* matches any characters at the beginning of the string.
-- Intel Celeron matches these exact words.
-- (\s+Dual Core)? optionally matches 'Dual Core' if present.
-- \s+ matches one or more whitespace characters.

-- The second argument '' in REGEXP_REPLACE:
-- This replaces the matched pattern with an empty string, effectively removing it.

-- TRIM(...):
-- This removes any leading or trailing whitespace from the result.


-- check for "Intel core i_"

SELECT name, 
	   processor_name, 
	   TRIM(REGEXP_REPLACE(processor_name,'.*Core\s+(i[3579])(.*)$','\2')) AS processor_model
FROM laptops
WHERE processor_name LIKE '%Intel Core i_%';


UPDATE laptops
SET processor_model = TRIM(REGEXP_REPLACE(processor_name,'.*Core\s+(i[3579])(.*)$','\2'))
WHERE processor_name ILIKE '%Intel Core i_%';



-- To extract everything after "Core i5" (or any other Core iX designation) 
-- from the processor name, you can use the following query:

-- This query does the following:

-- '.*Core\s+(i[3579])(.*)$' is the regular expression pattern:
-- .* matches any characters at the beginning of the string

-- Core\s+ matches "Core" followed by one or more whitespace characters
-- (i[3579]) captures "i3", "i5", "i7", or "i9"
-- (.*) captures everything after that until the end of the string

-- '\2' in the replacement part of REGEXP_REPLACE keeps only the second captured group, 
-- which is everything after "Core iX"
-- TRIM() removes any leading or trailing whitespace from the result

-- the WHERE clause %Intel Core i_%' means:
-- 1. it starts with any characters (%)
-- 2. Followed by "Intel Core i"
-- 3. Then exactly one character (_)
-- 4. Followed by any number of characters (%)



-- Inspecting the processor_name and corresponding model column to find the
-- null values

SELECT processor_name, processor_model FROM laptops
WHERE processor_model IS NULL;



-- we can extract for Intel core ultra and for processor names with AMD Ryzen

-- extracting for Intel core ultra

SELECT 
  processor_name, 
  TRIM(REGEXP_REPLACE(processor_name,'.*Core Ultra\s+(\d+)(.*)$','\1\2')) AS intermediate_result,
  SPLIT_PART(TRIM(REGEXP_REPLACE(processor_name,'.*Core Ultra\s+(\d+)(.*)$','\1\2')), ' ', -1) AS processor_model
FROM laptops
WHERE processor_name LIKE '%Intel Core Ultra%';

SELECT * FROM laptops;

UPDATE laptops
SET processor_model = SPLIT_PART(TRIM(REGEXP_REPLACE(processor_name,'.*Core Ultra\s+(\d+)(.*)$','\1\2')), ' ', -1)
WHERE processor_name LIKE '%Intel Core Ultra%';



-- extract for laptops with AMD Ryzen

SELECT processor_name, 
	   TRIM(REGEXP_REPLACE(processor_name, '.*Amd\s+(.*)$', '\1')) AS processor_model
FROM 
laptops
WHERE processor_name LIKE '%AMD Ryzen%';


-- I notice some AMD laptops have lowercase characters, so we use ILIKE

UPDATE laptops
SET processor_model = TRIM(REGEXP_REPLACE(processor_name, '(?i).*AMD\s+(.*)$', '\1'))
WHERE processor_name ILIKE '%AMD%';


-- Breakdown of the Query:

-- TRIM(...):
-- Removes any leading or trailing whitespace from the result of the expression 
-- inside it.

-- REGEXP_REPLACE(processor_name, '(?i).*AMD\s+(.*)$', '\1'):

-- (?i): This is a flag within the regular expression that makes the search case-insensitive.
-- .*AMD\s+(.*)$: The regular expression pattern used to search the processor_name column.

-- .*: Matches any characters (except newline) zero or more times before "AMD".
-- AMD\s+: Matches "AMD" followed by one or more whitespace characters.
-- (.*)$: Captures the rest of the string after "AMD" as a group.
-- \1: Refers to the first captured group, which is the text after "AMD".

-- WHERE processor_name ILIKE '%AMD%':
-- processor_name ILIKE '%AMD%': Matches rows where processor_name 
-- contains "AMD", case-insensitively (ILIKE).


SELECT processor_name, processor_model
FROM laptops
WHERE processor_model IS NULL;



-- processor_speed column

SELECT *
FROM laptops
WHERE processor_model IS NULL;


-- I notice there is a misplaced data (processor speed) inside 1 of the rows


SELECT * FROM laptops;

-- From processor_name, processor_speed, no_cores, caches, graphics_card, rom_memory, 
-- internal_memory, some data has been placed wrongly

-- start from the end, internal memory to the processor_speed


-- use LIKE HARD Disk or SSD to extract the affected rows 

SELECT name, rom_memory, internal_memory
FROM laptops
WHERE rom_memory LIKE '%HARD Disk%' OR rom_memory LIKE '%SSD%' AND internal_memory IS NULL;

UPDATE laptops
SET internal_memory = rom_memory
WHERE rom_memory LIKE '%HARD Disk%' OR rom_memory LIKE '%SSD%' AND internal_memory IS NULL;


-- fix the rom_memory column

SELECT graphics_card, rom_memory
FROM laptops
WHERE rom_memory LIKE '%HARD Disk%' OR rom_memory LIKE '%SSD%' OR graphics_card LIKE '%RAM%';


UPDATE laptops
SET rom_memory = graphics_card
WHERE rom_memory LIKE '%HARD Disk%' OR rom_memory LIKE '%SSD%' OR graphics_card LIKE '%RAM%';


-- fix the graphics_card column

SELECT caches, graphics_card
FROM laptops
WHERE graphics_card LIKE '%RAM%' OR caches LIKE '%Graphics%';

UPDATE laptops
SET graphics_card = caches
WHERE graphics_card LIKE '%RAM%' OR caches LIKE '%Graphics%';


-- fix the caches column

SELECT name, processor_name, processor_speed, no_cores, caches
FROM laptops
WHERE caches LIKE '%Graphics%'


-- some rows do no have any information for caches, 
-- so set those rows to null

UPDATE laptops
SET caches = NULL
WHERE caches LIKE '%Graphics%';



-- fix the no_cores column having misplaced data

SELECT processor_name, no_cores FROM laptops
WHERE no_cores LIKE '%RAM%';


SELECT * FROM laptops
WHERE no_cores LIKE '%RAM%' OR caches LIKE '%SSD%';

UPDATE laptops
SET internal_memory = caches
WHERE no_cores LIKE '%RAM%' OR caches LIKE '%SSD%';

UPDATE laptops
SET rom_memory = no_cores
WHERE no_cores LIKE '%RAM%' OR caches LIKE '%SSD%';


SELECT * FROM laptops
WHERE processor_speed LIKE '%Graphics%';

UPDATE laptops
SET graphics_card = processor_speed
WHERE processor_speed LIKE '%Graphics%';



-- Finally, replace the misplaced data in the columns with null since there is no available data

SELECT * FROM laptops
WHERE no_cores LIKE '%RAM%' OR caches LIKE '%SSD%';

UPDATE laptops
SET caches = NULL
WHERE no_cores LIKE '%RAM%' OR caches LIKE '%SSD%';

UPDATE laptops
SET no_cores = NULL
WHERE no_cores LIKE '%RAM%' OR caches LIKE '%SSD%';

SELECT processor_speed
FROM laptops
WHERE processor_speed LIKE '%Graphics%';


UPDATE laptops
SET processor_speed = NULL
WHERE processor_speed LIKE '%Graphics%';



-- Inspecting the columns

SELECT name, processor_name, processor_speed, no_cores, caches, graphics_card, rom_memory, internal_memory
FROM laptops
WHERE processor_name LIKE '%Speed%';



-- there is only 1 row affected, so target the exact laptop name to avoid more issues

UPDATE laptops
SET internal_memory = caches
WHERE name = 'Jio JioBook Cloud Laptop (Octa Core/ 4GB/ 64GB eMMC/ JioOS)';


UPDATE laptops
SET rom_memory = no_cores
WHERE name = 'Jio JioBook Cloud Laptop (Octa Core/ 4GB/ 64GB eMMC/ JioOS)';

UPDATE laptops
SET no_cores = processor_speed
WHERE name = 'Jio JioBook Cloud Laptop (Octa Core/ 4GB/ 64GB eMMC/ JioOS)';

UPDATE laptops
SET processor_speed = processor_name
WHERE name = 'Jio JioBook Cloud Laptop (Octa Core/ 4GB/ 64GB eMMC/ JioOS)';


SELECT name, processor_name, processor_speed, no_cores, caches, graphics_card, rom_memory, internal_memory
FROM laptops
WHERE processor_name LIKE '%Speed%';




-- finally, update processor_name and caches to null

UPDATE laptops
SET processor_name = NULL
WHERE name = 'Jio JioBook Cloud Laptop (Octa Core/ 4GB/ 64GB eMMC/ JioOS)';

UPDATE laptops
SET caches = NULL
WHERE name = 'Jio JioBook Cloud Laptop (Octa Core/ 4GB/ 64GB eMMC/ JioOS)';



-- Inspect the data to confirm all information are in the
-- right column for that exact laptop

SELECT name, processor_name, processor_speed, no_cores, caches, graphics_card, rom_memory, internal_memory
FROM laptops
WHERE name = 'Jio JioBook Cloud Laptop (Octa Core/ 4GB/ 64GB eMMC/ JioOS)'



-- I notice some error, so I will retrieve from the original smart_prix_laptop data

SELECT *
FROM smartprix_laptop
WHERE name LIKE '%Jio JioBook Cloud Laptop%';

UPDATE laptops
SET utility = 'Everyday Use',
	internal_memory = '64 GB HARD Disk',
	rom_memory = '4 GB LPDDR4 RAM'
WHERE name LIKE '%Jio JioBook Cloud Laptop%' AND utility IS NULL;


-- Done with handling the misplaced data, now back to the data cleaning of the columns

SELECT * 
FROM laptops;



-- processor_speed column, try to insert a comma between the cores

SELECT REGEXP_MATCH(processor_speed, '.*Cores')
FROM laptops;


SELECT processor_speed, REGEXP_REPLACE(processor_speed,'(Cores)(?=.*Cores)','\1, ','g') AS updated_processor_speed
FROM laptops
WHERE processor_speed ~ 'Cores.*Cores';

UPDATE laptops
SET processor_speed = REGEXP_REPLACE(processor_speed,'(Cores)(?=.*Cores)','\1, ','g')
WHERE processor_speed ~ 'Cores.*Cores';


SELECT DISTINCT processor_speed 
FROM laptops;



-- There is another case of misplaced data in the processor_speed column
-- showing threads

SELECT processor_speed 
FROM laptops
WHERE processor_speed LIKE '%Threads%'

-- There is only 1 row affected, target the exact laptop name to avoid futher issues

SELECT *
FROM laptops
WHERE processor_speed LIKE '%Threads%'

UPDATE laptops
SET caches = no_cores
WHERE name = 'Asus TUF Gaming F15 90NR0GW1-M00F00 Laptop (12th Gen Core i7/ 16GB/ 1TB SSD/ Win11/ 4GB Graph)';

UPDATE laptops
SET no_cores = processor_speed
WHERE name = 'Asus TUF Gaming F15 90NR0GW1-M00F00 Laptop (12th Gen Core i7/ 16GB/ 1TB SSD/ Win11/ 4GB Graph)';

UPDATE laptops
SET processor_speed = NULL
WHERE name = 'Asus TUF Gaming F15 90NR0GW1-M00F00 Laptop (12th Gen Core i7/ 16GB/ 1TB SSD/ Win11/ 4GB Graph)';


-- Inspect the no_cores column

SELECT DISTINCT no_cores FROM laptops;


-- Inspect the caches column

SELECT DISTINCT caches FROM laptops;


-- Remove any extra white spaces, remove cases where Cache comes twice

UPDATE laptops
SET caches = TRIM(REPLACE(REPLACE(caches, '  ', ' '), '  ', ' '));

-- fix the cache column

SELECT caches, REGEXP_REPLACE(caches, '(Cache)\s+Cache$', '\1', 'g') AS cleaned_caches
FROM laptops
WHERE caches ~ 'Cache\s+Cache$';

UPDATE laptops
SET caches = REGEXP_REPLACE(caches, '(Cache)\s+Cache$', '\1', 'g')
WHERE caches ~ 'Cache\s+Cache$';


-- REGEXP_REPLACE(caches, '(Cache)\s+Cache$', '\1', 'g'):
-- The first argument is the column we're operating on.

-- '(Cache)\s+Cache$' is the regex pattern:

-- (Cache) captures the word "Cache" in a group.
-- \s+ matches one or more whitespace characters.
-- Cache$ matches "Cache" at the end of the string.


-- '\1' in the replacement string refers to the first captured group 
-- (the first "Cache").

-- 'g' flag makes the replacement global (though it's not strictly 
-- necessary here as we're matching the end of the string).

-- WHERE caches ~ 'Cache\s+Cache$': This condition ensures we only 
-- update rows where "Cache Cache" appears at the end of the string.



-- Inspect the table 

SELECT * FROM laptops;


-- graphics_card column

SELECT graphics_card, 
	   TRIM(REPLACE(REPLACE(graphics_card, '  ', ' '), '  ', ' '))
FROM laptops;


UPDATE laptops
SET graphics_card = TRIM(REPLACE(REPLACE(graphics_card, '  ', ' '), '  ', ' '));


-- replace the redundant 'Graphics' in some of the columns

SELECT graphics_card, REGEXP_REPLACE(graphics_card, '(Graphics)\s+Graphics$', '\1')
FROM laptops
WHERE graphics_card ~ 'Graphics\s+Graphics$';


UPDATE laptops
SET graphics_card = REGEXP_REPLACE(graphics_card, '(Graphics)\s+Graphics$', '\1')
WHERE graphics_card ~ 'Graphics\s+Graphics$';



-- Also, try to remove the words Smallest, Largest, Average after the graphics_card
-- we can use regexp_replace or left and strpos

SELECT graphics_card, REGEXP_REPLACE(graphics_card, '(Graphics).*$', '\1') AS cleaned_graphics_card
FROM laptops
WHERE graphics_card LIKE '%Graphics%';

SELECT graphics_card, 
       LEFT(graphics_card, STRPOS(graphics_card, 'Graphics') + 7) AS cleaned_graphics_card
FROM laptops
WHERE graphics_card LIKE '%Graphics%';


UPDATE laptops
SET graphics_card = LEFT(graphics_card, STRPOS(graphics_card, 'Graphics') + 7)
WHERE graphics_card LIKE '%Graphics%';




-- replace the commas and capitalise each word

SELECT graphics_card, INITCAP(REPLACE(graphics_card, ',', '')) AS cleaned_graphics_card
FROM laptops;

UPDATE laptops
SET graphics_card = INITCAP(REPLACE(graphics_card, ',', ''));


-- also remove any hidden white spaces

SELECT DISTINCT graphics_card, 
	   ASCII(SUBSTRING(graphics_card FROM 1 FOR 1)) AS first_char_ascii
FROM laptops;


UPDATE laptops
SET graphics_card = REGEXP_REPLACE(graphics_card, '[\u200E]', '', 'g');



SELECT DISTINCT graphics_card FROM laptops;


-- rom_memory column

SELECT * FROM laptops;

SELECT DISTINCT rom_memory FROM laptops;

SELECT rom_memory, TRIM(REPLACE(REPLACE(rom_memory, '  ', ' '), '  ', ' '))
FROM laptops;

UPDATE laptops
SET rom_memory = TRIM(REPLACE(REPLACE(rom_memory, '  ', ' '), '  ', ' '));



SELECT rom_memory, REPLACE(rom_memory, '-', '')
FROM laptops;
	
UPDATE laptops
SET rom_memory = REPLACE(rom_memory, '-', '');



-- remove the largest, Small... at the back of RAM

SELECT rom_memory, LEFT(rom_memory, STRPOS(rom_memory, 'RAM') + 2)
FROM laptops
WHERE rom_memory LIKE '%RAM%';

SELECT rom_memory, REGEXP_REPLACE(rom_memory, '(RAM).*$', '\1')
FROM laptops
WHERE rom_memory LIKE '%RAM%';


UPDATE laptops
SET rom_memory =  LEFT(rom_memory, STRPOS(rom_memory, 'RAM') + 2)
WHERE rom_memory LIKE '%RAM%';

SELECT DISTINCT rom_memory FROM laptops;


-- internal_memory column

SELECT DISTINCT internal_memory FROM laptops;

SELECT TRIM(REPLACE(REPLACE(internal_memory, '  ', ' '), '  ', ' '))
FROM laptops;

UPDATE laptops
SET internal_memory = TRIM(REPLACE(REPLACE(internal_memory, '  ', ' '), '  ', ' '));

SELECT DISTINCT internal_memory FROM laptops;


SELECT 
    internal_memory,
    REGEXP_REPLACE(internal_memory, '(Large|Small|Average|Largest|Smallest)$', '') AS cleaned_internal_memory
FROM laptops
WHERE internal_memory ~ '(Large|Small|Average|Largest|Smallest)$';

UPDATE laptops
SET internal_memory = REGEXP_REPLACE(internal_memory, '(Large|Small|Average|Largest|Smallest)$', '')
WHERE internal_memory ~ '(Large|Small|Average|Largest|Smallest)$';


-- Breakdown of the Query:

-- REGEXP_REPLACE(internal_memory, '(Large|Small|Average|Largest|Smallest)$', ''):

-- This function looks for any of the words "Large", "Small", "Average", 
-- "Largest", or "Smallest" at the end of the string ($ ensures it's at the end).
-- It replaces any matches with an empty string, effectively removing them.

-- WHERE internal_memory ~ '(Large|Small|Average|Largest|Smallest)$':
-- This condition updates only rows where these words appear at the end of the string.



SELECT DISTINCT internal_memory 
FROM laptops;


SELECT * 
FROM laptops;




-- port_connection column

SELECT DISTINCT port_connection FROM laptops;

-- there are some columns showing 'Wifi, Bluetooth'
-- which is another case of misplaced data


SELECT port_connection, wireless_connection, usb_ports, hardware_features
FROM laptops
WHERE port_connection LIKE '%WiFi%' OR port_connection LIKE '%Bluetooth%';




-- About 15 rows affected, so again we start the corrections 
-- from the last column, hardware_features


UPDATE laptops
SET hardware_features = usb_ports
WHERE port_connection LIKE '%WiFi%' OR port_connection LIKE '%Bluetooth%';


-- try to fix the usb_ports column

SELECT port_connection, wireless_connection, usb_ports, hardware_features
FROM laptops
WHERE port_connection LIKE '%WiFi%' OR port_connection LIKE '%Bluetooth%' AND wireless_connection LIKE '%USB%';


UPDATE laptops
SET usb_ports = wireless_connection
WHERE port_connection LIKE '%WiFi%' OR port_connection LIKE '%Bluetooth%' AND wireless_connection LIKE '%USB%';


SELECT port_connection, wireless_connection, usb_ports, hardware_features
FROM laptops
WHERE wireless_connection LIKE '%Microphone%' AND usb_ports IS NULL AND hardware_features IS NULL;


UPDATE laptops
SET hardware_features = wireless_connection
WHERE wireless_connection LIKE '%Microphone%' AND usb_ports IS NULL AND hardware_features IS NULL;


-- fix the misplaced data in wireless_connection 

SELECT port_connection, wireless_connection, usb_ports, hardware_features
FROM laptops
WHERE wireless_connection LIKE '%Microphone%' AND usb_ports IS NULL;

UPDATE laptops
SET wireless_connection = NULL
WHERE wireless_connection LIKE '%Microphone%' AND usb_ports IS NULL;



-- now fix the wireles_connection column

SELECT port_connection, wireless_connection, usb_ports, hardware_features
FROM laptops
WHERE port_connection LIKE '%WiFi%' OR port_connection LIKE '%Bluetooth%';

UPDATE laptops
SET wireless_connection = port_connection
WHERE port_connection LIKE '%WiFi%' OR port_connection LIKE '%Bluetooth%';




-- finally remove the misplaced data in the port_connection column

SELECT port_connection, wireless_connection, usb_ports, hardware_features
FROM laptops
WHERE port_connection LIKE '%WiFi%' OR port_connection LIKE '%Bluetooth%';


UPDATE laptops
SET port_connection = NULL
WHERE port_connection LIKE '%WiFi%' OR port_connection LIKE '%Bluetooth%';



-- Inspect the columns again

SELECT DISTINCT port_connection FROM laptops;

SELECT * FROM laptops;



-- wireless_connection

SELECT DISTINCT wireless_connection FROM laptops;

-- this looks good, so I will proceed to the next column



-- usb_ports column

SELECT DISTINCT usb_ports FROM laptops;


-- I notice there are some misplaced data in the usb_ports column

SELECT usb_ports, hardware_features
FROM laptops
WHERE usb_ports NOT LIKE '%USB%';


-- since the usb_ports contains data that should be in the 
-- hardware_features column, I will simply concat the misplaced_data
-- it to the existing hardware_features for this case


SELECT usb_ports, hardware_features
FROM laptops
WHERE usb_ports NOT LIKE '%USB%' AND usb_ports LIKE '%Camera%';

SELECT CONCAT(hardware_features, ', ', usb_ports)
FROM laptops
WHERE usb_ports NOT LIKE '%USB%' AND usb_ports LIKE '%Camera%';


UPDATE laptops
SET hardware_features = CONCAT(hardware_features, ', ', usb_ports)
WHERE usb_ports NOT LIKE '%USB%' AND usb_ports LIKE '%Camera%';



-- handle the other set of misplaced data

SELECT usb_ports, hardware_features
FROM laptops
WHERE usb_ports NOT LIKE '%USB%' AND hardware_features IS NULL;

UPDATE laptops
SET hardware_features = usb_ports
WHERE usb_ports NOT LIKE '%USB%' AND hardware_features IS NULL;


-- finally we can remove the misplaced data from the usb_ports column

SELECT usb_ports, hardware_features
FROM laptops
WHERE usb_ports NOT LIKE '%USB%';

UPDATE laptops
SET usb_ports = NULL
WHERE usb_ports NOT LIKE '%USB%';


-- hardware_features column

SELECT DISTINCT hardware_features
FROM laptops;

SELECT * FROM laptops
WHERE hardware_features IS NULL;

-- this looks good




-- I can now handle the first_column, name 
-- there are some redundant data that are no longer needed

SELECT * FROM laptops;

SELECT name, TRIM(LEFT(name, POSITION('(' IN name) - 1))
FROM laptops;



-- I notice that some laptop names do not contain their features in paranthesis ()
-- so add an else condition to capture them

SELECT name, CASE WHEN name LIKE '%(%' THEN TRIM(LEFT(name, POSITION('(' IN name) - 1)) 
			 ELSE TRIM(LEFT(name, POSITION('Laptop' IN name) + 5)) END AS cleaned_name
FROM laptops;


UPDATE laptops
SET name = CASE WHEN name LIKE '%(%' THEN TRIM(LEFT(name, POSITION('(' IN name) - 1)) 
ELSE TRIM(LEFT(name, POSITION('Laptop' IN name) + 5)) END;



-- check if there are any duplicates again

WITH duplicate_cte AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY brand, name, price, spec_score, user_votes, user_rating, reviews, os, 
	   utility, thickness, thickness_category, weight, weight_category,
	   warranty, screen_size, battery, screen_feature, 
	   processor_name, processor_gen, processor_brand, processor_core, processor_model,
	   processor_speed, no_cores, caches, graphics_card, rom_memory, internal_memory,
	   port_connection, wireless_connection, usb_ports, hardware_features) AS row_num
FROM laptops
)
SELECT * 
FROM duplicate_cte 
WHERE row_num > 1;


-- output returns no data, meaning there are no duplicate rows in the table

SELECT * FROM laptops;


-- Add a unique identifier (primary key) to the table

ALTER TABLE laptops ADD COLUMN id SERIAL PRIMARY KEY;


-- save the cleaned data into a new table laptops_cleaned

SELECT * FROM laptops
ORDER BY id;


DROP TABLE IF EXISTS laptops_cleaned;

-- saving the cleaned data into laptop_cleaned table

SELECT id, brand, name, price, spec_score, user_votes, user_rating, reviews, os, 
	   utility, thickness, thickness_category, weight, weight_category,
	   warranty, screen_size, battery, screen_feature, 
	   processor_name, processor_gen, processor_brand, processor_core, processor_model,
	   processor_speed, no_cores, caches, graphics_card, rom_memory, internal_memory,
	   port_connection, wireless_connection, usb_ports, hardware_features
INTO laptops_cleaned
FROM laptops
ORDER BY id;


-- Inspect the cleaned dataset

SELECT *
FROM laptops_cleaned;



-- Export the laptops_cleaned.csv file


-- Drop the existing laptops table

DROP TABLE IF EXISTS laptops;


-- create a new laptops table with data from laptops_cleaned

CREATE TABLE laptops AS
SELECT * FROM laptops_cleaned;

SELECT * FROM laptops;


-- enforce the id column as the primary key

ALTER TABLE laptops ADD CONSTRAINT laptops_pkey PRIMARY KEY (id);


-- Add constraint on the price column

ALTER TABLE laptops ADD CONSTRAINT check_price CHECK (price > 0);



-- Create indexes for frequently queried columns

CREATE INDEX idx_brand ON laptops(brand);
CREATE INDEX idx_price ON laptops(price);



-- Inspect the laptops dataset before proceeding to the analysis

SELECT * FROM laptops;

