CREATE TABLE import AS 
    SELECT 
        CAST(regexp_extract(game, '[0-9]+$') AS int) AS game,
        trim(cards) AS numbers

    FROM read_csv('day4/test', delim = ':', header=false, columns = {'game': 'VARCHAR', 'cards': 'VARCHAR'})
;
CREATE TABLE card_numbers AS
    SELECT
        game,
        unnest(regexp_extract_all(split_part(trim(numbers), '|', 1), '([0-9]+)', 1)) AS card_number,
    FROM
        import
;
CREATE TABLE winning_numbers AS
    SELECT
        game,
        split_part(trim(numbers), '|', 2) AS winning_numbers
    FROM
        import
;
CREATE TABLE check_card AS
    SELECT 
        card_numbers.game,
        card_number,
        1 AS winning
    FROM card_numbers
    JOIN winning_numbers
        ON winning_numbers.game = card_numbers.game
    WHERE 
        instr(winning_numbers, card_number) > 0
;
CREATE TABLE points AS
    SELECT
        game,
        2 ^ (SUM(winning) - 1) AS points
    FROM
        check_card
    GROUP BY
        game
;

SELECT
    CAST(sum(points) AS INT) AS answer_part1
FROM
    points
;

--Part 2
CREATE TABLE winning_numbers2 AS
    SELECT
        game,
        split_part(trim(numbers), '|', 2) AS winning_numbers
    FROM
        import
;
CREATE TABLE cards AS (
    SELECT
        card_numbers.game,
        card_number,
        winning_numbers2
    FROM card_numbers
    JOIN winning_numbers2
        ON card_numbers.game = winning_numbers2.game
);
CREATE TABLE check_card2 AS
    SELECT 
        card_numbers.game,
        card_number,
        1 AS winning
    FROM card_numbers
    WHERE 
        card_number IN (SELECT struct_extract(card_numbers.winning_numbers2, 'winning_numbers') FROM card_numbers)
;
SELECT * FROM cards;