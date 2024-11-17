-- вариант решения при условии, что датой регистрации продавца считается самая ранняя из его дат регистраций
-- ни один из продавцов не будет выведен 
select 
    seller_id,
    string_agg(category, ' - ' ORDER BY category) as category_pair
from sellers
group by seller_id
having 
	extract(year from min(to_date(date_reg, 'DD-MM-YYYY'))) = 2022 
	and count(DISTINCT category) = 2
	and	sum(revenue) > 75000
order by seller_id;


-- вариант решения при условии, что дата регистрации продавца - любая из дат регистраций 
-- выводится 4 продавца 
select 
    seller_id,
    string_agg(category, ' - ' ORDER BY category) as category_pair
    from sellers
    where extract(year from to_date(date_reg, 'DD-MM-YYYY')) = 2022
group by seller_id
having count(DISTINCT category) = 2 and sum(revenue) > 75000
order by seller_id;
