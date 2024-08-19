# Исследование данных таблицы

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

select *
from layoffs_staging2
where percentage_laid_off=1
order by total_laid_off desc;

select company, SUM(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select MIN(`date`), MAX(`date`)
from layoffs_staging2;

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

select `date`, sum(total_laid_off)
from layoffs_staging2
group by `date`
order by 2 desc;

select YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
group by YEAR(`date`)
order by 2 desc;

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

select company, AVG(percentage_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

Select substring(`date`,6,2) as `month`, sum(total_laid_off)
from layoffs_staging2
group by `month`;

Select substring(`date`,1,7) as `month`, sum(total_laid_off)
from layoffs_staging2
group by `month`
order by 1 asc;

Select substring(`date`,1,7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc;

WITH rolling_total as
(
Select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month`, total_off, sum(total_off) over(order by `month`) as Rolling_month
from rolling_total;

select company, SUM(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select company, YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
group by company, YEAR(`date`)
order by 3 desc;

WITH Company_Year (company, years, total_laid_off) as
(
select company, YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
group by company, YEAR(`date`)
)
select *, dense_rank() Over(Partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
order by ranking asc
;

WITH Company_Year (company, years, total_laid_off) as
(
select company, YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
group by company, YEAR(`date`)
)
, Company_Year_Rank As
(
select *, dense_rank() Over(Partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)
Select *
From Company_Year_Rank
Where Ranking <= 5
;