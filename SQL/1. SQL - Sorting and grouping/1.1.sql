select 
    city,
    case
        when  age between 0 and 20 then 'young'
        when age between 21 and 49 then 'adult'
        when age >= 50 then 'old'
    end as age_category,
    count(*) as buyers_num
from users
group by city, age_category
order by city, buyers_num desc;