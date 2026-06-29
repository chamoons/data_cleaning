-- data cleaning
use world_layoffs;
show tables;
show databases;

select * from layoffs;

-- 1. remove duplicates
-- 2. standardize the data
-- 3. null values or blank values
-- 4. remove unnecessaray column or rows


create table layoffs_staging
like layoffs;


select * from layoffs_staging;

insert layoffs_staging
select * from layoffs;


select *, 
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date') as row_num
from layoffs_staging;


with duplicate_cte as
(
select *, 
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select * 
from duplicate_cte
where row_num >1;

select * from layoffs_staging
where company = 'Oda';


with duplicate_cte as
(
select *, 
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
delete 
from duplicate_cte
where row_num >1; -- if wwe try to delete the duplicate tables like this, it wont work

-- rigth click layoffs_staging and copy to clipboard and create statement


CREATE TABLE `layoffs_staging2`( -- new one
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

select * from layoffs_staging2; -- using the new one

insert into layoffs_staging2
select *,
row_number() over( partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as eow_num
from layoffs_staging;

select * from layoffs_staging2
where row_num > 1 ;

-- now u can delete it
delete  from layoffs_staging2
where row_num > 1 ;

set sql_safe_updates = 0;

select * from layoffs_staging2; -- now, theres no duplicate 2 in row num


-- standardizing data

select company, trim(company) -- trim if may mga spaces
from layoffs_staging2;

update layoffs_staging2
set company = trim(company); -- i update para sa real table naka trim na

select distinct industry -- isad isad na lang an sa industry compare pag wara an distinct na may mga double sinda
from layoffs_staging2
order  by 1; -- pasuronod

select * 
from layoffs_staging2
where industry like 'crypto%';

-- gin update para same lang an rows san crypto, kay an iba may crypto currency and so on
update layoffs_staging2
set industry = 'Crypto'
where industry like 'crypto%';

select  distinct industry 
from layoffs_staging2; -- now one na lang an crypto

select distinct country -- check column basi may duplicate
from layoffs_staging2
order by 1;

select * 
from layoffs_staging2
where country like 'united states%'
order by 1;

update layoffs_staging2
set country = 'United States'
where country like 'united states%';

select `date`
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y'); -- no need  to put semi colon when running this, i just put one so i can still execute the next one


-- dont do this to raw data

alter table layoffs_staging2
modify column `date` date; -- now it changed into date

-- 3. null values or blank values

select * from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;


select distinct industry
 from layoffs_staging2
 where industry is null
 or industry = '';

select *
 from layoffs_staging2
 where industry is null
 or industry = '';
 
 select *
 from layoffs_staging2
 where company = 'airbnb';
 
 -- dapat may travel sa industry an isad pa na airbnb
 
 select t1.industry, t2.industry
 from layoffs_staging2 t1
 join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

-- nothing change. so firts thing to do is make blank space into null

update layoffs_staging2
set industry = null
where industry = '';

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
set t1.industry = t2.industry
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

select * from layoffs_staging2;


-- 4 remove unnecessary column and rows

select * from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select * from layoffs_staging2;

-- try to delete the row num

alter table layoffs_staging2
drop column row_num;