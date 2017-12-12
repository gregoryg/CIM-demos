CREATE DATABASE IF NOT EXISTS nyctaxi;
USE nyctaxi;

CREATE EXTERNAL TABLE IF NOT EXISTS green_tripdata_pre2015_staging (
  vendor_id STRING,
  lpep_pickup_datetime TIMESTAMP,
  lpep_dropoff_datetime TIMESTAMP,
  store_and_fwd_flag STRING,
  rate_code_id INT,
  pickup_longitude DOUBLE,
  pickup_latitude DOUBLE,
  dropoff_longitude DOUBLE,
  dropoff_latitude DOUBLE,
  passenger_count INT,
  trip_distance DOUBLE,
  fare_amount DOUBLE,
  extra DOUBLE,
  mta_tax DOUBLE,
  tip_amount DOUBLE,
  tolls_amount DOUBLE,
  ehail_fee STRING,
  total_amount DOUBLE,
  payment_type INT,
  trip_type INT,
  junk1 STRING,
  junk2 STRING
)
  ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
  STORED AS TEXTFILE
  LOCATION 's3a://gregoryg/datasets/nyc-taxi/green_pre2015';

  CREATE EXTERNAL TABLE IF NOT EXISTS green_tripdata_staging (
  vendor_id STRING,
  lpep_pickup_datetime STRING,
  lpep_dropoff_datetime STRING,
  store_and_fwd_flag STRING,
  rate_code_id STRING,
  pickup_longitude DOUBLE,
  pickup_latitude DOUBLE,
  dropoff_longitude DOUBLE,
  dropoff_latitude DOUBLE,
  passenger_count STRING,
  trip_distance STRING,
  fare_amount STRING,
  extra STRING,
  mta_tax STRING,
  tip_amount STRING,
  tolls_amount STRING,
  ehail_fee STRING,
  improvement_surcharge DOUBLE,
  total_amount STRING,
  payment_type STRING,
  trip_type STRING,
  junk1 STRING,
  junk2 STRING
)
  ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
  STORED AS TEXTFILE
  LOCATION 's3a://gregoryg/datasets/nyc-taxi/green_2015';

-- N.B. junk columns are there because green_tripdata file headers are
-- inconsistent with the actual data, e.g. header says 20 or 21 columns per row,
-- but data actually has 22 or 23 columns per row, which COPY doesn't like.
-- junk1 and junk2 should always be null


CREATE EXTERNAL TABLE IF NOT EXISTS yellow_tripdata_2015_staging (
  vendor_id STRING,
  tpep_pickup_datetime TIMESTAMP,
  tpep_dropoff_datetime TIMESTAMP,
  passenger_count INT,
  trip_distance DOUBLE,
  pickup_longitude DOUBLE,
  pickup_latitude DOUBLE,
  rate_code_id INT,
  store_and_fwd_flag STRING,
  dropoff_longitude DOUBLE,
  dropoff_latitude DOUBLE,
  payment_type STRING,
  fare_amount DOUBLE,
  extra DOUBLE,
  mta_tax DOUBLE,
  tip_amount DOUBLE,
  tolls_amount DOUBLE,
  improvement_surcharge DOUBLE,
  total_amount DOUBLE
  )
  ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
  STORED AS TEXTFILE
  LOCATION 's3a://gregoryg/datasets/nyc-taxi/yellow_2015/';

CREATE EXTERNAL TABLE IF NOT EXISTS yellow_tripdata_pre2015_staging (
  vendor_id STRING,
  tpep_pickup_datetime TIMESTAMP,
  tpep_dropoff_datetime TIMESTAMP,
  passenger_count INT,
  trip_distance DOUBLE,
  pickup_longitude DOUBLE,
  pickup_latitude DOUBLE,
  rate_code_id INT,
  store_and_fwd_flag STRING,
  dropoff_longitude DOUBLE,
  dropoff_latitude DOUBLE,
  payment_type STRING,
  fare_amount DOUBLE,
  extra DOUBLE,
  mta_tax DOUBLE,
  tip_amount DOUBLE,
  tolls_amount DOUBLE,
  total_amount DOUBLE
  )
  ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
  STORED AS TEXTFILE
  LOCATION 's3a://gregoryg/datasets/nyc-taxi/yellow_pre2015/';

