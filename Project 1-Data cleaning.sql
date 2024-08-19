# 1. Сначала создаем таблицу
# 2. Затем скачиваем csv файлa
 
select * 
from layoffs;

-- 1. Remove duplicates
-- 2. Standardized the Data
-- 3. Null values or blank values
-- 4. Remove any columns

# 1. Сначала создадим другую таблицу, на основе импортированной
Create table layoffs_staging
like layoffs;

select * 
from layoffs_staging;

Insert layoffs_staging
select *
from layoffs;

# 2. Находим дубликаты
# 2.1 Создаем row_number для определния дубликатов (кол-во повторений) 
select *, 
row_number() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`)
from layoffs_staging;

# 2.2 Проверяем действительно ли являются дубликатами
Select *
from layoffs_staging
Where company='Oda';

# 2.3 Создаем временную таблицу со доп столбцом row_num
with duplicates_cte AS 
(
select *, 
row_number() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
SELECT *
from duplicates_cte
where row_num>1;

# 2.4 Создаем таблицу чтобы удалить дубликаты и в дальнейшем работать с таблицей
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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from layoffs_staging2;

Insert into layoffs_staging2
select *, 
row_number() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

select * 
from layoffs_staging2
WHERE row_num > 1;

# 2.5 Удаляем дубликаты 
DELETE
from layoffs_staging2
WHERE row_num > 1;

select * 
from layoffs_staging2;

# 3. Приводим таблицы в стандартный вид
# 3.1 Убираем лишний пробел спереди 1го слова 
select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company=trim(company);

# 3.2 Убираем похожие названия индустрии и делаем 1 целый.
select distinct industry
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry like 'crypto%';

Update layoffs_staging2
set industry='Crypto'
where industry like 'Crypto%';

select distinct industry
from layoffs_staging2
order by 1;

# 3.3 Убираем похожие названия стран и делаем 1 целый.
select distinct country
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where country like 'united states%';

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United states%';

# 3.4 Меняем формат даты: с текста на дату
select `date`
from layoffs_staging2;

select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

# 3.4.1 Меняем обозначение даты
update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

select `date`
from layoffs_staging2;

# 3.4.2 Меняем формат с текста на дату
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

# 4. Удаляем (корректируем) пустые значения в строках 
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2
where industry is null
or industry = '';

select *
from layoffs_staging2
where company='airbnb';

select *
from layoffs_staging2
where company='carvana';

select *
from layoffs_staging2
where company='juul';

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	ON t1.company=t2.company
Where (t1.industry is null OR t1.industry = '')
AND t2.industry is not null;

Update layoffs_staging2 t1
Join layoffs_staging2 t2
ON t1.company=t2.company
set t1.industry=t2.industry
Where (t1.industry is null OR t1.industry = '')
AND t2.industry is not null;

update layoffs_staging2
set industry=null
where industry='';

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	ON t1.company=t2.company
Where (t1.industry is null OR t1.industry = '')
AND t2.industry is not null;

Update layoffs_staging2 t1
Join layoffs_staging2 t2
ON t1.company=t2.company
set t1.industry=t2.industry
Where t1.industry is null
AND t2.industry is not null;

select *
from layoffs_staging2
where company like 'airbn%';

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

# 4.1 Удаляем NULL столбцы
DELETE
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

# 4.2 Удаляем столбец row_num
ALTER TABLE layoffs_staging2
drop column row_num;

select *
from layoffs_staging2;