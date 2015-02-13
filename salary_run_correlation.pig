-- Load data from Batting.csv, assign field names and group runs by year
batting = load 'Batting.csv' using PigStorage(',');
runs = FOREACH batting GENERATE $0 as playerID, $1 as year, $8 as runs;
group_runs = GROUP runs BY (year);
-- Load data from Salaries.csv, assign field names and group salaries by team
salaries = load 'Salaries.csv' using PigStorage(',');
cash_given = FOREACH salaries GENERATE $0 as year, $3 as playerID, $4 as salary;
group_salaries = GROUP cash_given BY (year);
-- Group to find maximum runs by a player for a year, re-assign field names
max_runs_by_year = FOREACH group_runs GENERATE group as grp1, MAX(runs.runs) as max_runs;
join_run = JOIN max_runs_by_year by ($0, max_runs), runs by (year, runs);
runs_max_player = FOREACH join_run GENERATE $0 as year, $1 as runs, $2 as playerID;
-- Group to find maximum earning player by year, re-assign field names
max_salary_by_year = FOREACH group_salaries GENERATE group as grp2, MAX(cash_given.salary) as max_salary;
join_salary = JOIN max_salary_by_year by ($0, max_salary), cash_given by (year, salary);
salary_max_player = FOREACH join_salary GENERATE $0 as year, $1 as salary, $2 as playerID;
-- Group salary and runs values together, using playerID and year
runs_and_salaries = JOIN runs_max_player by (year, playerID), salary_max_player by (year, playerID);
-- Re-assign field names
final_data = FOREACH runs_and_salaries GENERATE $0 as year, $1 as playerID, $2 as runs, $3 as salary;
-- Display the output
dump final_data;
