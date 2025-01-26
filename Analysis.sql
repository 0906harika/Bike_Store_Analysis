SELECT * FROM staffs;

select * from customers;

select * from orders;

select * from stores;

--Which brand has the most products in the store?

select brand_name,count(products.product_id) as total from brands inner JOIN
products on products.brand_id = brands.brand_id 
group by brands.brand_id
order by total desc;

--Which product is the most ordered?

select products.product_id,
product_name,sum(quantity) as total from 
products inner join order_items ON
products.product_id = order_items.product_id 
group by products.product_id
order by total desc;

--Which product earned the most revenue?

with price as (
  select product_id, quantity, 
  list_price,discount,list_price * quantity * (1-discount) as final from order_items)
select products.product_name,products.product_id,sum(final) as sales_revenue  
from price
inner join products ON
products.product_id = price.product_id
group by price.product_id
order by sales_revenue desc;

--In which product category were the most units sold?

with p_category as (
  select product_id, quantity, list_price,
  list_price * quantity  as total 
  from order_items)
select sum(p_category.total) as revenue, sum(p_category.quantity) as unit_sold ,
categories.category_id, categories.category_name from p_category
inner join products on p_category.product_id = products.product_id
inner join categories on products.category_id = categories.category_id
group by categories.category_id
order by unit_sold desc;

--Which product is sold out in each store? 

select product_name,store_name,products.product_id from stocks
inner join stores on stocks.store_id = stores.store_id
inner join products on products.product_id = stocks.product_id
where quantity =0;

--Which products are sold out in one store but available in others? And its quantity?

with sold_out as (
select stores.store_name,stocks.product_id,product_name 
from stores inner join stocks 
on stores.store_id = stocks.store_id inner JOIN
products on products.product_id = stocks.product_id
where quantity =0)
select stocks.store_name, sold_out.product_id, stock.quantity,
sold_out.product_name from sold_out left join (select 
stores.store_name, stocks.product_id, stocks.product_id,
stocks.quqntity, products.product_name from stocks JOIN
stores on stocks.store_id = stores.store_id inner JOIN
products on stocks.product_id = products.product_id) stocks 
on sold_out.product_id = stocks.product_id

--Calculate the average bike price for each model year

select model_year,avg(list_price) as avg_price from products
group by model_year;

--How many staffs are active in all stores?

select active,count(active) as working from staffs 
group by active;

--Who is the top manager?

select * from staffs where manager_id is null;

--Who are managers in each store?

select * from staffs where manager_id =1;

--List of employees in each store?

SELECT stores.store_name,concat(first_name ||' ' || last_name) as employees
FROM staffs
JOIN stores ON staffs.store_id = stores.store_id
group by stores.store_name
ORDER BY stores.store_name desc;

--Which state has the most customers?

select state, count(customer_id) as highest
from customers 
group by state
order by highest desc;

--Which customers have made the highest number of orders?

with highest_orders as 
( select first_name, last_name,customers.customer_id,
 count(orders.order_id) as nb_orders,orders.store_id
 from orders inner join customers 
 on customers.customer_id = orders.customer_id
 group by customers.customer_id
 )
 select * from highest_orders where nb_orders =
 (select max(nb_orders) from highest_orders)
  order by store_id;
  
--Latest order by customer?

with recent_orders as(
select distinct customer_id,store_id,max(order_date) over
  (partition by customer_id) as latest_orders from orders)
  select * from recent_orders where strftime('%Y',latest_order) IS '2018'
  ORDER BY store_id;
  
--Which orders are late-shipped?

select order_id, required_date,shipped_date,
case when required_date <= shipped_date then 0 else 1
end as late_shipping, store_id from orders
where shipped_date is not null and late_shipping = 1;

--Which store has the most late-shipped orders? 
with status as (
select order_id,required_date, shipped_date,
case when required_date < = shipped_date then 0 else 1 
end as late_shipping, store_id
from orders where shipped_date is not Null and late_shipping = 1
)

select store_id,count(late_shipping) as most_shipped_orders from status
group by store_id;

--Customer engagement

select customers.customer_id, store_id, 
count(orders.order_id) as nb_count,
first_name, last_name
from customers inner join orders ON
customers.customer_id = orders.customer_id
group by customers.customer_id;

--Average monthly sales  

SELECT strftime('%m', order_date) AS order_month, AVG(b.price) as avg_order_bills 
FROM orders a JOIN (SELECT order_id, SUM(quantity*list_price*(1-discount)) AS price 
FROM order_items GROUP BY order_id) b 
ON a.order_id = b.order_id GROUP BY order_month;

--Average monthly sales by category

select strftime('%m' , orders.order_date) as order_month,
products.category_id,categories.category_name,
avg(order_items.quantity * order_items.list_price * (1- order_items.discount))
as price from order_items
inner join products on order_items.product_id = products.product_id
inner join categories on products.category_id = categories.category_id
inner join orders on order_items.order_id = orders.order_id
group by order_month, products.category_id;

--Average monthly unit ordered by category

select strftime('%m', o.order_date) as order_month, 
avg(oi.quantity) as avg_quantity, category_name, p.category_id 
from orders o 
inner JOIN order_items oi on o.order_id = oi.order_id 
inner join products p ON oi.product_id = p.product_id 
inner join categories c on p.category_id = c.category_id
group by p.category_id,order_month;

--Distribution of different brands within the store 

select count(p.product_id) as product_brand,
brand_name from brands b 
inner join products p on 
b.brand_id = p.brand_id 
group by b.brand_id 
order by product_brand desc;

--Percentage of late shipments per store
with percenatge_sales as (
select store_id,case when required_date <= shipped_date then 0 else 1 end)
as late_shipped from orders where shipped_date is not null)

select store_id,sum(late_shipped) as late, count(late_shipped) as total,
cast(100*sum(late_shipped) / count(late_shipped) as float) as percentage
from percentage_sales
group by store_id;

--Total number of customers from each state 

select count(customer_id) as total,state from customers
group by state
order by total desc;

--Average bike price by model year 

select avg(list_price) as avg_price, model_year from products
group by model_year
order by avg_price desc;











