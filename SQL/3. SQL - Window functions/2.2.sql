-- для каждого города 
-- нахожу долю продаж товаров категории "ЧИСТОТА" за конкретную дату 
-- от суммарной продажи товаров этой категории за все даты
select
	sal.date as date_, 
	sh.city,
	-- (сумма продаж товаров категории "ЧИСТОТА" за день в городе) / (сумма продаж за все дни в городе)
	sum(sal.qty * g.price) / sum(sum(sal.qty * g.price)) over (partition by sh.city) as sum_sales_rel
from sales sal 
join shops sh on sal.shopnumber = sh.shopnumber
join goods g on sal.id_good = g.id_good
where g.category = 'ЧИСТОТА'
group by sal.date, sh.city
order by sal.date;