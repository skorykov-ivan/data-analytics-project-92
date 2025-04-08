--1. top_10_total_income.csv. Десятка лучших продавцов.
select 
	concat(e.first_name, ' ', e.last_name) as seller,    -- Конкатенация имени и фамилии 
	count(s.quantity) as operations,					 -- Считаем количество сделок 
	sum(s.quantity * p.price) as income					 -- Перемножаем в каждой строке количество товара, а потом суммируем все строки у каждого продавца
from employees e

left join sales s                                        -- Создаём одну общую таблицу со всеми нужными данными
on e.employee_id = s.sales_person_id

left join products p                                     -- Создаём одну общую таблицу со всеми нужными данными
on s.product_id = p.product_id

group by e.first_name, e.last_name                      -- Группируем по имени и фамилии, чтобы применить агрегирующие функции
order by income desc nulls last limit 10; 				 -- Сортируем по условиям и выводим топ-10 по выручке

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--2. lowest_average_income.csv.  Продавцы, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
with avg_inc_saller as                                  													-- Создаём таблицу, из которой создадим финальную таблицу
		(select 
			concat(e.first_name, ' ', e.last_name) as seller,                                               -- Конкатенация имени и фамилии 
			round(sum(s.quantity * p.price) / count(s.quantity),0) as average_income,					    -- Перемножаем в каждой строке количество товара, а потом суммируем все строки у каждого продавца
			round(avg(round(sum(s.quantity * p.price) / count(s.quantity),0)) over(), 0) as avg_all_income  -- Через оконную функцию получаем среднее значение выручки среди всех продавцов
		from employees e
		
		left join sales s                                   -- Создаём одну общую таблицу со всеми нужными данными
		on e.employee_id = s.sales_person_id
		
		left join products p                                -- Создаём одну общую таблицу со всеми нужными данными
		on s.product_id = p.product_id
		
		group by e.first_name, e.last_name
		order by average_income nulls last)
		
select 														-- Достаём из той таблицы
	seller,													-- нужные столбцы
	average_income
from avg_inc_saller
where average_income < avg_all_income;						-- Фильтруем, чтобы были отобраны только те продавцы, у которых выручка меньше средней выручки по всем продавцам

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3. day_of_the_week_income.csv. Отчет с данными по выручке по каждому продавцу и дню недели.
select 
	concat(e.first_name, ' ', e.last_name) as seller,                  -- Конкатенация имени и фамилии.
	trim(to_char(s.sale_date, 'Day')) as day_of_week,                  -- Получаем название дня недели и убираем лишние пробелы для сортировки.
	round(sum(s.quantity * p.price), 0) as income                      -- Высчитываем выручку в день недели
from employees e
		
left join sales s                                                      -- Создаём одну общую таблицу со всеми нужными данными  
on e.employee_id = s.sales_person_id
		
left join products p                                                   -- Создаём одну общую таблицу со всеми нужными данными
on s.product_id = p.product_id
		
group by e.first_name, e.last_name, day_of_week                        -- Группируем по имени, фамилии, дню недели 
order by case
	when trim(to_char(s.sale_date, 'Day')) = 'Monday'    then 1
	when trim(to_char(s.sale_date, 'Day')) = 'Tuesday'   then 2        -- В order by к каждому дню недели присваиваем цифру для корректной сортировки.
	when trim(to_char(s.sale_date, 'Day')) = 'Wednesday' then 3
	when trim(to_char(s.sale_date, 'Day')) = 'Thursday'  then 4
	when trim(to_char(s.sale_date, 'Day')) = 'Friday'    then 5
	when trim(to_char(s.sale_date, 'Day')) = 'Saturday'  then 6
	when trim(to_char(s.sale_date, 'Day')) = 'Sunday'    then 7
		 end, 
              seller;												   -- И не забываем в сортировке про имя и фамилию

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------