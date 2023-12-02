WITH
import AS (
	SELECT 
		regexp_extract(game, '[0-9]+$') AS game,
		string_split_regex(trim(bags), '; ') AS bags

	FROM read_csv('day2/day2.txt', delim = ':', header=false, columns = {'game': 'VARCHAR', 'bags': 'VARCHAR'})
),
long_data AS (
	SELECT 
		game,
		unnest(bags) as bag
	FROM import

),
data AS (
	SELECT
		game,
		regexp_extract(bag, '([0-9]+) red', 1) AS red,
		regexp_extract(bag, '([0-9]+) green', 1) AS green,
		regexp_extract(bag, '([0-9]+) blue', 1) AS blue
	FROM long_data
),
games as (
	SELECT DISTINCT
		CAST(game AS INT) as game
	FROM data
	WHERE 
		-- 12 red cubes, 13 green cubes, and 14 blue cubes
		game NOT IN (SELECT game FROM data WHERE CASE WHEN red = '' THEN 0 ELSE red END > 12)
		AND
		game NOT IN (SELECT game FROM data WHERE CASE WHEN green = '' THEN 0 ELSE green END > 13)
		AND
		game NOT IN (SELECT game FROM data WHERE CASE WHEN blue = '' THEN 0 ELSE blue END > 14)
)
SELECT sum(game) AS solution FROM games
;
