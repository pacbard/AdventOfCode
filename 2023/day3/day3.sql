.maxrows -1

WITH
import AS (
	SELECT 
		ROW_NUMBER() OVER () AS row,
		regexp_extract_all(schematics, '(.)', 1) AS schematics,
	FROM read_csv('day3/input', columns = {'schematics': 'VARCHAR'})
),
numbers AS (
	SELECT
		row,
		unnest(schematics) as number,
		generate_subscripts(schematics, 1) AS loc
	FROM
		import
),
number_filter AS (
	SELECT
		row,
		loc,
		lag(loc, 1, 1) OVER(PARTITION BY row ORDER BY row, loc) AS lag,
		number
	FROM 
		numbers

	WHERE
		number IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')

	ORDER BY row, loc
),
number_group AS (
	SELECT
		row,
		loc,
		CASE WHEN loc =  lag + 1 THEN 0 ELSE 1 END AS group_bump,
		number
		
	FROM 
		number_filter

	ORDER BY row, loc
),
number_groups AS (
	SELECT
		row,
		CAST(loc AS INT) AS loc,
		SUM(group_bump) OVER (ORDER BY row, loc) AS ngroup,
		number
		
	FROM 
		number_group

	ORDER BY row, loc
),
number_candidates AS (
	SELECT
		row,
		min(loc) OVER (PARTITION BY row, ngroup) AS loc_start,
		max(loc) OVER (PARTITION BY row, ngroup) AS loc_end,
		CAST(string_agg(number, '') OVER (PARTITION BY row, ngroup ORDER BY row, ngroup, loc) AS INT) AS number

	FROM
		number_groups

	ORDER BY row, loc
),
number_location AS (
	SELECT DISTINCT
		row,
		loc_start,
		loc_end,
		MAX(number) OVER (PARTITION BY row, loc_start, loc_end) AS number

	FROM
		number_candidates

	ORDER BY row, loc_start
),
symbols AS (
	SELECT
		row,
		unnest(schematics) AS symbol,
		generate_subscripts(schematics, 1) AS loc
	FROM
		import
),
symbol_location AS (
	SELECT DISTINCT
		row AS row,
		loc,
		symbol
	FROM 
		symbols
	WHERE 
		symbols.symbol NOT IN ('.', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
),
list AS (
	SELECT
		number_location.number
	FROM number_location
	JOIN symbol_location 
		ON symbol_location.row = number_location.row
		AND
		symbol_location.loc BETWEEN number_location.loc_start - 1 AND number_location.loc_end + 1

	UNION ALL

	SELECT 
		number_location.number
	FROM number_location
	JOIN symbol_location 
		ON symbol_location.row = number_location.row + 1
		AND
		symbol_location.loc BETWEEN number_location.loc_start - 1 AND number_location.loc_end + 1

	UNION ALL

	SELECT 
		number_location.number
	FROM number_location
	JOIN symbol_location 
		ON symbol_location.row = number_location.row - 1
		AND
		symbol_location.loc BETWEEN number_location.loc_start - 1 AND number_location.loc_end + 1
)
SELECT
	SUM(number) AS solution_part1
FROM list;

-- Part 2
WITH
import AS (
	SELECT 
		ROW_NUMBER() OVER () AS row,
		regexp_extract_all(schematics, '(.)', 1) AS schematics,
	FROM read_csv('day3/input', columns = {'schematics': 'VARCHAR'})
),
numbers AS (
	SELECT
		row,
		unnest(schematics) as number,
		generate_subscripts(schematics, 1) AS loc
	FROM
		import
),
number_filter AS (
	SELECT
		row,
		loc,
		lag(loc, 1, 1) OVER(PARTITION BY row ORDER BY row, loc) AS lag,
		number
	FROM 
		numbers

	WHERE
		number IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')

	ORDER BY row, loc
),
number_group AS (
	SELECT
		row,
		loc,
		CASE WHEN loc =  lag + 1 THEN 0 ELSE 1 END AS group_bump,
		number
		
	FROM 
		number_filter

	ORDER BY row, loc
),
number_groups AS (
	SELECT
		row,
		CAST(loc AS INT) AS loc,
		SUM(group_bump) OVER (ORDER BY row, loc) AS ngroup,
		number
		
	FROM 
		number_group

	ORDER BY row, loc
),
number_candidates AS (
	SELECT
		row,
		min(loc) OVER (PARTITION BY row, ngroup) AS loc_start,
		max(loc) OVER (PARTITION BY row, ngroup) AS loc_end,
		CAST(string_agg(number, '') OVER (PARTITION BY row, ngroup ORDER BY row, ngroup, loc) AS INT) AS number

	FROM
		number_groups

	ORDER BY row, loc
),
number_location AS (
	SELECT DISTINCT
		row,
		loc_start,
		loc_end,
		MAX(number) OVER (PARTITION BY row, loc_start, loc_end) AS number

	FROM
		number_candidates

	ORDER BY row, loc_start
),
symbols AS (
	SELECT
		row,
		unnest(schematics) AS symbol,
		generate_subscripts(schematics, 1) AS loc
	FROM
		import
),
symbol_location AS (
	SELECT DISTINCT
		row AS row,
		loc,
		symbol
	FROM 
		symbols
	WHERE 
		symbols.symbol NOT IN ('.', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
),
list AS (
	SELECT
		symbol,
		symbol_location.row,
		symbol_location.loc,
		number_location.number
	FROM number_location
	JOIN symbol_location 
		ON symbol_location.row = number_location.row
		AND
		symbol_location.loc BETWEEN number_location.loc_start - 1 AND number_location.loc_end + 1
		AND
		symbol_location.symbol = '*'

	UNION

	SELECT 
		symbol,
		symbol_location.row,
		symbol_location.loc,
		number_location.number
	FROM number_location
	JOIN symbol_location 
		ON symbol_location.row = number_location.row + 1
		AND
		symbol_location.loc BETWEEN number_location.loc_start - 1 AND number_location.loc_end + 1
		AND
		symbol_location.symbol = '*'

	UNION

	SELECT 
		symbol,
		symbol_location.row,
		symbol_location.loc,
		number_location.number
	FROM number_location
	JOIN symbol_location 
		ON symbol_location.row = number_location.row - 1
		AND
		symbol_location.loc BETWEEN number_location.loc_start - 1 AND number_location.loc_end + 1
		AND
		symbol_location.symbol = '*'
),
possible_gears AS MATERIALIZED (
	SELECT 
		symbol,
		row,
		loc,
		number,
		ROW_NUMBER() OVER (PARTITION BY symbol, row, loc ORDER BY symbol, row, loc) AS num
	FROM list
	ORDER BY symbol, row, loc
),
gear_ratios AS (
SELECT 
	possible_gears.symbol,
	possible_gears.row,
	possible_gears.loc,
	possible_gears.number AS gear1,
	possible_gears2.number AS gear2,
	IFNULL(possible_gears.number, 0) * IFNULL(possible_gears2.number, 0) AS ratio

	FROM possible_gears
	JOIN possible_gears AS possible_gears2 
	ON 
		possible_gears.row = possible_gears2.row
		AND 
		possible_gears.loc = possible_gears2.loc
		AND
		possible_gears.num = 1 AND possible_gears2.num = 2
)
-- 89211325 too high
-- 82660900 too high
-- 75312571

SELECT SUM(ratio) AS solution_part2 FROM gear_ratios
