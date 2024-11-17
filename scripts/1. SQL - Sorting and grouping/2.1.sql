select 
	seller_id, 
	count(distinct category) as total_categ,
	avg(rating) as avg_rating,
	sum(revenue) as total_revenue,
	case
	    -- если у продавца две записи с одинаковым значением категории, считаю это одной категорией
		when count(distinct category) > 1 then
			case
				when sum(revenue) > 50000 then 'rich'
				else 'poor'
			end
	end as seller_type
from sellers
where category != 'Bedding'
group by seller_id
having count(distinct category) > 1 -- чтобы не выводить ноунеймов, которые не poor и не rich
order by seller_id;