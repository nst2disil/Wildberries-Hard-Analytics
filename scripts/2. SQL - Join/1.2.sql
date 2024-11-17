-- тип данных значений столбцов order_date и shipment_date - date

-- временная таблица для хранения количества заказов, общей суммы заказов 
-- и среднего времени между заказом и доставкой для каждого покупателя
with count_orders as ( 
select 
	c.customer_id,
	sum(order_ammount) as sum_order_ammount,
	avg(o.shipment_date - o.order_date) as avg_waiting_time,
	count(*) as orders_num
from customers_new c join orders_new o on c.customer_id = o.customer_id
group by c.customer_id
)

select 
	customer_id,
	avg_waiting_time,
	sum_order_ammount
from count_orders
where orders_num = (
						select max(orders_num) 
						from count_orders
				   )
order by sum_order_ammount desc;