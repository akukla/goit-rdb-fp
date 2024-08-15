-- 1 initialize
create schema pandemic;
use pandemic;


-- Do manual import before continue


-- 2.1: Create a temporary table to store unique combinations of Entity and Code
create temporary table temp_entities as
select distinct Entity, Code
from infectious_cases;

-- 2.2: Create the entities table
create table entities (
    id int auto_increment primary key,
    Entity varchar(255),
    Code varchar(255),
    unique (Entity, Code)
);

-- 2.3: Insert unique values from the temporary table into the entities table
insert into entities (Entity, Code)
select Entity, Code
from temp_entities;

drop table temp_entities;

-- 2.4: Create the infectious_cases_normalized table
create table cases
(
    id int auto_increment primary key,
    entity_id int,
    Year                 int    null,
    Number_yaws          bigint null,
    polio_cases          double null,
    cases_guinea_worm    double null,
    Number_rabies        double null,
    Number_malaria       double null,
    Number_hiv           double null,
    Number_tuberculosis  double null,
    Number_smallpox      bigint null,
    Number_cholera_cases bigint null,
    foreign key (entity_id) references entities(id)
);

-- 2.5: Insert data into infectious_cases_normalized
insert into cases (entity_id, Year, Number_yaws, polio_cases, cases_guinea_worm, Number_rabies, Number_malaria, Number_hiv, Number_tuberculosis, Number_smallpox, Number_cholera_cases)
select e.id, ic.Year, ic.Number_yaws, ic.polio_cases, ic.cases_guinea_worm, ic.Number_rabies, ic.Number_malaria, ic.Number_hiv, ic.Number_tuberculosis, ic.Number_smallpox, ic.Number_cholera_cases
from infectious_cases as ic
join entities e on ic.Entity = e.Entity and ic.Code = e.Code;



-- 3
select
    e.Entity,
    e.Code,
    avg(c.Number_rabies) as avg_rabies,
    min(c.Number_rabies) as min_rabies,
    max(c.Number_rabies) as max_rabies,
    sum(c.Number_rabies) as sum_rabies
from
    entities e
inner join
    cases c on e.id = c.entity_id
where
    c.Number_rabies != ''
group by
    e.Entity, e.Code
order by
    avg_rabies desc
limit 10;



-- 4
select
    Year,
    concat(Year, '-01-01') as start_of_year,
    current_date() as `current_date`,
    timestampdiff(year, concat(Year, '-01-01'), current_date()) as year_difference
from
    cases;

-- 5
delimiter //
create function if not exists year_difference(input_year int)
returns int
    deterministic
begin
    declare start_of_year date;
    declare year_diff int;

    -- Create the date for January 1st of the input year
    set start_of_year = str_to_date(concat(input_year, '-01-01'), '%Y-%m-%d');

    -- Calculate the difference in years
    set year_diff = timestampdiff(year, start_of_year, current_date());

    return year_diff;
end;
//
delimiter ;

-- Use the function in a query
select
    Year,
    year_difference(Year) as year_difference
from
    cases;