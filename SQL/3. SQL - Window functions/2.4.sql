-- временная таблица для хранения сумм продаж за каждую дату 
with sales_by_day as (
	select
		sal.date,
		sh.shopnumber,
		g.category,
		sum(sal.qty * g.price) as sales_sum_by_day
	from sales sal 
	join shops sh on sal.shopnumber = sh.shopnumber
	join goods g on sal.id_good = g.id_good
	where sh.city = 'СПб'
	group by sal.date, sh.shopnumber, g.category
	order by sal.date
)

select 
	date as date_,
	shopnumber,
	category,
	-- получение суммы продаж за предыдущий день
	lag(sales_sum_by_day) over (partition by shopnumber, category order by date) as prev_sales
from sales_by_day
order by shopnumber, date_;


