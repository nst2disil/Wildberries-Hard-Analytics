-- тип данных значений в столбцах order_date и shipment_date - date

select 
	c.customer_id, 
	count(
		case 
			when o.shipment_date - o.order_date > 5
			then 1
		end
	) as late_orders_num,
	count(
		case 
			when o.order_status = 'Cancel'
			then 1
		end
	) as cancelled_orders_num,
	-- общая сумма отменённых или опоздавших заказов 
	sum(o.order_ammount) as bad_orders_ammount
from customers_new c join orders_new o on c.customer_id = o.customer_id
where 
	o.shipment_date - o.order_date > 5
	or o.order_status = 'Cancel'
group by c.customer_id
-- сортировка по общей сумме отменённых или опоздавших заказов
order by bad_orders_ammount desc;