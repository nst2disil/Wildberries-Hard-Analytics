select
    seller_id,
    -- количество месяцев между текущей датой и минимальной датой регистрации продавца
    (current_date - min(to_date(date_reg, 'DD/MM/YYYY'))) / 30 as month_from_registration,
    -- разница между максимальным и минимальным сроком доставки среди всех poor продавцов, не считая категории Bedding
    (select max(delivery_days) - min(delivery_days) from (
    		-- сроки доставки всех poor продавцов, не считая категории Bedding
	    	select delivery_days
	    	from sellers
	    	where category != 'Bedding'
	    	group by seller_id, delivery_days
	    	having count(distinct category) > 1 and sum(revenue) <= 50000
	)) as max_delivery_difference
from sellers
where category != 'Bedding'
group by seller_id
having count(distinct category) > 1 and sum(revenue) <= 50000 
order by seller_id;

