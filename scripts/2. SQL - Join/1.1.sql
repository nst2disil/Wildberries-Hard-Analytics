-- тип данных значений в столбцах order_date и shipment_date - date

-- решение 1: вывод первого покупателя с самым долгим временем ожидания
select 
	c.customer_id, 
    o.shipment_date - o.order_date AS waiting_time
from customers_new c join orders_new o on c.customer_id = o.customer_id
order by
    waiting_time desc
limit 1;


-- решение 2: вывод всех покупателей с самым долгим временем ожидания
select 
	c.customer_id, 
	o.shipment_date - o.order_date as waiting_time
from customers_new c join orders_new o on c.customer_id = o.customer_id
where o.shipment_date - o.order_date =
	-- подзапрос для нахождения максимального времени ожидания
	(
		select max(o2.shipment_date - o2.order_date)
		from orders_new o2
	)
	