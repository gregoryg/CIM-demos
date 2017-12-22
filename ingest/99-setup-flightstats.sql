CREATE DATABASE IF NOT EXISTS flightstats;
CREATE EXTERNAL TABLE IF NOT EXISTS flightstats.flights_raw (   
    year INT,   
    month INT,   
    dayofmonth INT,   
    dayofweek INT,   
    deptime INT,   
    crsdeptime INT,   
    arrtime INT,   
    crsarrtime INT,   
    uniquecarrier STRING,   
    flightnum INT,   
    tailnum STRING,   
    actualelapsedtime BIGINT,   
    crselapsedtime BIGINT,   
    airtime BIGINT,   
    arrdelay BIGINT,   
    depdelay BIGINT,   
    origin STRING,   
    dest STRING,   
    distance BIGINT,   
    taxiin INT,   
    taxiout INT,   
    cancelled BIGINT,   
    cancellationcode STRING,   
    diverted TINYINT,   
    carrierdelay INT,   
    weatherdelay INT,   
    nasdelay INT,   
    securitydelay INT,   
    lateaircraftdelay INT ) 
    ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' WITH SERDEPROPERTIES ('field.delim'=',', 'serialization.format'=',') 
    STORED AS TEXTFILE 
    LOCATION 's3a://gregoryg/datasets/flight-stats' 
    TBLPROPERTIES ('skip.header.line.count'='1')

