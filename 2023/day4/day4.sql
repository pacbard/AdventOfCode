.maxrows -1

WITH
import AS MATERIALIZED (
    SELECT 
        CAST(regexp_extract(game, '[0-9]+$') AS int) AS game,
        trim(cards) AS numbers

    FROM read_csv('day4/input', delim = ':', header=false, columns = {'game': 'VARCHAR', 'cards': 'VARCHAR'})
),
card_numbers AS (
    SELECT
        game,
        unnest(regexp_extract_all(split_part(trim(numbers), '|', 1), '([0-9]+)', 1)) AS card_number,
    FROM
        import
),
winning_numbers AS (
    SELECT
        game,
        unnest(regexp_extract_all(split_part(trim(numbers), '|', 2), '([0-9]+)', 1)) AS winning_numbers
    FROM
        import
),
check_card AS (
    SELECT 
        game,
        card_number,
        1 AS winning
    FROM card_numbers
    WHERE 
        card_number IN (SELECT winning_numbers FROM winning_numbers WHERE card_numbers.game = winning_numbers.game)
),
points AS (
    SELECT
        game,
        2 ^ (SUM(winning) - 1) AS points
    FROM
        check_card
    GROUP BY
        game
)

-- 27454

SELECT
    CAST(sum(points) AS INT) AS answer_part1
FROM
    points

--Part 2