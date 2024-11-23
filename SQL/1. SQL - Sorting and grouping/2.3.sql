-- тип данных в столбцах date_reg и date - date

-- вариант решения при условии, что датой регистрации продавца считается самая ранняя из его дат регистраций
-- ни один из продавцов не будет выведен 
select 
    seller_id,
    string_agg(category, ' - ' order by category) as category_pair
from sellers
group by seller_id
having 
	extract(year from min(date_reg)) = 2022 
	and count(distinct category) = 2
	and	sum(revenue) > 75000
order by seller_id;


-- вариант решения при условии, что дата регистрации продавца - любая из дат регистраций 
-- выводится 4 продавца 
select 
    seller_id,
    string_agg(category, ' - ' order by category) as category_pair
    from sellers
    where extract(year from date_reg) = 2022
group by seller_id
having count(distinct category) = 2 and sum(revenue) > 75000
order by seller_id;
