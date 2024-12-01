create or replace table input as from read_csv('input.txt', header=false, delim=' ');

-- Part 1
select sum(abs(column3 - column0)) as part_1 
    from (select row_number() over (order by column0) as sorted, column0 from input) as "left" 
    join (select row_number() over (order by column3) as sorted, column3 from input) as "right" on "right".sorted = "left".sorted;

-- Part 2
select sum(column0 * N_times) as part_2 
    from (select row_number() over (order by column0) as sorted, column0 from input) as "left" 
    join (select column3, count(column3) as N_times from "right" group by column3) as "right_count" on right_count.column3 = "left".column0;