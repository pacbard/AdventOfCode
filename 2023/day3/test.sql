.maxrows -1

WITH
import AS (
	SELECT 
		ROW_NUMBER() OVER () AS row,
		schematics,
		CONCAT('.', regexp_replace(schematics, '([^0-9\.])', '.', 'g'), '.') as schematics_location
	FROM read_csv('day3/test', columns = {'schematics': 'VARCHAR'})
),
numbers AS (
	SELECT
		row,
		regexp_extract_all(schematics, '([0-9]+)', 1) AS numbers
	FROM
		import
),
number AS (
	SELECT
		numbers.row,
		unnest(numbers) as number
	FROM 
		numbers
),
number_location AS (
	SELECT
		number.row AS row,
		CAST(number AS INT) AS number,
		instr(schematics_location, CONCAT('.', number, '.')) - 1 AS loc_start,
		instr(schematics_location, CONCAT('.', number, '.')) + strlen(number) + 1 AS loc_end
	FROM 
		number
	JOIN
		import ON import.row = number.row
),
symbols AS (
	SELECT
		row,
		regexp_extract_all(schematics, '(.)', 1) AS symbols
	FROM
		import
),
symbol_row AS (
	SELECT
		symbols.row,
		unnest(symbols) as symbol
	FROM 
		symbols
),
symbol AS (
	SELECT
		*,
		ROW_NUMBER() OVER () AS loc
	FROM
		symbol_row
),
symbol_location AS (
	SELECT DISTINCT
		symbol.row AS row,
		(symbol.loc % 10) AS loc,
		symbol.symbol AS symbol
	FROM 
		symbol
	WHERE 
		symbol.symbol NOT IN ('.', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
),
list AS (
	SELECT
		number_location.row,
		number_location.loc_start,
		number_location.loc_end,
		number_location.number
	FROM number_location
	JOIN symbol_location 
		ON symbol_location.row = number_location.row
		AND
		symbol_location.loc BETWEEN number_location.loc_start AND number_location.loc_end

	UNION

	SELECT 
		number_location.row,
		number_location.loc_start,
		number_location.loc_end,
		number_location.number
	FROM number_location
	JOIN symbol_location 
		ON symbol_location.row = number_location.row + 1
		AND
		symbol_location.loc BETWEEN number_location.loc_start AND number_location.loc_end

	UNION

	SELECT 
		number_location.row,
		number_location.loc_start,
		number_location.loc_end,
		number_location.number
	FROM number_location
	JOIN symbol_location 
		ON symbol_location.row = number_location.row - 1
		AND
		symbol_location.loc BETWEEN number_location.loc_start AND number_location.loc_end
)

SELECT
	SUM(number) AS solution_part1
FROM list
;
