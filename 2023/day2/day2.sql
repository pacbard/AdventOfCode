WITH
import AS (
	SELECT 
		CAST(regexp_extract(game, '[0-9]+$') AS int) AS game,
		string_split_regex(trim(bags), '; ') AS bags

	FROM read_csv('day2/input', delim = ':', header=false, columns = {'game': 'VARCHAR', 'bags': 'VARCHAR'})
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
		CASE WHEN regexp_extract(bag, '([0-9]+) red', 1) = '' THEN 0 ELSE regexp_extract(bag, '([0-9]+) red', 1) END AS red,
		CASE WHEN regexp_extract(bag, '([0-9]+) green', 1) = '' THEN 0 ELSE regexp_extract(bag, '([0-9]+) green', 1) END AS green,
		CASE WHEN regexp_extract(bag, '([0-9]+) blue', 1) = '' THEN 0 ELSE regexp_extract(bag, '([0-9]+) blue', 1) END AS blue
	FROM long_data
),
games as (
	SELECT DISTINCT
		game as game
	FROM data
	WHERE 
		-- 12 red cubes, 13 green cubes, and 14 blue cubes
		game NOT IN (SELECT game FROM data WHERE red > 12)
		AND
		game NOT IN (SELECT game FROM data WHERE green > 13)
		AND
		game NOT IN (SELECT game FROM data WHERE blue > 14)
)
SELECT sum(game) AS solution_part1 FROM games;

WITH
import AS (
	SELECT 
		CAST(regexp_extract(game, '[0-9]+$') AS int) AS game,
		string_split_regex(trim(bags), '; ') AS bags

	FROM read_csv('day2/input', delim = ':', header=false, columns = {'game': 'VARCHAR', 'bags': 'VARCHAR'})
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
		CAST(CASE WHEN regexp_extract(bag, '([0-9]+) red', 1) = '' THEN 0 ELSE regexp_extract(bag, '([0-9]+) red', 1) END AS INT) AS red,
		CAST(CASE WHEN regexp_extract(bag, '([0-9]+) green', 1) = '' THEN 0 ELSE regexp_extract(bag, '([0-9]+) green', 1) END AS INT) AS green,
		CAST(CASE WHEN regexp_extract(bag, '([0-9]+) blue', 1) = '' THEN 0 ELSE regexp_extract(bag, '([0-9]+) blue', 1) END AS INT) AS blue
	FROM long_data
),
power AS (
	SELECT 
		game,
		MAX(red) AS power_red,
		MAX(green) AS power_green,
		MAX(blue) AS power_blue
	FROM data
	GROUP BY game
)
SELECT SUM(power_red * power_green * power_blue) AS solution_part2 FROM power;
