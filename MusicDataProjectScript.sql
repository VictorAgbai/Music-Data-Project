-- Query table to see all values
SELECT *
FROM musicdata;  -- Data contains 3008 rows of data and 6 field columns

-- Change the names of columns 5 and 6 to avoid conflict while writing queries
ALTER TABLE musicdata
RENAME COLUMN `value (Actual)` to value;

ALTER TABLE musicdata
RENAME COLUMN `Number of Records` to number_of_records;

-- To answer questions from this dataset, we need to create 2 new columns
-- First is a century column to aggregate years into centuries
-- Second is a format-category column to aggregate the formats into physical and digital

-- First, we write a query to confirm the data types for each column
SELECT COLUMN_NAME,
		DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'musicdata'; 

-- Then we change the datatype of the year to one similar to the one for the column we'll create 
-- So that we can extract the data to the century column we'll create...say VARCHAR

ALTER TABLE musicdata
CHANGE COLUMN `year` years varchar(25);

ALTER TABLE musicdata
ADD COLUMN years_10s varchar(25);

-- Next, we populate the data for the century column
UPDATE musicdata
SET years_10s =
		  CASE WHEN LEFT(years,3) LIKE '%7' THEN '70s'
			      WHEN LEFT(years,3) LIKE '%8' THEN '80s'
            WHEN LEFT(years,3) LIKE '%9' THEN '90s'
            WHEN LEFT(years,3) LIKE '%0' THEN '2000s'
            ELSE '2010s'
END;

-- If you encounter error 1175, 
-- Run the below query to toggle off safe update mode and that should fix the error.
SET SQL_SAFE_UPDATES = 0;

-- Next, we create and populate the format-category column 
ALTER TABLE musicdata
ADD COLUMN format_category varchar(25);

UPDATE musicdata
SET format_category =
			CASE WHEN format = 'CD' OR format = 'CD Single'
					          OR format = 'Cassette' OR format = 'Cassette Single'
                    OR format = 'LP/EP' OR format = 'Vinyl Single'
                    OR format LIKE '8-Track' OR format = 'Other Tapes'
                    OR format = 'Music Video (Physical)' OR format = 'SACD'
                    THEN 'Physical'
                    ELSE 'Digital'
END;

-- ---------------------------------- DATA CLEANING PROCEDURES -------------------------------
-- Check for data inconsistency in format column --

SELECT distinct format as uniq_format,
		COUNT(*) as format_freq
FROM musicdata
GROUP BY format;	-- 24 unique rows without any duplicates or near duplicates

-- blanks in value column show years that the music formats didn't generate revenue, no need to delete them

-- --------------------------FEATURE ENGINEERING --------------------------------------
--------------------------------------------------------------------------------------- 
-- 1. In what century was the joint greatest revenue generated?
SELECT DISTINCT years_10s,
			SUM(value) AS total_revenue
FROM musicdata
GROUP BY years_10s
ORDER BY total_revenue;

-- 2. In what century did each format category perform best by revenue?
SELECT years_10s,
		format_category,
		SUM(value) AS total_revenue
FROM musicdata
GROUP BY years_10s, format_category;

-- 3. In what century was there a significant change in revenue generated?
SELECT distinct years_10s,
				ROUND(SUM(value),2) as total_revenue
FROM musicdata
GROUP BY years_10s;

-- 4. What are the current top 5 profitable formats of music?
SELECT format,
		years_10s,
		SUM(value) AS total_revenue
FROM musicdata
WHERE years_10s = '2010s'
GROUP BY format, years_10s
ORDER BY total_revenue DESC
LIMIT 5;

