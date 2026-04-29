-- DATA CLEANING

SELECT *
FROM layoffs;

-- 1. REMOVE DUPLICATES
-- 2. STANDARDIZED THE DATA
-- 3. NULL VALUES OR BLANK VALUES
-- 4. REMOVE ANY COLUMNS or ROWS

-- REMOVE DUPLICATES
CREATE TABLE  layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *,
row_number() OVER (PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

 WITH duplicate_cte AS
(
 SELECT *,
row_number() OVER (PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_staging2
SELECT *,
row_number() OVER (PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- STANDARDIZING DATA
SELECT distinct company, (TRIM(company))
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT *
FROM layoffs_staging2
where industry like 'Crypto%';

UPDATE layoffs_staging2
SET industry ='Crypto'
WHERE industry LIKE 'Cypto%';

SELECT distinct industry
FROM layoffs_staging2;

SELECT Distinct country
FROM layoffs_staging2
order by 1;

SELECT Distinct country
FROM layoffs_staging2
where country like 'United States%'
;

UPDATE layoffs_staging2
SET country ='United States'
WHERE country LIKE 'United States%'
;

SELECT distinct country
FROM layoffs_staging2
order by 1
;

SELECT Distinct country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
order by 1
;

SELECT *
FROM layoffs_staging2
ORDER BY 1
;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y')
;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ''
;

SELECT *
FROM layoffs_staging2
WHERE industry = ''
;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%'
;

SELECT *
FROM layoffs_staging2
order by 1;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
order by 1;

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR (`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR (`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT SUBSTRING(`date` ,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date` ,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date` ,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date` ,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;


SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
), Company_Year_Rank AS
(SELECT *, dense_rank() over (PARTITION BY years ORDER BY total_laid_off DESC) as Ranking
FROM Company_Year
where years is not null
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <=5;
;