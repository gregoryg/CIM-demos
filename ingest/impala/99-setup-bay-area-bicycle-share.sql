-- [[file:~/projects/cloudera-demos/CIM-demos/README.org::*BABS%20-%20Bay%20Area%20Bike%20Share%20dataset][BABS - Bay Area Bike Share dataset:2]]
-- can be run as Impala
-- Bay Area Bicycle Share (BABS) dataset
  CREATE DATABASE IF NOT EXISTS bikeshare;
  USE bikeshare;

  CREATE EXTERNAL TABLE bikeshare.station_raw (
     station_id BIGINT,
     name STRING,
     lat DOUBLE,
     long DOUBLE,
     dockcount BIGINT,
     landmark STRING,
     installation STRING )
     ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
     STORED AS TEXTFILE LOCATION 's3a://gregoryg/babs/station'
     TBLPROPERTIES ('numRows'='-1', 'rawDataSize'='-1', 'skip.header.line.count'='1' );

  CREATE EXTERNAL TABLE IF NOT EXISTS bikeshare.rebalancing_raw (
     station_id BIGINT,
     bikes_available BIGINT,
     docks_available BIGINT,
     time_recorded STRING ) 
  ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
  STORED AS TEXTFILE
  LOCATION 's3a://gregoryg/babs/rebalancing'
  TBLPROPERTIES ('numRows'='-1', 'rawDataSize'='-1', 'skip.header.line.count'='1');

  CREATE EXTERNAL TABLE bikeshare.trip_raw (
     trip_id BIGINT,
     duration BIGINT,
     date_start STRING,
     start_station STRING,
     start_terminal BIGINT,
     date_end STRING,
     end_station STRING,
     end_terminal BIGINT,
     bike_num BIGINT,
     subscription_type STRING,
     zip STRING )
     ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
     STORED AS TEXTFILE
     LOCATION 's3a://gregoryg/babs/trip'
     TBLPROPERTIES ('numRows'='-1', 'rawDataSize'='-1', 'skip.header.line.count'='1');

  CREATE EXTERNAL TABLE bikeshare.weather_raw (
     `date` STRING,
     max_temperature_f BIGINT,
     mean_temperature_f BIGINT,
     min_temperaturef BIGINT,
     max_dew_point_f BIGINT,
     meandew_point_f BIGINT,
     min_dewpoint_f BIGINT,
     max_humidity BIGINT,
     mean_humidity BIGINT,
     min_humidity BIGINT,
     max_sea_level_pressure_in DOUBLE,
     mean_sea_level_pressure_in DOUBLE,
     min_sea_level_pressure_in DOUBLE,
     max_visibility_miles BIGINT,
     mean_visibility_miles BIGINT,
     min_visibility_miles BIGINT,
     max_wind_speed_mph BIGINT,
     mean_wind_speed_mph BIGINT,
     max_gust_speed_mph BIGINT,
     precipitation_in BIGINT,
     cloud_cover BIGINT,
     events STRING,
     wind_dir_degrees BIGINT,
     zip STRING )
     ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
     STORED AS TEXTFILE LOCATION 's3a://gregoryg/babs/weather'
     TBLPROPERTIES ('numRows'='-1', 'rawDataSize'='-1', 'skip.header.line.count'='1');

  -- Create optimized tables
  create table IF NOT EXISTS bikeshare.rebalancing
  STORED AS parquet
  AS select
      CAST(station_id AS int) AS station_id,
      CAST(bikes_available AS int) AS bikes_available,
      CAST(docks_available AS int) AS docks_available,
      CAST(time_recorded AS timestamp) AS time_recorded,
      time_recorded AS original_timestring
  FROM bikeshare.rebalancing_raw;

  create table IF NOT EXISTS bikeshare.trip
  STORED AS parquet
  AS SELECT
     CAST(trip_id AS INT) AS trip_id,
     CAST(duration AS INT) AS duration,
     CAST( concat(split_part(split_part(date_start, '/', 3), ' ' , 1), '-',
       lpad(split_part(date_start, '/', 1), 2, '0'), '-',
       lpad(split_part(date_start, '/', 2), 2, '0'), ' ',
       lpad(split_part(date_start, ' ', 2), 5, '0'), ':00') AS timestamp) AS date_start,
     start_station,
     CAST(start_terminal AS INT) AS start_terminal,
     CAST( concat(split_part(split_part(date_end, '/', 3), ' ' , 1), '-',
       lpad(split_part(date_end, '/', 1), 2, '0'), '-',
       lpad(split_part(date_end, '/', 2), 2, '0'), ' ',
       lpad(split_part(date_end, ' ', 2), 5, '0'), ':00') AS timestamp) AS date_end,
     end_station,
     CAST(end_terminal AS INT) AS end_terminal,
     CAST(bike_num AS INT) AS bike_num,
     subscription_type,
     zip
    FROM bikeshare.trip_raw;

    CREATE TABLE IF NOT EXISTS bikeshare.station
    STORED AS parquet
    AS SELECT
       CAST(station_id AS INT) AS station_id,
       name,
       lat,
       long,
       CAST(dockcount AS INT) AS dockcount,
       landmark,
       installation
    FROM bikeshare.station_raw;

    CREATE TABLE IF NOT EXISTS bikeshare.station
    STORED AS parquet
    AS SELECT
       CAST(station_id AS INT) AS station_id,
       name,
       lat,
       long,
       CAST(dockcount AS INT) AS dockcount,
       landmark,
       installation
    FROM bikeshare.station_raw;

    CREATE TABLE IF NOT EXISTS bikeshare.weather
    STORED AS parquet
    AS SELECT
    CAST( concat( split_part(`date`, '/', 3), '-',
       lpad(split_part(`date`, '/', 1), 2, '0'), '-',
       lpad(split_part(`date`, '/', 2), 2, '0')) AS timestamp) AS date_recorded,
     CAST(max_temperature_f AS INT) AS max_temperature,
     CAST(mean_temperature_f AS INT) AS mean_temperature_f,
     CAST(min_temperaturef AS INT) AS min_temperaturef,
     CAST(max_dew_point_f AS INT) AS max_dew_point_f,
     CAST(meandew_point_f AS INT) AS meandew_point_f,
     CAST(min_dewpoint_f AS INT) AS min_dewpoint_f,
     CAST(max_humidity AS INT) AS max_humidity,
     CAST(mean_humidity AS INT) AS mean_humidity,
     CAST(min_humidity AS INT) AS min_humidity,
     max_sea_level_pressure_in,
     mean_sea_level_pressure_in,
     min_sea_level_pressure_in,
     CAST(max_visibility_miles AS INT) AS max_visibility_miles,
     CAST(mean_visibility_miles AS INT) AS mean_visibility_miles,
     CAST(min_visibility_miles AS INT) AS min_visibility_miles,
     CAST(max_wind_speed_mph AS INT) AS max_wind_speed_mph,
     CAST(mean_wind_speed_mph AS INT) AS mean_wind_speed_mph,
     CAST(max_gust_speed_mph AS INT) AS max_gust_speed_mph,
     CAST(precipitation_in AS INT) AS precipitation_in,
     CAST(cloud_cover AS INT) AS cloud_cover,
     events,
     CAST(wind_dir_degrees AS INT) AS wind_dir_degrees,
     zip
     FROM bikeshare.weather_raw;
-- BABS - Bay Area Bike Share dataset:2 ends here
