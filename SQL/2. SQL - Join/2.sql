-- временная таблица для хранения суммы продаж для каждой категории продуктов
with category_amount as
(
        select
                p.product_category,
                sum(o.order_amount) as total_amount
        from products p join orders_2 o on p.product_id = o.product_id
        group by p.product_category
        order by total_amount desc
)

select 
	product_category,
	total_amount,
	-- подзапрос для нахождения названия продукта с максимальной суммой продаж в категории
	(
                select p.product_name
                from products p join orders_2 o on p.product_id = o.product_id
                where p.product_category = category_amount.product_category
                group by p.product_name
                order by sum(o.order_amount) desc
                limit 1
	) as top_product,
	(
                select product_category
	        from category_amount
	        limit 1
	) as category_with_max_sum
from category_amount
order by total_amount desc;