-- Big Cities Health Coalition
    CREATE DATABASE IF NOT EXISTS bchc;
    USE bchc;

    CREATE EXTERNAL TABLE bchc.healthstats_raw (
           indicator_category STRING,
           indicator STRING,
           indicator_name STRING,
           indicator_name_graph STRING,
           year INT,
           sex STRING,
           race_ethnicity STRING,
           value DOUBLE,
           place STRING,
           bchc_requested_methodology STRING,
           source STRING,
           methods STRING,
           notes STRING,
           90pct_confidence_low STRING,
           90pct_confidence_high STRING,
           95pct_confidence_low STRING,
           95pct_confidence_high STRING )
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
    WITH SERDEPROPERTIES ('field.delim'='\t', 'serialization.format'='\t')
    STORED AS TEXTFILE
    LOCATION 's3a://gregoryg/datasets/big-cities-health-coalition'
    TBLPROPERTIES ('skip.header.line.count'='1');

  -- optimized Parquet-backed table
  CREATE TABLE bchc.healthstats
  STORED AS PARQUET
  AS SELECT
    regexp_replace(indicator_category, '"', '') AS indicator_category, 
    regexp_replace(indicator, '"', '') AS indicator, 
    regexp_replace(indicator_name, '"', '') AS indicator_name, 
    regexp_replace(indicator_name_graph, '"', '') AS indicator_name_graph, 
    `year`, 
    regexp_replace(sex, '"', '') AS sex, 
    regexp_replace(race_ethnicity, '"', '') AS race_ethnicity, 
    `value`, 
    regexp_replace(place, '"', '') AS place,
    regexp_extract(place, '([^,"]+),[ ]*([^,"]+)', 1) AS city,
    regexp_extract(place, '([^,"]+),[ ]*([^,"]+)', 2) AS state,
    regexp_replace(bchc_requested_methodology, '"', '') AS bchc_requested_methodology, 
    regexp_replace(source, '"', '') AS source, 
    regexp_replace(methods, '"', '') AS methods, 
    regexp_replace(notes, '"', '') AS notes, 
    CAST(if(90pct_confidence_low = '', 90pct_confidence_low, NULL) AS double) AS 90pct_confidence_low, 
    CAST(if(90pct_confidence_high = '', 90pct_confidence_high, NULL) AS double) AS 90pct_confidence_high, 
    CAST(if(95pct_confidence_low = '', 95pct_confidence_low, NULL) AS double) AS 95pct_confidence_low, 
    CAST(if(95pct_confidence_high = '', 95pct_confidence_high, NULL) AS double) AS 95pct_confidence_high
  FROM bchc.healthstats_raw;
