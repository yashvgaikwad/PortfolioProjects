-- Exploratory Data Analysis

select * from layoffs_staging2;

-- Adding another column to calculate the total number of employees
alter table layoffs_staging2 add total_employees varchar(50);

-- Standardizing the data
update layoffs_staging2
set total_laid_off = null
where total_laid_off = 'NULL';

update layoffs_staging2
set percentage_laid_off = null
where percentage_laid_off = 'NULL';

-- Exploring the data
select total_laid_off, percentage_laid_off
from layoffs_staging2
where total_laid_off is null or percentage_laid_off is null ;

-- Performing calculations to update the total_employees column
-- Using nullif to counter the divide by zero issue
update layoffs_staging2 
set total_employees = round((total_laid_off/nullif(percentage_laid_off,0)))
where total_laid_off is not null or percentage_laid_off is not null;

select total_laid_off, percentage_laid_off, total_employees
from layoffs_staging2 ;

-- Max number of people that got laid off & max percentage of lay offs
select max(cast(total_laid_off as unsigned)) as 'max of total_laid_off' , 
max(cast(percentage_laid_off as unsigned)) as 'max of percentage_laid_off'
from layoffs_staging2
order by 2;

-- Sum of the total number of people that got laid off by their respective companies
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- Industry that got hit the most by layoffs
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- Date ranges of this dataset
select min(`date`), max(`date`)
from layoffs_staging2;

-- Sum of the total laid off people per year
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

select company, cast(total_employees as unsigned)
from layoffs_staging2
order by 2 desc;

select company, max(cast(total_employees as unsigned)), min(cast(total_employees as unsigned))
from layoffs_staging2
group by company
order by 1 asc;

select stage, AVG(percentage_laid_off)
from layoffs_staging2
group by stage
order by 2 DESC;

-- Total industry layoffs every year
select 
year(`date`),
sum(total_laid_off) as total_layoffs,
sum(total_employees) as total_employees,
round(sum(cast(total_laid_off as unsigned)) / sum(nullif(cast(total_employees as unsigned),0)) * 100, 2) as overall_layoff_percentage
from layoffs_staging2
group by year(`date`)
order by year(`date`);

-- Top 10 companies with the highest layoff
select company, cast(total_laid_off as unsigned)
from layoffs_staging2
order by 2 desc
limit 10;

-- Highest layoff percentage 
select company, percentage_laid_off
from layoffs_staging2
where total_employees > 1000
order by 2 desc;

-- Total layoffs per industry
select 
industry,
sum(total_laid_off) as total_layoffs,
sum(total_employees) as total_employees,
round(sum(cast(total_laid_off as unsigned)) / sum(nullif(cast(total_employees as unsigned),0)) * 100, 2) as industry_layoff_percentage
from layoffs_staging2layoffs_staging2
group by industry
order by industry_layoff_percentage desc;

-- Companies that laid off >50% of their staff
select 
company, percentage_laid_off, total_employees, total_laid_off
from layoffs_staging2
where percentage_laid_off > 0.5
order by 2 desc;

-- Layoffs vs Company size
select 
    case
		when total_employees < 100 then 'small'
        when total_employees between 100 and 1000 then 'medium'
        else 'large'
	end as company_size,
	count(company) as companies,
    sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by company_size;

-- Most resilient companies
-- High employee count, zero or least layoff
select 
year(`date`), company, total_employees, total_laid_off, percentage_laid_off
from layoffs_staging2
where percentage_laid_off < 0.02 and total_employees > 1000 
order by percentage_laid_off, year(`date`) ;

select substring(`date`,1,7) as `MONTH` , sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `MONTH`
order by 1 asc;

-- Calculating the Rolling Total using CTE
with Rolling_Total as
(select substring(`date`,1,7) as `MONTH` , sum(total_laid_off) as total_laid_offs
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `MONTH`
order by 1 asc)
select `MONTH`, total_laid_offs, sum(total_laid_offs) over (order by `MONTH`) as rolling_total
from Rolling_Total;

-- Cross checking the rolling total
select sum(total_laid_off)
from layoffs_staging2
where `date` is not null;

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order  by 2 desc;

select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order  by 3 desc;

with company_year (company, years, total_laid_off) as
(select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), company_year_rank as 
(select * , dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)
select * 
from company_year_rank
where ranking <= 5;