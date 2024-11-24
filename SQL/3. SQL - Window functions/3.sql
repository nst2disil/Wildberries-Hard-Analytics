create table query (
    searchid serial primary key,
    year int,                                 
    month int,                  
    day int,                          
    userid int,                           
    ts int,                                
    devicetype VARCHAR(50),                  
    deviceid VARCHAR(50),                        
    query VARCHAR(255)                           
)

INSERT INTO query (year, month, day, userid, ts, devicetype, deviceid, query)
VALUES
(2024, 11, 20, 1, 1732104943, 'android', 'D1', 'к'),
(2024, 11, 20, 1, 1732104993, 'android', 'D1', 'ку'),
(2024, 11, 20, 1, 1732105063, 'android', 'D1', 'куп'),
(2024, 11, 20, 1, 1732105073, 'android', 'D1', 'купить'),
(2024, 11, 20, 1, 1732105107, 'android', 'D1', 'купить кур'),
(2024, 11, 20, 1, 1732105347, 'android', 'D1', 'купить куртку'),
(2024, 11, 20, 2, 1732104943, 'android', 'D2', 'к'),
(2024, 11, 20, 2, 1732104948, 'android', 'D2', 'ку'),
(2024, 11, 20, 2, 1732105043, 'android', 'D2', 'куп'),
(2024, 11, 20, 2, 1732105143, 'android', 'D2', 'купить'),
(2024, 11, 20, 2, 1732105347, 'android', 'D2', 'купить джинсы'),
(2024, 11, 20, 3, 1732104943, 'ios', 'D3', 'телефон'),
(2024, 11, 20, 3, 1732104949, 'ios', 'D3', 'купить телефон'),
(2024, 11, 20, 3, 1732104960, 'ios', 'D3', 'купить телефон samsung'),
(2024, 11, 20, 3, 1732119747, 'android', 'D33', 'ноутбук'),
(2024, 11, 20, 3, 1732119867, 'android', 'D33', 'купить ноутбук'),
(2024, 11, 20, 3, 1732119887, 'android', 'D33', 'купить ноутбук 128'),
(2024, 11, 20, 4, 1732130667, 'android', 'D4', 'куртка'),
(2024, 11, 20, 4, 1732130699, 'android', 'D4', 'купить куртку'),
(2024, 11, 20, 4, 1732130767, 'android', 'D4', 'купить куртку зимнюю'),
(2024, 11, 20, 4, 1732131507, 'android', 'D4', 'купить'),
(2024, 11, 20, 4, 1732138767, 'android', 'D4', 'купить куртку зимн'),
(2024, 11, 20, 4, 1732138768, 'android', 'D4', 'купить куртку зи');

with next_queries as (
select 
	year, month, day, userid, ts, devicetype, deviceid, query,
	-- следующая строка в окне - следующий запрос пользователя (разные устройства пользователя - разные подсчёты запросов)
	lead(query) over (partition by userid, devicetype order by ts) as next_query, 
	-- временная метка следующего запроса 
	lead(ts) over (partition by userid, devicetype order by ts) as next_ts
from query
)

select *
from 
(
	select
		year, 
	    month, 
	    day, 
	    userid, 
	    ts, 
	    devicetype, 
	    deviceid, 
	    query,
	    next_query,
	    case 
	        when next_query is null then 1
	        when length(next_query) < length(query) and next_ts - ts > 60 then 2
	        when next_ts - ts > 180 then 1
	        else 0
	    end as is_final
	from next_queries
)
where year = 2024 and month = 11 and day = 20 and devicetype = 'android' and is_final in (1, 2);