CREATE EXTERNAL TABLE IF NOT EXISTS uber_trips_staging (
  pickup_datetime timestamp,
  pickup_latitude DOUBLE,
  pickup_longitude DOUBLE,
  base_code STRING
  )
  ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
  STORED AS TEXTFILE
  LOCATION 's3a://gregoryg/utility/cdata/ds2/raw/MeterData';

-- CREATE TABLE uber_trips_2015 (
--   dispatching_base_num STRING,
--   pickup_datetime timestamp,
--   affiliated_base_num STRING,
--   location_id INT,
--   nyct2010_ntacode STRING
-- );

-- CREATE TABLE taxi_zone_lookups (
--   location_id integer primary key,
--   borough STRING,
--   zone STRING,
--   service_zone STRING,
--   nyct2010_ntacode STRING
-- );

-- CREATE TABLE fhv_trips (
--   id serial primary key,
--   dispatching_base_num STRING,
--   pickup_datetime timestamp without time zone,
--   location_id INT
-- );

-- CREATE TABLE fhv_bases (
--   base_number STRING primary key,
--   base_name STRING,
--   dba STRING,
--   dba_category STRING
-- );

-- CREATE INDEX index_fhv_bases_on_dba_category ON fhv_bases (dba_category);

-- CREATE TABLE cab_types (
--   id serial primary key,
--   type STRING
-- );

-- INSERT INTO cab_types (type) SELECT 'yellow';
-- INSERT INTO cab_types (type) SELECT 'green';
-- INSERT INTO cab_types (type) SELECT 'uber';

----- GJG Clean up data, put in optimized format
-- set hive.execution.engine=spark;
create table trips STORED AS PARQUET as
SELECT 'yellow' AS taxi_type,
vendor_id, 
tpep_pickup_datetime AS pickup_datetime,
tpep_dropoff_datetime AS dropoff_datetime,
passenger_count,
trip_distance,
pickup_latitude,
pickup_longitude,
rate_code_id,
store_and_fwd_flag,
dropoff_latitude,
dropoff_longitude,
payment_type,
CAST(fare_amount AS DECIMAL(8,2)) AS fare_amount,
CAST(extra AS DECIMAL(8,2)) AS extra,
CAST(mta_tax AS DECIMAL(8,2)) AS mta_tax,
CAST(tip_amount AS DECIMAL(8,2)) AS tip_amount,
CAST(tolls_amount AS DECIMAL(8,2)) AS tolls_amount,
CAST(improvement_surcharge AS DECIMAL(8,2)) AS improvement_surcharge,
CAST(total_amount AS DECIMAL(8,2)) AS total_amount,
regexp_extract(INPUT__FILE__NAME, '.+/(.+)$', 1) AS source_file
from yellow_tripdata_2015_staging;

-- set hive.execution.engine=spark;
insert INTO TABLE trips
SELECT 'yellow' AS taxi_type,
vendor_id, 
tpep_pickup_datetime AS pickup_datetime,
tpep_dropoff_datetime AS dropoff_datetime,
passenger_count,
trip_distance,
pickup_latitude,
pickup_longitude,
rate_code_id,
store_and_fwd_flag,
dropoff_latitude,
dropoff_longitude,
payment_type,
CAST(fare_amount AS DECIMAL(8,2)) AS fare_amount,
CAST(extra AS DECIMAL(8,2)) AS extra,
CAST(mta_tax AS DECIMAL(8,2)) AS mta_tax,
CAST(tip_amount AS DECIMAL(8,2)) AS tip_amount,
CAST(tolls_amount AS DECIMAL(8,2)) AS tolls_amount,
NULL AS improvement_surcharge,
CAST(total_amount AS DECIMAL(8,2)) AS total_amount,
regexp_extract(INPUT__FILE__NAME, '.+/(.+)$', 1) AS source_file
from yellow_tripdata_pre2015_staging;

