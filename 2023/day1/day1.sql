SELECT 
	SUM(
		CAST(
			CONCAT(
				left(regexp_replace(column0, '^[^0-9]+', ''), 1), 
				right(regexp_replace(column0, '[^0-9]+$', ''), 1)
			) 
		AS INT)
	) AS solution_part1
FROM read_csv('day1/input', columns = {'column0': 'VARCHAR'});

WITH 
	data AS (
		SELECT
			replace(
			replace(
			replace(
			replace(
			replace(
			replace(
			replace(
			replace(
			replace(
			replace(
			replace(
			replace(
			replace(
			replace(
			replace(
			column0, 'eightwo', '82'), 
				     'eightree', '83'), 
					 'oneight', '18'), 
			         'threeight', '38'), 
			 		 'fiveight', '58'),
					 'twone', '21'),
					 'one', '1'), 
					 'two', '2'), 
				     'three', '3'), 
					 'four', '4'), 
					 'five', '5'), 
					 'six', '6'), 
					 'seven', '7'), 
					 'eight', '8'), 
					 'nine', '9') 
			AS c
		FROM read_csv('day1/input', columns = {'column0': 'VARCHAR'})
	)

SELECT 
	SUM(
		CAST(
			CONCAT(
				left(regexp_replace(c, '^[^0-9]+', ''), 1), 
				right(regexp_replace(c, '[^0-9]+$', ''), 1)
			) 
		AS INT)
	) AS solution_part2
FROM data
;