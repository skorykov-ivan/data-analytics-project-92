--1. age_groups.csv с возрастными группами покупателей
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


_____________________________________________________________________________________________________

--2. customers_by_month.csv с количеством покупателей и выручкой по месяцам
select 
	to_char(s.sale_date, 'YYYY-MM') as selling_month,  -- Выводим месяц и год из даты
	count(s.customer_id) as total_customers,           -- Считаем количество покупателей
	round(sum(s.quantity*p.price), 0) as income        -- Считаем общую выручку
from sales s
left join products p
on p.product_id = s.product_id                --Присоединяем таблицу с продуктами, чтобы взять поле с ценой
group by selling_month
order by selling_month;

_____________________________________________________________________________________________________

--3. special_offer.csv с покупателями первая покупка которых пришлась на время проведения специальных акций
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
















