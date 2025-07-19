select count(*) as customers_count
from customers;
--5.1. top_10_total_income.csv. Десятка лучших продавцов.
select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.quantity) as operations,
    floor(sum(s.quantity * p.price)) as income
from sales as s
left join employees as e on s.sales_person_id = e.employee_id
left join products as p on s.product_id = p.product_id
group by e.first_name, e.last_name
order by income desc nulls last limit 10;
--5.2. lowest_average_income.csv.
with avg_inc_saller as (
    select distinct
        concat(e.first_name, ' ', e.last_name) as seller,
        floor(
            avg(s.quantity * p.price)
                over (partition by e.first_name, e.last_name)
        ) as average_income,
        floor(avg(s.quantity * p.price) over ()) as avg_all_income
    from sales as s
    left join employees as e on s.sales_person_id = e.employee_id
    left join products as p on s.product_id = p.product_id
    order by average_income nulls last
)

select
    seller,
    average_income
from avg_inc_saller
where average_income < avg_all_income;
--5.3.day_of_the_week_income.csv.
select
    concat(e.first_name, ' ', e.last_name) as seller,
    to_char(s.sale_date, 'day') as day_of_week,
    floor(sum(s.quantity * p.price)) as income
from employees as e
left join sales as s on e.employee_id = s.sales_person_id
left join products as p on s.product_id = p.product_id
group by
    e.first_name, e.last_name, day_of_week, date_part('isodow', s.sale_date)
order by date_part('isodow', s.sale_date)
--6.1. age_groups.csv с возрастными группами покупателей
select case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        when age > 40 then '40+'
    end as age_category,
    count(*) as age_count
from customers
group by
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        when age > 40 then '40+'
    end
order by age_category;
--6.2. customers_by_month.csv
select
    to_char(s.sale_date, 'YYYY-MM') as selling_month,
    count(distinct s.customer_id) as total_customers,
    floor(sum(s.quantity * p.price)) as income
from sales as s
left join products as p on s.product_id = p.product_id
group by selling_month
order by selling_month;
--6.3. special_offer.csv
with tbl_answ as (
    select
        s.sale_date,
        concat(c.first_name, ' ', c.last_name) as customer,
        concat(e.first_name, ' ', e.last_name) as seller,
        row_number() over (
            partition by c.first_name, c.last_name
            order by s.sale_date
        ) as rn
    from sales as s
    left join customers as c on s.customer_id = c.customer_id
    left join employees as e on s.sales_person_id = e.employee_id
    left join products as p on s.product_id = p.product_id
    where p.price = 0 and s.sale_date is not null
    order by s.customer_id
)

select
    customer,
    sale_date,
    seller
from tbl_answ
where rn = 1;
