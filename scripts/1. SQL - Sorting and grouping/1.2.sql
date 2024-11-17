select round(avg(price), 2) as avg_price, category
from products
where name ilike '%Hair%' or name ilike '%Home%'
group by category;