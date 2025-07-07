select count(*) as customers_count
from customers;

--5.1. top_10_total_income.csv. Десятка лучших продавцов.
select concat(e.first_name, ' ', e.last_name) as seller, count(s.quantity) as operations, floor(sum(s.quantity * p.price)) as income
from employees as e
left join sales as s on e.employee_id = s.sales_person_id
left join products as p on s.product_id = p.product_id
group by e.first_name, e.last_name
order by income desc nulls last limit 10;

--5.2. lowest_average_income.csv.
with avg_inc_saller as
		(select
			concat(e.first_name, ' ', e.last_name) as seller,
			floor(sum(s.quantity * p.price) / count(s.quantity)) as average_income,
			round(avg(round(sum(s.quantity * p.price) / count(s.quantity),0)) over (), 0) as avg_all_income
		from employees as e
		
		left join sales as s
		on e.employee_id = s.sales_person_id
		
		left join products as p
		on s.product_id = p.product_id
		
		group by e.first_name, e.last_name
		order by average_income nulls last)
		
select
	seller,
	average_income
from avg_inc_saller
where average_income < avg_all_income;-


--5.3.day_of_the_week_income.csv.
select
	concat(e.first_name, ' ', e.last_name) as seller,
	lower(trim(to_char(s.sale_date, 'Day'))) as day_of_week,
	floor(sum(s.quantity * p.price)) as income
from employees as e
		
left join sales as s on e.employee_id = s.sales_person_id
left join products as p on s.product_id = p.product_id
		
group by e.first_name, e.last_name, day_of_week
having floor(sum(s.quantity * p.price)) is not null
order by case
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'monday'    then 1
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'tuesday'   then 2
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'wednesday' then 3
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'thursday'  then 4
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'friday'    then 5
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'saturday'  then 6
	when lower(trim(to_char(s.sale_date, 'Day'))) = 'sunday'    then 7
		 end, 
              seller;

              
--6.1. age_groups.csv с возрастными группами покупателей
select '16-25' as age_category, count(age) as age_count
from customers
where age between 16 and 25
group by age_category
union
select '26-40' as age_category, count(age)
from customers
where age between 26 and 40
group by age_category
union 
select '40+' as age_category, count(age)
from customers
where age > 40
group by age_category
order by age_category;


--6.2. customers_by_month.csv с количеством покупателей и выручкой по месяцам
select to_char(s.sale_date, 'YYYY-MM') as selling_month, count(distinct s.customer_id) as total_customers, floor(sum(s.quantity*p.price)) as income
from sales as s
left join products as p on p.product_id = s.product_id
group by selling_month
order by selling_month;


--6.3. special_offer.csv с покупателями первая покупка которых пришлась на время проведения специальных акций
with tbl_answ as
			(select
				row_number() over(partition by concat(c.first_name, ' ', c.last_name) order by s.sale_date) as rn,
				concat(c.first_name, ' ', c.last_name) as customer,
				s.sale_date,
				concat(e.first_name, ' ', e.last_name) as seller
			from customers as c
			
			left join sales as s on c.customer_id = s.customer_id
			left join employees as e on e.employee_id = s.sales_person_id
			left join products as p on p.product_id = s.product_id
			
			where s.sale_date is NOT null
				  and p.price = 0
			order by s.customer_id)
select customer, sale_date, seller
from tbl_answ
where rn = 1                                     
___________________________________________________________________