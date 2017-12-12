create database if not exists airlines;
use airlines;

create external table if not exists airlines
LIKE PARQUET 's3a://gregoryg/datasets/airlines/airlines/4345e5eef217aa1b-c8f16177f35fd988_1432111844_data.0.parq'
STORED AS PARQUET
LOCATION 's3a://gregoryg/datasets/airlines/airlines/';

create external table if not exists airports_raw
(iata string,
airport string,
city string,
state string,
country string,
latitude float,
longitude float)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3a://gregoryg/datasets/airlines/airports';

create table if not exists airports
stored as parquet
AS
select regexp_replace(iata, '"','') AS iata,
regexp_replace(airport, '"','') AS airport,
regexp_replace(city, '"','') AS city,
regexp_replace(state, '"','') AS state,
regexp_replace(country, '"','') AS country,
latitude,
longitude
from airports_raw
where iata <> '"iata"'

create table if not exists default.airlines
STORED AS PARQUET
AS select * FROM airlines.airlines;

create table if not exists default.airports
STORED AS PARQUET
AS select * FROM airlines.airports;
