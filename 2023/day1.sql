select 
	SUM(
		CAST(
			CONCAT(
				left(regexp_replace(column0, '^[^0-9]+', ''), 1), 
				right(regexp_replace(column0, '[^0-9]+$', ''), 1)
			) 
		AS INT)
	)
from 'data/day1.csv';