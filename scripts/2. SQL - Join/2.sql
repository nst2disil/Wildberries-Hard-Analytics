select 
	product_category,
	total_amount,
	-- подзапрос для нахождения id продукта с максимальной суммой продаж в категории
	(select
        p.product_id
     from products p join orders_2 o on p.product_id = o.product_id
     where p.product_category = category_amount.product_category
     group by p.product_id
     order by sum(o.order_amount) desc
     limit 1
	) as top_product
from 
	-- подзапрос для нахождения суммы продаж для каждой категории продуктов
	(
		select
            p.product_category,
            sum(o.order_amount) as total_amount
        from products p join orders_2 o on p.product_id = o.product_id
        group by p.product_category
	) as category_amount
order by total_amount desc
limit 1;