select 
	count(*) as customers_count
from customers;

-- В данном запросе мы считаем общее количество строк по имени. Так же можно посчитать по count(*). Дубликатов нет.

-- ___________________________________________________________________

--5.1. top_10_total_income.csv. Десятка лучших продавцов.
	select 
		concat(e.first_name, ' ', e.last_name) as seller,    -- Конкатенация имени и фамилии 
		count(s.quantity) as operations,					 -- Считаем количество сделок 
		floor(sum(s.quantity * p.price)) as income					 -- Перемножаем в каждой строке количество товара, а потом суммируем все строки у каждого продавца
	from employees e
	
	left join sales s                                        -- Создаём одну общую таблицу со всеми нужными данными
	on e.employee_id = s.sales_person_id
	
	left join products p                                     -- Создаём одну общую таблицу со всеми нужными данными
	on s.product_id = p.product_id
	
	group by e.first_name, e.last_name                      -- Группируем по имени и фамилии, чтобы применить агрегирующие функции
	order by income desc nulls last limit 10; 				 -- Сортируем по условиям и выводим топ-10 по выручке

-- ___________________________________________________________________
--5.2. lowest_average_income.csv.  Продавцы, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
with avg_inc_saller as                                  													-- Создаём таблицу, из которой создадим финальную таблицу
		(select 
			concat(e.first_name, ' ', e.last_name) as seller,                                               -- Конкатенация имени и фамилии 
			floor(sum(s.quantity * p.price) / count(s.quantity)) as average_income,					    -- Перемножаем в каждой строке количество товара, а потом суммируем все строки у каждого продавца
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

-- ___________________________________________________________________
--5.3. day_of_the_week_income.csv. Отчет с данными по выручке по каждому продавцу и дню недели.
select 
	concat(e.first_name, ' ', e.last_name) as seller,                  -- Конкатенация имени и фамилии.
	lower(trim(to_char(s.sale_date, 'Day'))) as day_of_week,                  -- Получаем название дня недели и убираем лишние пробелы для сортировки.
	floor(sum(s.quantity * p.price)) as income                      -- Высчитываем выручку в день недели
from employees e
		
left join sales s                                                      -- Создаём одну общую таблицу со всеми нужными данными  
on e.employee_id = s.sales_person_id
		
left join products p                                                   -- Создаём одну общую таблицу со всеми нужными данными
on s.product_id = p.product_id
		
group by e.first_name, e.last_name, day_of_week                        -- Группируем по имени, фамилии, дню недели 
having floor(sum(s.quantity * p.price)) is not null
order by case
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'monday'    then 1
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'tuesday'   then 2        -- В order by к каждому дню недели присваиваем цифру для корректной сортировки.
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'wednesday' then 3
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'thursday'  then 4
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'friday'    then 5
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'saturday'  then 6
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'sunday'    then 7
		 end, 
              seller;												   -- И не забываем в сортировке про имя и фамилию

-- ___________________________________________________________________

--6.1. age_groups.csv с возрастными группами покупателей
select 
	'16-25' as age_category,  -- Создаём нужную строку с возрастом
	count(age) as age_count   -- Считаем количество людей с нужным возрастом
FROM customers
where age between 16 and 25   -- Фильтруем по нужному возрасту
group by age_category         -- Группируем по новой строчке 
union             -- Соединяем ещё 2 раза такие же табоицы, но с 2 другими возрастные категориями
select 
	'26-40' as age_category,
	count(age)
FROM customers
where age between 26 and 40
group by age_category
union 
select 
	'40+' as age_category,
	count(age)
FROM customers
where age > 40
group by age_category
order by age_category;


-- ___________________________________________________________________

--6.2. customers_by_month.csv с количеством покупателей и выручкой по месяцам
select 
	to_char(s.sale_date, 'YYYY-MM') as selling_month,  -- Выводим месяц и год из даты
	count(s.customer_id) as total_customers,           -- Считаем количество покупателей
	round(sum(s.quantity*p.price), 0) as income        -- Считаем общую выручку
from sales s
left join products p
on p.product_id = s.product_id                --Присоединяем таблицу с продуктами, чтобы взять поле с ценой
group by selling_month
order by selling_month;

-- ___________________________________________________________________

--6.3. special_offer.csv с покупателями первая покупка которых пришлась на время проведения специальных акций
select
	concat(c.first_name, ' ', c.last_name) as customer,   --Выводим имя и фамилию покупателя 
	min(s.sale_date) as sale_date,						  --Выводим самую первую покупку
	concat(e.first_name, ' ', e.last_name) as seller     --Выводим имя и фамилию продавца 
from customers c
left join sales s
on c.customer_id = s.customer_id
left join employees e                     --Присоединяем друг к другу все 4 таблицы
on e.employee_id = s.sales_person_id
left join products p
on p.product_id = s.product_id

where s.sale_date is NOT null 				--Убираем NULL значения и учитываем только те строки, где был куплен акционный товар
	  and p.price = 0
group by customer, seller, c.customer_id

order by c.customer_id;

___________________________________________________________________