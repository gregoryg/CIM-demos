-- [[file:~/projects/cloudera-demos/personalrepo-CIM-demos/README.org::*Utility%20data][Utility data:1]]
create database IF NOT EXISTS utility;
use utility;

CREATE EXTERNAL TABLE IF NOT EXISTS meterdata_raw (
       LocationName string,
       MeterName    string,
       ChannelName  string,
       IntervalReadDateTime string,
       IntervalReadRawValue float
       )
       COMMENT 'Meter Data using raw .csv files'
       ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
       STORED AS TEXTFILE
       LOCATION 's3a://gregoryg/utility/cdata/ds2/raw/MeterData';


CREATE EXTERNAL TABLE IF NOT EXISTS rateplan_raw (
       LocationName string,
       AccountName string,
       RateplanName string,
       RatePlanDate string
       )
       COMMENT 'Rate plan using raw .csv files'
       ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
       STORED AS TEXTFILE
       LOCATION 's3a://gregoryg/utility/cdata/ds2/raw/RateplanData';

CREATE EXTERNAL TABLE IF NOT EXISTS register_raw (
       LocationName string,
       MeterName string,
       RegisterTypeName string,
       RegisterReadDate string,
       RegisterReadValue float
       )
       COMMENT 'Register data using raw .csv files'
       ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
       STORED AS TEXTFILE
       LOCATION 's3a://gregoryg/utility/cdata/ds2/raw/RegisterData';

CREATE EXTERNAL TABLE IF NOT EXISTS multiplier_raw (
       LocationName string,
       MeterName string,
       RegisterTypeName string,
       ApplicationTypeCode string,
       RegisterReadDate string,
       MultiplierFactor string
       )
       COMMENT 'Multiplier data using raw .csv files'
       ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
       STORED AS TEXTFILE
       LOCATION 's3a://gregoryg/utility/cdata/ds2/raw/MultiplierData';

CREATE EXTERNAL TABLE IF NOT EXISTS weather_raw (
       AmbientYear int,
       AmbientMonth int,
       AmbientDay int,
       AmbientHour int,
       AmbientDate string,
       WetBulbTemp double,
       DryBulbTemp double,
       BarometricPressure double,
       Precipitation double,
       RelativeHumidity double
       )
       COMMENT 'Weather data using raw .csv files'
       ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
       STORED AS TEXTFILE
       LOCATION 's3a://gregoryg/utility/cdata/ds2/raw/WeatherData';


CREATE TABLE IF NOT EXISTS meterdata STORED AS PARQUET
       AS SELECT cast(substring(LocationName, 12) AS int) AS LocationName,
                 cast(substring(MeterName, 8) AS int) AS MeterName,
                 ChannelName,
                 cast(IntervalReadDateTime AS timestamp) AS IntervalReadDateTime,
                 IntervalReadRawValue
          FROM meterdata_raw
          WHERE LocationName <> 'LocationName';

CREATE TABLE IF NOT EXISTS multiplier STORED AS PARQUET
       AS SELECT cast(substring(LocationName, 12) AS int) AS LocationName,
                 cast(substring(MeterName, 11) AS int) AS MeterName,
                 RegisterTypeName,
                 ApplicationTypeCode,
                 cast(RegisterReadDate AS timestamp) AS RegisterReadDate,
                 cast(MultiplierFactor AS decimal(9,4)) AS MultiplierFactor
          FROM multiplier_raw
          WHERE LocationName <> 'LocationName';

CREATE TABLE IF NOT EXISTS rateplan STORED AS PARQUET
       AS SELECT cast(substring(LocationName, 12) AS int) AS LocationName,
                 cast(substring(AccountName, 11) AS int) AS AccountName,
                 RatePlanName,
                 cast(RatePlanDate AS timestamp) AS RatePlanDate
          FROM rateplan_raw
          WHERE LocationName <> 'LocationName';

CREATE TABLE IF NOT EXISTS register STORED AS PARQUET
       AS SELECT cast(substring(LocationName, 12) AS int) AS LocationName,
                 cast(substring(MeterName, 11) AS int) AS MeterName,
                 RegisterTypeName,
                 cast(RegisterReadDate AS timestamp) AS RegisterReadDate,
                 cast(RegisterReadValue AS decimal(9,2)) AS RegisterReadValue
          FROM register_raw
          WHERE LocationName <> 'LocationName';

CREATE TABLE IF NOT EXISTS weather STORED AS PARQUET
       AS SELECT * FROM weather_raw
       WHERE AmbientDate <> 'AmbientDate';
-- Utility data:1 ends here
