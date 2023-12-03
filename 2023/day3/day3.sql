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
		unnest(schematics) as number
	FROM
		import
),
number_row AS (
	SELECT
		numbers.row AS row,
		ROW_NUMBER() OVER (PARTITION BY row) AS loc,
		regexp_replace(number, '[^0-9]', '.') AS number
	FROM 
		numbers
),
number_filter AS (
	SELECT
		row,
		loc,
		lag(loc, 1, 1) OVER(PARTITION BY row) AS lag,
		number
	FROM 
		number_row

	WHERE
		number IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
),
number_group AS (
	SELECT
		row,
		loc,
		CASE WHEN loc =  lag + 1 THEN 0 ELSE 1 END AS group_bump,
		number
		
	FROM 
		number_filter
),
number_groups AS (
	SELECT
		row,
		CAST(loc AS INT) AS loc,
		SUM(group_bump) OVER (ORDER BY row, loc) AS ngroup,
		number
		
	FROM 
		number_group
),
number_location AS (
	SELECT DISTINCT
		row,
		CAST(min(loc) AS INT) AS loc_start,
		CAST(max(loc) AS INT) AS loc_end,
		CAST(string_agg(number, '') AS INT) AS number

	FROM
		number_groups

	GROUP BY
		row, ngroup
),
symbols AS (
	SELECT
		row,
		unnest(schematics) as symbol
	FROM
		import
),
symbol AS (
	SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY row) AS loc
	FROM
		symbols
),
symbol_location AS (
	SELECT DISTINCT
		symbol.row AS row,
		loc,
		symbol.symbol AS symbol
	FROM 
		symbol
	WHERE 
		symbol.symbol NOT IN ('.', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
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
--535078

-- SELECT * FROM list ORDER BY row, loc_start

SELECT
	SUM(number) AS solution_part1
FROM list
;
