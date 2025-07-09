-- Data --> https://www.kaggle.com/datasets/swaptr/layoffs-2022

/* First, we need to create a duplicate from the imported table to work on and avoid mistakes to the initial data
now clean data following these steps
1. check for duplicates and remove any
2. standardize data and fix errors
3. Look at null values and see if they need to be replaced
4. remove any columns and rows that are not necessary - few ways
*/
SELECT *
FROM world_layoffs.layoffs_staging
;

CREATE TABLE layoffs_staging
LIKE layoffs
;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs
; 

/* 1. Remove duplicates by creating a new table that starts numbering every unique row (start a series at a row)
This way, if a row is mentioned again, it will be numbered more than 1 and this way we can detect it by creating a new table with additional column 'row_num' and remove it
*/
CREATE TABLE `layoffs_staging2` (  -- or ALTER TABLE world_layoffs.layoffs_staging ADD row_num INT;
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER () OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging2
;

/* 2. Standardize data by:
(1) remove extra spaces using the trim() function in the 'country' column
(2) set different terms of the same industry to a unique one, and remove empty cells (null)
(3) Set 'United States.' to 'United States'
(4) Changing the format of 'date' from text to date
*/
-- 1
SELECT company, TRIM(company)
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET company = TRIM(company)
;

SELECT *
FROM layoffs_staging2
;

-- 2
SELECT distinct(industry)
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');
;

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1
;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ''
;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL
;

SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1
;

-- 3
SELECT distinct(country)
FROM layoffs_staging2
ORDER BY 1
;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%'
;

SELECT *
FROM layoffs_staging2
;

-- 4
SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2
;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
;

SELECT *
FROM layoffs_staging2
;

/* 3. Remove null values:
the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal and cannot be replaced.
*/

/* 4. Remove useless not informative rows that have zero information
*/
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL
;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL
;

SELECT *
FROM layoffs_staging2
;

/* Lastly, we need to remove 'row_num' column */
ALTER TABLE layoffs_staging2
DROP COLUMN row_num
;

SELECT *
FROM layoffs_staging2
;