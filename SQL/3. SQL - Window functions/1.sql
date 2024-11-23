-- список сотрудников с именами сотрудников, получающих самую высокую зарплату в отделе
-- 1 способ
select
	s.first_name, 
	s.last_name,
	s.salary, 
	s.industry,
	(
		-- подзапрос для нахождения сотрудника с самой высокой зарплатой в отделе 
		select first_name
     	from salary s2
     	where s.industry = s2.industry
     	and s2.salary = m.max_salary
    ) as name_highest_sal
from salary s
join (
		-- подзапрос для нахождения максимальной зарплаты в каждом отделе
		select
			industry,
			max(salary) as max_salary
		from salary
		group by industry
	 ) as m
on s.industry = m.industry
order by s.id;

-- 2 способ
select
	    first_name,
	    last_name,
	    salary,
	    industry,
	    first_value(first_name) over (partition by industry order by salary desc) as name_highest_sal
from salary
order by id;
    

-- аналогично с минимальной зарплатой в отделе
-- 1 способ
select
	s.first_name, 
	s.last_name,
	s.salary, 
	s.industry,
	(
		select first_name
     	from salary s2
     	where s.industry = s2.industry
     	and s2.salary = m.min_salary
    ) as name_lowest_sal
from salary s
join (
		select
			industry,
			min(salary) as min_salary
		from salary
		group by industry
	 ) as m
on s.industry = m.industry
order by s.id;

-- 2 способ
select
	    first_name,
	    last_name,
	    salary,
	    industry,
	    first_value(first_name) over (partition by industry order by salary) as name_lowest_sal
from salary
order by id;

