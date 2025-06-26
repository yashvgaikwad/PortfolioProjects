-- Data Cleaning
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

select * from layoffs;
select count(*) from layoffs;

-- 1. Check for duplicates and remove any
-- 2. Standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. Remove any columns and rows that are not necessary

-- We want to do is create a staging table. This is the one we will work in and clean the data
-- We want a table with the raw data in case something happens
create table layoffs_staging
LIKE layoffs;

select * from layoffs_staging;

-- Inserting data from raw table to the temp table
insert layoffs_staging select * from layoffs;
select * from layoffs_staging;


-- 1. Remove Duplicates

-- First let's check for duplicates
-- One solution, which I think is a good one. Is to create a new column and add those row numbers in 
-- Then delete where row numbers are over 2, then delete that column
select * ,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

-- These are the ones we want to delete where the row number is > 1 or 2or greater essentially
with duplicate_cte as 
(
select * ,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select * from duplicate_cte where row_num > 1;

-- Creating another duplicate table where actual calculations will be performed
CREATE TABLE `layoffs_staging2` (
  `company` varchar(50) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  `industry` varchar(50) DEFAULT NULL,
  `total_laid_off` varchar(50) DEFAULT NULL,
  `percentage_laid_off` varchar(50) DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  `stage` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `funds_raised_millions` varchar(50) DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

insert into layoffs_staging2 select * ,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

-- Delete rows were row_num is greater than 2
delete from layoffs_staging2 where row_num > 1;
select * from layoffs_staging2 ;

-- 2. Standardize the data

-- Standardizing the company names that start or end in blanks
select company, trim(company)
from layoffs_staging2 ;

-- It's fixed now
update layoffs_staging2
set company = trim(company);
select * from layoffs_staging2;

-- Standardizing the industry names that are the same
select distinct(industry)
from layoffs_staging2 
where industry like 'Crypto%'
order by 1;

-- It's fixed now
update layoffs_staging2
set industry = "Crypto"
where industry like 'Crypto%';

select * from layoffs_staging2;

select distinct(country)
from layoffs_staging2
order by 1;

-- We have some "United States" and some "United States." with a period at the end. Standardizing this
select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

-- It's fixed now
update layoffs_staging2
set country = trim(trailing '.' from country)
where country like '%United States%';

select distinct country 
from layoffs_staging2
order by 1;

-- Fixing the date column format
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = NULL
where `date` = 'NULL';

-- Using str to date to update this field
update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

-- Converting the data type properly from varchar to date
alter table layoffs_staging2
modify column `date` date;

select `date`
from layoffs_staging2
where `date` IS NULL;

-- 3. Looking at Null Values

-- The null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal
-- Having them null makes it easier for calculations during the EDA phase

-- There isn't anything I want to change with the null values for now

-- 4. Removing any columns, rows or values like blank spaces or 'NULL' (string format) we need to
select * 
from layoffs_staging2
where total_laid_off = 'NULL'
and percentage_laid_off = 'NULL';

select *
from layoffs_staging2
where industry = 'NULL' or industry = '';

select *
from layoffs_staging2
where company = 'Airbnb';

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2 
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry = 'NULL' or t1.industry = '')
and t2.industry != 'NULL';
    
update layoffs_staging2
set industry = NULL
where industry = 'NULL' or industry = '';
    
update layoffs_staging2 t1
join layoffs_staging2 t2 
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is NULL
and t2.industry is not NULL;
    
select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2 
	on t1.company = t2.company
    and t1.location = t2.location
where t1.industry is NULL
and t2.industry is not NULL;   
    
select *
from layoffs_staging2
where company like 'Bally%';

-- Deleting any useless data that we don't need
delete 
from layoffs_staging2
where total_laid_off = 'NULL'
and percentage_laid_off = 'NULL';

alter table layoffs_staging2
drop column row_num;

select * from layoffs_staging2;









