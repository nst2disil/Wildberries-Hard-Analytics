-- временная таблица для хранения информации о рейтинге товаров
-- в каждом магазине за каждый день 
with goods_ranks as (
	select 
		g.id_good,
		sh.shopnumber,
		sal.date,
		sal.qty,
		-- нумерация товаров по рейтингу 
		row_number() over (partition by sh.shopnumber, sal.date order by sal.qty desc) as row_num 
	from sales sal 
	join shops sh on sal.shopnumber = sh.shopnumber
	join goods g on sal.id_good = g.id_good
)

select
	date as date_,
	shopnumber,
	id_good
from goods_ranks
where row_num <= 3; 