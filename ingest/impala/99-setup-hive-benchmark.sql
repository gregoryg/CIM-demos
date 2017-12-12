-- LOCATION $sudouser
create database hivebench;

use hivebench;

create external table rankings_raw
       (
        pageURL VARCHAR(300),
        pageRank INT,
        avgDuration INT
        )
        ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
       LOCATION 's3a://gregoryg/bigtest/rankings/';
        -- LOCATION '${var:USERDIR}/data/bigtest/rankings/';

create external table uservisits_raw
       (
       sourceIP VARCHAR(116),
       destURL VARCHAR(100),
       visitDate timestamp,
       adRevenue FLOAT,
       userAgent VARCHAR(256),
       countryCode CHAR(3),
       languageCode CHAR(6),
       searchWord VARCHAR(32),
       duration INT
       )
       ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
       LOCATION 's3a://gregoryg/bigtest/uservisits/';
       -- LOCATION '${var:USERDIR}/data/bigtest/uservisits/';

create table uservisits stored as parquet as select * FROM uservisits_raw;

create table rankings stored as parquet as select * FROM rankings_raw;