insert INTO TABLE trips
SELECT 'green' AS taxi_type,
vendor_id, 
CAST(lpep_pickup_datetime AS TIMESTAMP) AS pickup_datetime,
CAST(lpep_dropoff_datetime AS TIMESTAMP) AS dropoff_datetime,
passenger_count,
trip_distance,
pickup_latitude,
pickup_longitude,
rate_code_id,
store_and_fwd_flag,
dropoff_latitude,
dropoff_longitude,
payment_type,
CAST(fare_amount AS DECIMAL(8,2)) AS fare_amount,
CAST(extra AS DECIMAL(8,2)) AS extra,
CAST(mta_tax AS DECIMAL(8,2)) AS mta_tax,
CAST(tip_amount AS DECIMAL(8,2)) AS tip_amount,
CAST(tolls_amount AS DECIMAL(8,2)) AS tolls_amount,
CAST(improvement_surcharge AS DECIMAL(8,2)) AS improvement_surcharge,
CAST(total_amount AS DECIMAL(8,2)) AS total_amount,
regexp_extract(INPUT__FILE__NAME, '.+/(.+)$', 1) AS source_file
from green_tripdata_staging;

insert INTO TABLE trips
SELECT 'green' AS taxi_type,
vendor_id, 
CAST(lpep_pickup_datetime AS TIMESTAMP) AS pickup_datetime,
CAST(lpep_dropoff_datetime AS TIMESTAMP) AS dropoff_datetime,
passenger_count,
trip_distance,
pickup_latitude,
pickup_longitude,
rate_code_id,
store_and_fwd_flag,
dropoff_latitude,
dropoff_longitude,
payment_type,
CAST(fare_amount AS DECIMAL(8,2)) AS fare_amount,
CAST(extra AS DECIMAL(8,2)) AS extra,
CAST(mta_tax AS DECIMAL(8,2)) AS mta_tax,
CAST(tip_amount AS DECIMAL(8,2)) AS tip_amount,
CAST(tolls_amount AS DECIMAL(8,2)) AS tolls_amount,
NULL AS improvement_surcharge,
CAST(total_amount AS DECIMAL(8,2)) AS total_amount,
regexp_extract(INPUT__FILE__NAME, '.+/(.+)$', 1) AS source_file
from green_tripdata_pre2015_staging;

CREATE EXTERNAL TABLE IF NOT EXISTS central_park_weather_observations_raw (
  station_id STRING,
  station_name STRING,
  weather_date STRING,
  precipitation double,
  snow_depth double,
  snowfall double,
  max_temperature double,
  min_temperature double,
  average_wind_speed double
  )
  ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
  LOCATION 's3a://gregoryg/datasets/nyc-taxi/central_park_weather';

CREATE TABLE IF NOT EXISTS central_park_weather_observations STORED AS PARQUET AS
   SELECT station_id, station_name, CAST(CONCAT(substring(weather_date, 1, 4), '-', substring(weather_date, 5, 2), '-', substring(weather_date, 7, 2)) AS TIMESTAMP) AS weather_date, snow_depth, snowfall, max_temperature, min_temperature, average_wind_speed FROM central_park_weather_observations_raw WHERE station_id <> 'STATION';




----  GJG 

-- CREATE TABLE trips (
--   id serial primary key,
--   cab_type_id INT,
--   vendor_id STRING,
--   pickup_datetime timestamp without time zone,
--   dropoff_datetime timestamp without time zone,
--   store_and_fwd_flag char(1),
--   rate_code_id INT,
--   pickup_longitude DOUBLE,
--   pickup_latitude DOUBLE,
--   dropoff_longitude DOUBLE,
--   dropoff_latitude DOUBLE,
--   passenger_count INT,
--   trip_distance numeric,
--   fare_amount numeric,
--   extra numeric,
--   mta_tax numeric,
--   tip_amount numeric,
--   tolls_amount numeric,
--   ehail_fee numeric,
--   improvement_surcharge numeric,
--   total_amount numeric,
--   payment_type STRING,
--   trip_type INT,
--   pickup_nyct2010_gid INT,
--   dropoff_nyct2010_gid INT
-- );

-- SELECT AddGeometryColumn('trips', 'pickup', 4326, 'POINT', 2);
-- SELECT AddGeometryColumn('trips', 'dropoff', 4326, 'POINT', 2);

-- CREATE TABLE central_park_weather_observations (
--   station_id STRING,
--   station_name STRING,
--   date date,
--   precipitation numeric,
--   snow_depth numeric,
--   snowfall numeric,
--   max_temperature numeric,
--   min_temperature numeric,
--   average_wind_speed numeric
-- );

-- CREATE UNIQUE INDEX index_weather_observations ON central_park_weather_observations (date);
