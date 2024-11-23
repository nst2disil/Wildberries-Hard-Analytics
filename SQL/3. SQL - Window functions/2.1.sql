select distinct
	sal.shopnumber, 
	sh.city, 
	sh.address, 
	sum(sal.qty) over (partition by sal.shopnumber) as sum_qty,
	sum(sal.qty * g.price) over (partition by sal.shopnumber) as sum_qty_price
from sales sal 
join shops sh on sal.shopnumber = sh.shopnumber
join goods g on sal.id_good = g.id_good
-- взяла другую дату, так как в таблице нет продаж за 2.01.2016
where date = '1.01.2016';